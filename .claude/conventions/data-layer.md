# Data layer

- `Block.date`/`startTime`/`endTime` are plain `String` (`yyyy-MM-dd`/`HH:mm`) but must never be
  produced by an inline `DateFormatter` — always go through `Manik/Manik/Utilities/DateFormat.swift`.
  That file splits into two kinds: **storage** formatters (`DateFormat.date`/`DateFormat.time`) pin
  `en_US_POSIX` locale so the string written to Firestore can't be corrupted by device
  locale/calendar; **display** formatters (`DateFormat.dayNumber`/`weekdayLetter`/`monthYear`) use
  `Locale.current` so on-screen dates follow the app's language — the app is multilingual via the
  String Catalog, so display formatters must never hardcode a locale. Both keep the salon's fixed
  `TimeZone`. `firestore.rules` regex-validates the storage format server-side
  (`hasValidBlockFormat()`) as defense in depth. Times shown on screen must go through
  `DateFormat.hourLabel(for:)`/`displayTime(_:)` rather than printing the stored `HH:mm` string —
  those use `setLocalizedDateFormatFromTemplate("jmm")`, so an English device gets "9:00 AM". Use
  the `"jmm"` template, not `"j"`: the latter silently drops minutes.
  **Any display formatter that combines more than one field must go through
  `templateFormatter(_:)`, never a fixed `dateFormat` string.** A fixed pattern pins the *order* of
  the fields and lets the locale change only the words: `"d MMMM"` gives the correct "12 серпня" in
  Ukrainian and the wrong "12 August" in English, where the convention is "August 12". The template
  (`"dMMMM"`) states which fields are wanted and lets the locale order them. The one deliberate
  exception is `monthYear`, which keeps the fixed `"LLLL y"`: `LLLL` is the *standalone* month form
  ("Серпень 2026"), while a template would produce the genitive "серпня 2026" — wrong for a bare
  month header. Don't "fix" that one.
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
- **A new field added to a model whose collection already has documents must be optional.** Swift's
  synthesized `init(from:)` does **not** fall back to a property's default value — a missing key
  throws `keyNotFound`, so `var isActive = true` would break decoding for every pre-existing
  document and render the whole list empty. Declare `var isActive: Bool?` and hide the optional
  behind a computed accessor (`var isOffered: Bool { isActive ?? true }`) that the rest of the code
  reads instead. Write the field explicitly on create so only legacy documents rely on the fallback.
  Optional `var`s also keep the memberwise initializer source-compatible (they default to `nil`),
  so existing call sites don't need touching.
- **Money is `Int`, never `Double`.** `Service.price` is whole PLN; `ServiceFormat` renders it with
  `.fractionLength(0)` and the input field uses `.numberPad`. `Double` accumulates rounding error
  once values get summed (the Stats screen does exactly that), and `.numberPad` has no decimal-
  separator key at all, which removes the whole class of locale-parsing bugs — no `FormatStyle`,
  no `.locale(.current)`, just `Int(text)`. If groszy are ever needed, switch to minor units
  (`Int` groszy), not back to floating point. Changing a stored numeric field's type is a data
  migration: a Firestore double decodes into `Int` only when it is whole (`800.0` yes, `450.5` no),
  and one bad document fails the whole query.
- In `firestore.rules`, **`write` means create + update + delete**, and on a delete
  `request.resource` is `null`. Any rule that validates incoming fields must therefore be attached
  to `create, update` with `delete` allowed separately — `allow write: if isMaster() &&
  hasValidServiceFormat()` silently breaks deletion. Both `services` and `blocks` are split this way.
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
