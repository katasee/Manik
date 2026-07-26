# Data layer

- `Block.date`/`startTime`/`endTime` are plain `String` (`yyyy-MM-dd`/`HH:mm`) but must never be
  produced by an inline `DateFormatter` — always go through `Manik/Manik/Utilities/DateFormat.swift`.
  That file splits into two kinds: **storage** formatters (`DateFormat.date`/`DateFormat.time`) pin
  `en_US_POSIX` locale so the string written to Firestore can't be corrupted by device
  locale/calendar; **display** formatters (`DateFormat.dayNumber`/`weekdayLetter`/`monthYear`) use
  `Locale.current` so on-screen dates follow the app's language — the app is multilingual via the
  String Catalog, so display formatters must never hardcode a locale. Both keep the salon's fixed
  `TimeZone`. `firestore.rules` regex-validates the storage format server-side
  (`hasValidBlockFormat()`) as defense in depth.
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
