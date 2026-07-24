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

**Current implementation status and the ordered next-steps checklist live in `docs/plan.md`.**
Check it at the start of a session to see what's done and what's next, and update it (check off /
add / reorder steps) whenever that changes — it's what lets work resume consistently from any
machine or terminal, not just this conversation.

**Don't edit `docs/plan.md` or a feature's `docs/superpowers/specs/`/`docs/superpowers/plans/`
files after every small back-and-forth while a feature is still being worked on** (e.g. a follow-up
tweak, a rename, a "why do we need this file" question mid-implementation). Batch those doc
sync-ups to once, at the end, when the feature itself is actually settled — editing docs on every
turn multiplies unrelated diff churn and burns time out of proportion to keeping the doc
turn-by-turn current.

## Architecture

**MVVM + Repository pattern, dependency injection via initializers — no singletons of our own.**

- ViewModels use the **`@Observable` macro** (Swift Observation, iOS 17+), not the older
  `ObservableObject`/`@Published` pair — plain `var` properties, no `@Published`. Views hold them
  with `@State private var viewModel = SomeViewModel()`, not `@StateObject`. Deployment target is
  iOS 17.2 so this is available everywhere; don't reach for `ObservableObject` out of habit.
- Views/ViewModels are organized **by feature, not by layer** — e.g. `Manik/Manik/Auth/` holds
  `AuthView.swift` and `AuthViewModel.swift` together, rather than spreading them across generic
  top-level `Views/`/`ViewModels` folders. A model only lives inside a feature folder if it's
  genuinely private to that feature; anything referenced from more than one feature belongs in
  `Manik/Manik/Models/` instead — that's where `UserProfile`, `Service`, and `Block` live, since all
  three get read from both the master and client cabinets (e.g. a client's name shown in the
  master's requests list), not just from the screen that created them.
  `Service`/`Block` use `@DocumentID var id: String?` (Firestore assigns it, don't encode it
  yourself). `UserProfile.id` is `uid`, since that collection is keyed by the Firebase Auth uid
  rather than an auto-generated document ID.
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
- Two `PBXFileSystemSynchronizedRootGroup`s feed the `Manik` target: `Manik/Manik/` (app source) and
  `Manik/Assets/` (build resources that aren't Swift source living next to feature code — currently
  just `Manik/Assets/Font/`). Both are auto-picked-up like the `GoogleService-Info.plist` case above;
  dropping a file into either tree is enough, no manual "Add Files" step.
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

User-facing strings never sit as bare literals in a View — they go in
`Manik/Manik/Localizable.xcstrings` (String Catalog) under a `feature.kind.name` key
(e.g. `auth.field.email`, `auth.action.signUp`) and get pulled in via `String(localized: "key")`.
Exception: the "Manik" wordmark/brand name — it's not translated, leave it as a literal. Add the
key to the catalog in the same change that introduces the string; don't leave it dangling for a
later pass.

Text never uses the system font — always go through `Font.elmsSans(_:_:)`
(`Manik/Assets/Font/Extension+ElmsSans.swift`), e.g. `.font(.elmsSans(.bold, 32))`, never
`.font(.system(...))`, `.font(.title)`, `.bold()`, or similar. Pick the closest weight from
`ElmsSans` (`regular`/`medium`/`semiBold`/`bold`, in `Manik/Assets/Font/ElmsSansWeight.swift`)
instead of layering SwiftUI's own `.fontWeight()` on top. The four `.ttf` files sit next to these
two Swift files in `Manik/Assets/Font/` and are registered by hand in `Info.plist` under
`UIAppFonts` — adding a new weight means dropping the `.ttf` in that folder *and* adding its
filename to `UIAppFonts`, or `Font.custom` silently falls back to the system font with no warning
or crash.

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
