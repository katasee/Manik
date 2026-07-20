# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (must succeed before considering any change done):

```bash
cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build
```

There is no test target, linter, or formatter configured yet.

## Project

Manik is a Booksy-style iOS booking app for a single nail salon master. SwiftUI + Firebase
(Auth + Firestore), one app with two role-gated cabinets (master / client). Full product spec —
data model, screen flows, out-of-scope list — lives in
`docs/superpowers/specs/2026-07-15-manik-mvp-design.md`; keep it in sync with any product decision
that changes scope, not just this file.

## Architecture

**MVVM + Repository pattern, dependency injection via initializers — no singletons of our own.**

- `Manik/Manik/Models/` — plain Codable structs (`UserProfile`, `Service`, `Block`). `Service` and
  `Block` use `@DocumentID var id: String?` (Firestore assigns it, don't encode it yourself).
  `UserProfile.id` is `uid`, since that collection is keyed by the Firebase Auth uid rather than an
  auto-generated document ID.
- `Block.date`/`startTime`/`endTime` are plain `String` (`yyyy-MM-dd`/`HH:mm`) but must never be
  produced by an inline `DateFormatter` — always go through `Manik/Manik/Utilities/DateFormat.swift`
  (`DateFormat.date`/`DateFormat.time`), which pins `en_US_POSIX` locale and the salon's fixed
  `TimeZone` so device locale/calendar settings can't corrupt the stored string. `firestore.rules`
  regex-validates the same format server-side (`hasValidBlockFormat()`) as defense in depth.
- `Manik/Manik/Services/Repositories/` — protocols only (`AuthRepository`, `ServiceRepository`,
  `BlockRepository`). These files must **not** import Firebase — that's the whole point: ViewModels
  depend on these contracts, not on Firestore/Auth directly, so a fake implementation can stand in
  for SwiftUI previews or tests without touching the network.
- `Manik/Manik/Services/Firestore/` — concrete implementations (`FirebaseAuthRepository`,
  `FirestoreServiceRepository`, `FirestoreBlockRepository`). `Firestore.firestore()`/`Auth.auth()`
  are singletons managed by the Firebase SDK itself; that's fine and expected — what we avoid is
  wrapping *our own* repository classes in `.shared` singletons. ViewModels take a repository
  protocol as an init parameter, defaulting to the real Firestore-backed implementation.
- Firestore's Codable convenience methods — `setData(from:)`, `addDocument(from:)` — have **no
  `async` overload** in this SDK version, only `throws` with an optional completion closure.
  Writing `try await someRef.setData(from: model)` compiles but silently resolves to the sync
  overload (Swift warns "No 'async' operations occur..."), so the write becomes fire-and-forget —
  errors never surface. Always encode manually with `Firestore.Encoder().encode(_:)` and call the
  raw dictionary method instead (`setData(_:)` / `addDocument(data:)`), which Swift auto-bridges
  from the underlying ObjC `completion: (NSError?) -> Void` overload into a real `async throws`.
  The compiler warning **"No 'async' operations occur within 'await' expression"** is the tell —
  treat it as a real, actionable bug report, not noise. That's different from the stale SourceKit
  "No such module"/"Cannot find type" errors that show up after almost every file write and clear
  themselves once indexing catches up (verify those against an actual `xcodebuild` run, not at
  face value) — the async-operations warning is a genuine compiler diagnostic about the code as
  written and won't go away on its own.
- Realtime data uses **async/await + `AsyncStream`** (`observeBlocks()`, `observeServices()`), not
  Combine. Each Firestore `addSnapshotListener` callback yields the full current array for that
  query; `continuation.onTermination` removes the listener. Listener errors are currently swallowed
  (`{ snapshot, _ in ... }`) — if that needs to surface to the UI, switch to `AsyncThrowingStream`
  rather than bolting an error side-channel onto `AsyncStream`.
- Block state machine: `available → pending → confirmed`, with cancel/decline both returning to
  `available`. A block carries `offeredServiceIds: [String]` (services the master allows for that
  time slot) and `bookedServiceId: String?` (the one the client actually picked at booking time).
  Firestore rules (`firestore.rules`, deployed manually via Firebase Console — no CLI/CI hookup)
  mirror this server-side, not just at the SwiftUI layer: `hasValidBlockFormat()` enforces the
  `date`/`startTime`/`endTime` format, and `isClientBooking()`/`isClientCanceling()` require
  `bookedServiceId` to be a member of `offeredServiceIds` *and* pin `date`/`startTime`/`endTime`/
  `offeredServiceIds` to stay unchanged — a client's write can only touch `status`/`clientId`/
  `bookedServiceId`, never reschedule the slot itself.
- One fixed master account, no multi-tenancy. Role lives in `users/{uid}.role` and is set manually
  in the Firebase Console after sign-up (there's no admin UI for granting the master role).
  `firestore.rules` protects this: a user can only self-create their `users/{uid}` doc with
  `role == "client"`, and `update` requires `role` to stay unchanged, so a client can never write
  their way to `master` through the app or the SDK directly. Reads are also restricted to the
  owner or the master (`isMaster() || request.auth.uid == uid`) so clients can't list/harvest other
  clients' names and emails.

## Code style

Any function/initializer call with 3 or more arguments gets one argument per line, not packed onto
one line:

```swift
throw NSError(
    domain: "Auth",
    code: 401,
    userInfo: [NSLocalizedDescriptionKey: "Not signed in"]
)
```

Same for declaring a function with 3+ parameters. Under 3 arguments, keep it on one line.

## Firebase SDK

The Firebase iOS SDK is a normal remote Swift package dependency
(`https://github.com/firebase/firebase-ios-sdk`, "Up to Next Major Version"), providing the
`FirebaseAuth` and `FirebaseFirestore` products to the `Manik` target. Requires Xcode 16.3+ (Swift
tools version 6.1); the project now builds on Xcode 16.4. (Earlier this was a local Swift package
reference pointing at a machine-specific `~/Developer/firebase-ios-sdk` checkout, needed because
Firebase >= 12.15.0 requires Swift tools 6.1 and the project was still on Xcode 16.1 — that
workaround is gone now that Xcode is updated.)

`GoogleService-Info.plist` is gitignored (regenerate from Firebase Console per environment) but
must exist on disk in `Manik/Manik/` for the app to run — Xcode's synchronized-folder project
format (`PBXFileSystemSynchronizedRootGroup`) means any file dropped into that directory tree is
picked up automatically, no manual "Add Files" step needed.
