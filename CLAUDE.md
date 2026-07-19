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
- `Manik/Manik/Services/Repositories/` — protocols only (`AuthRepository`, `ServiceRepository`,
  `BlockRepository`). These files must **not** import Firebase — that's the whole point: ViewModels
  depend on these contracts, not on Firestore/Auth directly, so a fake implementation can stand in
  for SwiftUI previews or tests without touching the network.
- `Manik/Manik/Services/Firestore/` — concrete implementations (`FirebaseAuthRepository`,
  `FirestoreServiceRepository`, `FirestoreBlockRepository`). `Firestore.firestore()`/`Auth.auth()`
  are singletons managed by the Firebase SDK itself; that's fine and expected — what we avoid is
  wrapping *our own* repository classes in `.shared` singletons. ViewModels take a repository
  protocol as an init parameter, defaulting to the real Firestore-backed implementation.
- Realtime data uses **async/await + `AsyncStream`** (`observeBlocks()`, `observeServices()`), not
  Combine. Each Firestore `addSnapshotListener` callback yields the full current array for that
  query; `continuation.onTermination` removes the listener. Listener errors are currently swallowed
  (`{ snapshot, _ in ... }`) — if that needs to surface to the UI, switch to `AsyncThrowingStream`
  rather than bolting an error side-channel onto `AsyncStream`.
- Block state machine: `available → pending → confirmed`, with cancel/decline both returning to
  `available`. A block carries `offeredServiceIds: [String]` (services the master allows for that
  time slot) and `bookedServiceId: String?` (the one the client actually picked at booking time).
  Firestore rules (`firestore.rules`, deployed manually via Firebase Console — no CLI/CI hookup)
  validate that a client's `bookedServiceId` is a member of the block's `offeredServiceIds` at
  booking time, not just the SwiftUI layer.
- One fixed master account, no multi-tenancy. Role lives in `users/{uid}.role` and is set manually
  in the Firebase Console after sign-up (there's no admin UI for granting the master role).

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

## Firebase SDK gotcha

The Firebase iOS SDK is added as a **local Swift package reference** pointing at
`~/Developer/firebase-ios-sdk` (see `XCLocalSwiftPackageReference` in `project.pbxproj`), not a
normal remote SPM dependency. This is a workaround: Firebase >= 12.15.0 requires Swift tools
version 6.1, which needs Xcode 16.3+, and this project is on Xcode 16.1. If Xcode gets upgraded to
16.3+, this can be switched back to a normal `https://github.com/firebase/firebase-ios-sdk` remote
package dependency pinned with "Up to Next Major Version". Until then, anyone building this project
on a different machine needs `firebase-ios-sdk` checked out at that same path.

`GoogleService-Info.plist` is gitignored (regenerate from Firebase Console per environment) but
must exist on disk in `Manik/Manik/` for the app to run — Xcode's synchronized-folder project
format (`PBXFileSystemSynchronizedRootGroup`) means any file dropped into that directory tree is
picked up automatically, no manual "Add Files" step needed.
