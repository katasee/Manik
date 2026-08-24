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
  master's requests list), not just from the screen that created them. `Models/` is the **domain
  layer** — the M of MVVM — not "files that contain a struct": it also holds derived properties of
  domain types (`Block/Block+Minutes.swift`, `Block/Block+StartDate.swift`) and domain
  configuration with no fields at all (`WorkHours.swift`). The rule for extensions is **an extension
  of our type lives beside the type; an extension of a foreign type lives where it's used** — which
  is why `View+Shadow.swift` and `Extension+ElmsSans.swift` sit in `Assets/UICommons/` next to the
  components that consume them, and not in some `Extensions/` folder. A folder grouping files by
  the `extension` keyword would organize by language construct, exactly the layer-first mistake this
  section rejects. A type gets its own subfolder (`Models/Block/`) once it spans more than one file;
  single-file types stay flat. **A type that exists only to serve one neighbour lives in that
  neighbour's file, not in its own** — `BlockActionConfirmation` sits with `BlockAction`,
  `StatsRoute` with `StatsLinkRow`, `MonthlyTotals` with `StatsCalculator`. Order inside such a file
  is supporting type first, the file's namesake second. This is not a licence to pile unrelated
  types together: the test is whether the type would ever be referenced without its host, and a
  three-line enum that only feeds one `navigationDestination` would not. A feature also owns
  **presentation models** — `BookingSlot`, `ServiceOffer`, `MonthlyStats` — built from a persistence
  model and never written back. They carry ready-made
  display strings so views never touch `DateFormat` or a raw stored value, and they keep persistence
  fields the screen has no business with (`status`, `clientId`) out of reach of the view.
  **The arithmetic that feeds a presentation model does not format it.** A pure calculator
  (`StatsCalculator`) returns numbers — `MonthlyTotals` is `Int`s — and the presentation model's
  `init(totals:)` does every `ServiceFormat.price`, `.formatted()` and percent string. Mixing the
  two has a concrete cost, not just a stylistic one: with no test target the only way to check a
  figure is a temporary text `#Preview`, and comparing *formatted* output makes that check depend on
  the device locale. Rules about what to *show* (hide the comparison when the previous month was
  zero) belong on the presentation side too — that is a display decision, not a sum. The same
  principle applies
  to reusable *views*: a component used (or reusable) across more than one feature lives in
  `Manik/Manik/Assets/UICommons/` (e.g. `WeekDayStrip`, `DashedSlot`, `View+BrandShadow`, the
  `ElmsSans` font extension), not in a feature folder, and must not depend on any feature's types
  (e.g. a feature's `*Metrics`) — give it its own private constants or take them as parameters.
  **When several cards repeat themselves, extract the chrome, not the card.** Cards that differ in
  structure — centred vs leading, a row with a chevron, one of them a `NavigationLink` — stay
  separate views; folding them into one configurable card trades short honest files for a chain of
  `if`s behind a growing set of flags. What is genuinely shared is the surface: padding, fill,
  corner radius, shadow. That lives in `.cardSurface(fill:padding:cornerRadius:fillsHeight:)`, and
  the repeated tinted glyph in `IconBadge`. Note `fillsHeight`: the frame that equalizes heights in
  a `GridRow` must sit *between* the padding and the background, which a caller cannot reproduce
  from outside, so the modifier branches internally instead of exposing the order.
  A feature folder holds only that feature's View, view model, feature-private model, subviews, and
  a feature-local metrics file (e.g. `Schedule/ScheduleMetrics.swift`, `TabBar/TabBarMetrics.swift`).
  A metrics file holds **layout** numbers only — anything the view model needs to reason about
  (salon working hours, tolerances, durations) is domain config and lives in `Models/`
  (e.g. `Models/WorkHours.swift`), otherwise the view model ends up importing the view layer.
  A generic UICommons component (e.g. `SwipeToDelete<Content>`) must keep its constants enum at
  **file scope**, not nested inside the struct — Swift forbids static stored properties in types
  nested within generic types, and moving them "tidily" inside breaks the build.
- Screen-covering popups are presented by the feature that owns them, via `.fullScreenCover` +
  `.presentationBackground(.clear)` — **not** by hoisting state into `MasterRootView`/
  `ClientRootView` so a shared `ZStack` can draw them above `CustomTabBar`. Presentation modifiers
  render outside the view hierarchy, so the tab bar stops being a reason to leak feature types into
  the router. To keep a custom fade instead of the system slide-up, wrap the *state mutation* in a
  `Transaction` with `disablesAnimations = true` and animate inside the popup; never put
  `.transaction { }` on the modifier, which disables animations for the whole subtree.
- **A screen that owns a `NavigationStack` inside a tab does not inherit the router's bottom
  inset.** `MasterRootView`/`ClientRootView` reserve room for `CustomTabBar` with
  `.safeAreaInset(edge: .bottom)` on the tab `Group`, and that is enough for a plain screen like
  `MyServicesView`. A `NavigationStack` expands into the safe area, so the inset never reaches a
  `ScrollView` inside it and the last row stays clipped even when scrolled fully down. Such a screen
  takes an explicit `bottomClearance: CGFloat` parameter and applies it as the scroll content's
  bottom padding; the router passes `TabBarMetrics.Size.reservedClearance`, so the feature still
  doesn't import the tab bar's metrics (`BookingView` does this). Standalone `#Preview`s pass `0` —
  there is no tab bar there. That happened at the third screen: the router still passes the value,
  but the screen applies it with `.bottomClearance(_:)` from
  `Assets/UICommons/View+BottomClearance.swift` rather than a bare `.padding(.bottom,)`. Three
  consumers: `BookingView`, `BookingDatesView`, `StatsView`. The modifier deliberately does **not**
  read `TabBarMetrics` itself — a UICommons component must not depend on a feature's metrics, and
  keeping the value a parameter is what stops a screen importing the tab bar's numbers.
- **Nested `NavigationLink`s don't work.** Wrapping a whole card in a link and then putting a link
  inside it is unpredictable in SwiftUI — the inner one may never receive taps, or both fire. If a
  card needs more than one destination, don't wrap the card: give each control its own link
  (`ServiceOfferCard` does this — each hour chip pushes that slot, the round chevron pushes the
  whole offer). Accept that the card body then stops being tappable, and give any icon-only control
  an `accessibilityLabel`, since it is otherwise silent to VoiceOver.
- **A `Task {}` created inside a `View`'s helper method does not inherit `MainActor`.** `Task`
  captures isolation *statically*, from the enclosing declaration — and helper methods on a `View`
  struct are nonisolated (only `body` carries the protocol's `@MainActor`). So anything
  **synchronous** called after an `await` — a `dismiss()` closure, an `onSuccess()` callback —
  runs on the generic executor and mutates `@State` off the main thread. Nothing diagnoses this:
  the callee is nonisolated too, so even Swift 6 stays quiet. Write `Task { @MainActor in ... }`
  at these sites (`ServiceFormPopup`, `AddNewSlotBlock`, `BlockActionButton` all do). Don't
  annotate the *method* instead — that cascades up through every caller (`actions(dismiss:)` and
  friends) and then into closure-conversion questions. A `Task {}` whose only post-`await` work is
  another `await` needs nothing: the async call hops to its own actor by itself.
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
