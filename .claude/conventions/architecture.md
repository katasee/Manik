# Architecture

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
  master's requests list), not just from the screen that created them. The same principle applies
  to reusable *views*: a component used (or reusable) across more than one feature lives in
  `Manik/Manik/Assets/UICommons/` (e.g. `WeekDayStrip`, `DashedSlot`, `View+BrandShadow`, the
  `ElmsSans` font extension), not in a feature folder, and must not depend on any feature's types
  (e.g. a feature's `*Metrics`) — give it its own private constants or take them as parameters.
  A feature folder holds only that feature's View, view model, feature-private model, subviews, and
  a feature-local metrics file (e.g. `Schedule/ScheduleMetrics.swift`, `TabBar/TabBarMetrics.swift`).
  `Service`/`Block` use `@DocumentID var id: String?` (Firestore assigns it, don't encode it
  yourself). `UserProfile.id` is `uid`, since that collection is keyed by the Firebase Auth uid
  rather than an auto-generated document ID.
- `Manik/Manik/Services/Repositories/` — protocols only (`AuthRepository`, `ServiceRepository`,
  `BlockRepository`). These files must **not** import Firebase — that's the whole point: ViewModels
  depend on these contracts, not on Firestore/Auth directly, so a fake implementation can stand in
  for SwiftUI previews or tests without touching the network.
- `Manik/Manik/Services/Firestore/` — concrete implementations (`FirebaseAuthRepository`,
  `FirestoreServiceRepository`, `FirestoreBlockRepository`). `Firestore.firestore()`/`Auth.auth()`
  are singletons managed by the Firebase SDK itself; that's fine and expected — what we avoid is
  wrapping *our own* repository classes in `.shared` singletons. ViewModels take a repository
  protocol as an init parameter, defaulting to the real Firestore-backed implementation.
- Two `PBXFileSystemSynchronizedRootGroup`s feed the `Manik` target: `Manik/Manik/` (app source) and
  `Manik/Assets/` (build resources that aren't Swift source living next to feature code — currently
  just `Manik/Assets/Font/`). Both are auto-picked-up like the `GoogleService-Info.plist` case (see
  `firebase.md`); dropping a file into either tree is enough, no manual "Add Files" step.
