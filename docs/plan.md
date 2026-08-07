# Manik — Implementation Plan

Living checklist of implementation progress and next steps. Update this file whenever a step is
finished or the plan changes — this is what lets work continue from any machine/terminal. Full
product scope/design decisions live in `docs/superpowers/specs/2026-07-15-manik-mvp-design.md`;
this file is just "what's done, what's next," not a design doc.

## Done

- **PR1 — data layer**: `Models/` (`UserProfile`, `Service`, `Block`), `Services/Repositories/`
  (protocols) + `Services/Firestore/` (implementations), `firestore.rules` (format validation,
  privilege-escalation protection, client-booking field pinning). Firebase SDK as remote SPM
  dependency.
- **PR2 — Auth**: `Auth/AuthView.swift` + `AuthViewModel.swift`, email/password sign in/sign up.
  Design system: custom `ElmsSans` font (`Assets/Font/` + `Assets/UICommons/Extension+ElmsSans.swift`),
  color palette in `Assets.xcassets` (`Background`, `Ink`, `TextSecondary`, `Surface`,
  `FieldBackground`, `Badge`), shared `View+BrandShadow`. `AuthView` split into
  `AuthFieldView`/`ModeSwitcher`/`AuthFocusField`/`AuthMetrics`.
- **PR3 — root routing (in progress, branch `feature/pr3/root-routing`)**: `Root/RootView.swift` +
  `RootViewModel.swift` — checks auth state + role (`fetchProfile()`), routes to
  `Master/MasterRootView.swift` / `Client/ClientRootView.swift` (currently placeholder screens:
  cabinet title + name + sign out). `ManikApp` now starts from `RootView()`.
- **PR4 — custom tab bar (branch `feature/pr-4-custom-tabbar`)**: `TabBar/` (`CustomTabBar` +
  `CabinetKind`, `TabBarButton`, `TabBarActiveIndicator`, `TabBarBadge`, `TabBarMetrics`),
  `Master/MasterTab.swift`, `Client/ClientTab.swift`. Floating dark-capsule tab bar (fixed 70pt
  height, visible captions under each icon) wired into `MasterRootView` (3 tabs) and
  `ClientRootView` (3 tabs — added "Акаунт"/`.account`, currently an `EmptyView()` placeholder).
  Colors consolidated: `TextPrimary` renamed to `Ink` (general dark UI token, not just text), the
  two dedicated `TabBarBackground`/`TabBarActiveBackground` colors were dropped in favor of
  reusing `Ink`/`Background`. Badge parameter exists but is stubbed to `nil` until the Requests
  screen ships (tracked as a Next step above).
- **PR5 — Master Schedule shell (branch `feature/pr-5-scheduleView`)**: view-only Schedule screen —
  `Master/Schedule/` (`ScheduleView` with title + week strip + hourly timeline, `@State selectedDate`,
  no view model; `HourlyTimelineView` = hour label per row with a `DashedSlot` in the gap;
  `ScheduleMetrics`). Reusable components pulled into `Assets/UICommons/`: `WeekDayStrip` (week-day
  date picker) and `DashedSlot` (tappable dashed-outline labeled slot), both decoupled from feature
  metrics. `DateFormat` split into storage formatters (`date`/`time`, pinned `en_US_POSIX` for
  Firestore) and display formatters (`dayNumber`/`weekdayLetter`/`monthYear`, `Locale.current` so the
  UI is multilingual). Tab bar scroll-clearance fixed: content reserves space via a `Color.clear`
  `safeAreaInset` (`TabBarMetrics.reservedClearance`) while the bar stays a `ZStack` overlay so its
  switch animation stays smooth. Block-rendering work (`ScheduleBlockCard`, `ScheduleBlockDetailSheet`,
  `ScheduleViewModel`, `UserRepository`/`FirestoreUserRepository`, `SchedulePreviewData`) was built
  then **git-stashed** for the follow-up slices below (still sitting in `git stash list`, untouched
  by PR7 — see PR7 note on why).
- **PR7 — Master Schedule: create free-time slot (branch `feature/pr-7-createFreeSlot`)**: tapping
  `DashedSlot`'s "+ Додати вільний час" on any hour row opens `Master/Schedule/CreateBlock/
  AddNewSlotBlock.swift` — a custom centered popup. Backdrop is a dimming `Rectangle().opacity(0.5)`,
  tapping it dismisses the popup (an accessible `Button`, not `onTapGesture`); the card carries
  `.brandShadow()` (needs `.compositingGroup()` first, otherwise SwiftUI shadows every child
  individually instead of the card's outline). PR7 presented it as a `ZStack` overlay owned by
  `MasterRootView`, because that was the only shared `ZStack` spanning both the schedule content and
  the floating `CustomTabBar`; **PR8 replaced that with `.fullScreenCover` owned by `ScheduleView`**
  — see the PR8 entry. Fields: "Дата" is a native `DatePicker(.date)`; "Початок"/"Кінець" are plain
  `TextField`s for manual `HH:mm` entry (parsed/validated in `CreateBlockViewModel`'s
  `startTimeText`/`endTimeText`, `didSet`-driven) — not a wheel picker, since a UIKit-wrapped
  `UIDatePicker` (tried first, for `minuteInterval` snapping) and a plain `DatePicker` wheel were
  both dropped in favor of typing the time directly. Default duration when opening the popup is 1
  hour (`ScheduleMetrics.CreatePopup.defaultDurationMinutes = 60`). Services render as a checklist
  (`ServicesChecklist`, checkmark-circle icons) reading whatever's in the `services` Firestore
  collection — no CRUD screen yet (still step 1 below), so services are hand-seeded via Firebase
  Console for now. A `#if DEBUG` override feeds a `FakeServiceRepository`/`SchedulePreviewData`
  instead of live Firestore — kept deliberately so the checklist has something to show before real
  services are seeded; it lived in `ScheduleView.serviceRepository` from PR8 (before that, in
  `MasterRootView`) and **PR11 removed it entirely** once services became creatable in-app.
  New files live under `Master/Schedule/CreateBlock/` (`AddNewSlotBlock`,
  `CreateBlockContext`, `CreateBlockViewModel`, `ServicesChecklist`) and `Services/Fakes/`
  (`FakeBlockRepository`, `FakeServiceRepository`) — split out from a flatter `Master/Schedule/`
  once it hit 11 files.
- **PR8 — Master Schedule: render + delete blocks (branch `feature/pr-8-showBlocks`)**: blocks from
  Firestore now appear on the timeline, which became a **proportional** grid — `Timeline/` holds
  `TimelineGeometry` (pure `CoreGraphics` math: `offset(forHour:)`, `offset(for:)`, `height(for:)`
  against a fixed `Size.hourHeight = 84`), plus `TimelineHourGrid`, `TimelineFreeSlots`,
  `TimelineBlockCards` and the card itself; `HourlyTimelineView` is now just their composition.
  A card's *frame* is exactly its duration — visual breathing room comes from
  `Card.verticalInset` applied **before** `.frame(height:)`, so insetting never distorts the time
  axis. Hour labels are nudged up by `Size.hourLabelCentering` so the glyphs sit centered on their
  line rather than hanging below it (without this everything positioned mathematically *looks*
  short). Overlapping blocks cascade Google-Calendar style: `ScheduledBlock.depth` = how many
  earlier blocks it overlaps, driving both a leading indent and `zIndex`. Swipe-to-delete via a new
  `Assets/UICommons/SwipeToDelete.swift` (generic container — its `Layout` constants must stay at
  file scope, Swift forbids static stored properties in types nested inside generics) backed by a
  new `BlockRepository.deleteBlock(blockId:)`; `firestore.rules` already allowed `delete` for the
  master. Only one row opens at a time (`openBlockId` lives in `HourlyTimelineView`), and tapping
  anywhere in the timeline closes it. `ScheduleViewModel` owns all derived state — it exposes
  `scheduledBlocks: [ScheduledBlock]` and `freeHours: Set<Int>`, rebuilt from `didSet` on
  `blocks`/`selectedDate`/services rather than recomputed in `body`. **Salon working hours and the
  free-slot tolerance moved out of `ScheduleMetrics` into `Models/WorkHours.swift`** (called
  `SalonHours` until PR9 renamed it) — they are domain config, not layout, and the view model can't
  depend on view-layer metrics. An hour keeps
  showing "+ Додати вільний час" while at most `WorkHours.freeSlotToleranceMinutes` (20) of it is
  occupied. `DateFormat` gained `hourLabel(for:)`/`displayTime(_:)` (template `"jmm"`, not `"j"` —
  the latter drops minutes) so times follow the device locale instead of a hardcoded `HH:mm`.
  The create-slot popup moved from a `MasterRootView` `ZStack` overlay to `.fullScreenCover` +
  `.presentationBackground(.clear)` owned by `ScheduleView`; its system slide-up is suppressed with
  a `disablesAnimations` `Transaction` at the mutation site (**not** `.transaction` on the modifier,
  which would kill animations across the whole subtree) while `AddNewSlotBlock` fades itself in/out
  via `@State isVisible` and `withAnimation(_:completion:)`. `MasterRootView` is now a pure router:
  no view model, no popup state, no feature types.

- **PR9 — Master Schedule: block detail popup (branch `feature/pr-9-blockDetail`)**: a card is now
  tappable and opens `Master/Schedule/BlockDetail/BlockDetailPopup.swift` — time range, status pill,
  booked (or offered) service, and the actions the block's status allows.
  - **Status is a first-class concept**: `Components/BlockStatusStyle.swift` extends the domain
    `BlockStatus` with `accentColor`/`textKey`, so the card's accent capsule and the popup's
    `BlockStatusPill` read one source. Third color added (`StatusAvailable` = grey) so `available`
    stops borrowing the pending color.
  - **Shared popup chrome** in `Assets/UICommons/`: `PopupContainer` (backdrop, fade in/out, card
    padding/shadow) plus `PopupPrimaryButton` and `PopupDismissButton`. `AddNewSlotBlock` was
    rebuilt on them, which deleted its private copy of all four. The container hands its
    `fadeOutAndDismiss` **into its content closure** (`content: (_ dismiss: @escaping () -> Void)
    -> Content`) — an `@Entry`-based `EnvironmentValues.popupDismiss` was built first and then
    removed, because `@Environment` resolves where it is *declared*, which forced every button that
    dismisses to be its own `View` struct and silently returned a no-op default if it wasn't.
    Passing `dismiss` explicitly costs one closure parameter and removes that trap entirely.
  - `ScheduleMetrics.CreatePopup` is gone; the only survivor is the default slot duration, now
    `WorkHours.defaultSlotDurationMinutes` — domain config, not layout. `SalonHours` was renamed
    `WorkHours` in the same pass.
  - **Actions**: `BlockAction` (confirm/decline/cancelBooking) carries its own title key, color and
    *optional* confirmation text; `BlockDetailViewModel.availableActions` maps status → actions and
    `perform(_:)` runs them. `BlockActionButton` takes `isLoading`/`isEnabled`/`perform`/`onSuccess`
    rather than the whole view model, so it stays previewable and reusable by the Requests screen.
  - **One `fullScreenCover`, not two**: two covers on the same view are unreliable in SwiftUI — only
    one wins — so create-slot and detail are unified behind `SchedulePopup: Identifiable`.
  - **Swipe-delete now confirms for booked blocks**: `ScheduleViewModel.requestDeletion(of:)` deletes
    `available` blocks immediately and routes everything else through an alert.
  - **Card tap is an `onTapGesture`, not a `Button`** — deliberately. Wrapping the card in a `Button`
    made `SwipeToDelete`'s red backdrop bleed through during the swipe, because `.plain`'s pressed
    state dims the label. A custom `ButtonStyle` ignoring `isPressed` fixes it and was tried; the
    tap gesture plus `.accessibilityAddTraits(.isButton)` was chosen instead. Cost: Switch Control
    and Full Keyboard Access can't reach the card.
  - Folder layout inside the feature settled into `BlockDetail/`, `CreateBlock/`, `Timeline/`
    (grid geometry and layout only), `Components/` (`ScheduleBlockCard`, `BlockStatusPill`,
    `BlockStatusStyle`) and `Preview/`.
  - **The client's name is deliberately absent.** No `pending` block can exist until the client
    booking screen ships, so `UserRepository` would have been a data layer with no data to serve.
  - Accessibility scorecard for step 9 below: nothing was paid off. `ScheduleBlockCard` briefly
    showed a status pill under `accessibilityDifferentiateWithoutColor` and it was removed on
    request, so a card's status is still conveyed by color alone.

- **PR10 — Master "Мої послуги", read-only list (branch `feature/pr-10-myServices`)**: the master can
  open a services screen and read their price list live from Firestore. Pure UI — the data layer was
  already complete and wasn't touched.
  - `Master/Services/` — `MyServicesView` + `MyServicesViewModel` (`observeServices()`, sorted with
    `localizedStandardCompare`), `ServiceRow`, `ServicesMetrics`, `Preview/ServicesPreviewData`
    (deliberately duplicating `SchedulePreviewData`'s four `Service` literals rather than importing
    another feature's fixtures).
  - `Utilities/ServiceFormat.swift` — first place `Service.price` is rendered anywhere in the app.
    Currency pinned to `PLN` (inferred from `DateFormat.salonTimeZone`, never confirmed — the design
    mockup showed грн); duration via `Duration.UnitsFormatStyle`, which localizes "год"/"хв" itself,
    so no catalog keys were needed for units.
  - **`Master/Stats/StatsView.swift` was extracted** so the `.stats` tab has a real owner and
    `MasterRootView` stays a one-line-per-tab router. It holds the app's **first `NavigationStack`**
    and the temporary entry link into "Мої послуги".
  - **Custom header, not the system nav bar**: `.toolbar(.hidden, for: .navigationBar)` plus a
    `chevron.left` `Button` and a title centered by a `ZStack` (two `Spacer()`s around the title
    would offset it by half the button's width). `navigationTitle` was ruled out because it renders
    in the system font.
  - Design pass after the first cut: subtitle line, black circular "+" button, uppercase section
    header with a live count, and the row rebuilt around a circled star icon. **The star is
    decorative** — `Service` has no `isFeatured`-style field, so the filled/outline distinction from
    the mockup has nothing to drive it. The mockup's per-row "Змінити" link was deliberately not
    built (PR12), and the "+" button was left a stub with an empty action until PR11 wired it.
  - States: `ProgressView` until the first snapshot (`hasLoaded`), `ContentUnavailableView` when
    empty; the section header hides itself rather than reading "· 0".
  - `MyServicesView.init(viewModel:)` is **required, not optional-with-default**. The
    `viewModel ?? MyServicesViewModel()` pattern silently binds the View to
    `FirestoreServiceRepository()`, so a preview that forgets to inject a fake still compiles and
    goes to the network. The repository default stays on the *view model*, which is the composition
    root. `ScheduleView` kept the old pattern through PR10 and was brought in line in PR11,
    alongside its `#if DEBUG` removal, rather than dragging that file into this PR.
  - `swiftui-pro` review: one finding applied — `.contentShape(.circle)` on the "+" button, whose
    `.frame`/`.background` sit *outside* the `Button` and therefore left a ~20pt hit area inside a
    52pt circle. Two findings declined: combining `ServiceRow`/section-header children into single
    accessibility elements, and extracting the header/intro into their own `View` structs.
  - Seven new `services.*` keys (en + uk).

- **PR11 — Master "Мої послуги": додавання послуги (branch `feature/pr-11-addService`)**: кнопка «+»,
  яку PR10 лишив заглушкою, стала робочою — попап із назвою й ціною пише в `services`, і послуга
  одразу видима і в списку, і в чеклісті створення слота. Дата-шар не змінювався взагалі
  (`ServiceRepository.add` існує з PR1), правила теж — звірка з Console показала, що опубліковані
  правила збігаються з локальним `firestore.rules` рядок у рядок.
  - **Тривалість послуги видалена з продукту**, не просто з форми: `Service` = `name` + `price`.
    Тривалість візиту задають межі блоку (`startTime`/`endTime`), тож `durationMinutes` дублював цю
    інформацію і використовувався лише як підпис у рядку списку. Разом із полем пішли
    `ServiceFormat.duration(minutes:)`, другий рядок у `ServiceRow` і `ServicesMetrics.Spacing.rowTextSpacing`.
    Уже засіяні документи з цим полем декодуються далі — Codable ігнорує невідомі ключі.
  - `Master/Services/AddService/` — `AddServicePopup` + `AddServiceViewModel` на наявному
    `PopupContainer`. Валідація: назва непорожня після trim і ціна > 0, без перевірки дублікатів.
    Ціна парситься через `try? Double(text, format: .number.locale(.current))`, а не `Double(text)`:
    `.decimalPad` видає роздільник поточної локалі, тож у полі буде «450,5», а ручна заміна коми
    ламається на роздільниках тисяч.
  - **Тулбар клавіатури обов'язковий** (`@FocusState` + `ToolbarItemGroup(placement: .keyboard)` з
    `common.action.done`): у `.decimalPad`, на відміну від `.numbersAndPunctuation` в
    `AddNewSlotBlock`, немає return-клавіші, тож без нього клавіатуру нічим прибрати — тап по фону
    закрив би всю форму.
  - **Ін'єкція через фабрику**: `MyServicesViewModel.makeAddServiceViewModel()` віддає дочірній VM,
    лишаючи `serviceRepository` приватним. Батько не зберігає дитину й не читає її стан — тому
    форма щоразу відкривається порожньою, а прев'ю з фейком працює наскрізь (додав → рядок
    з'явився). `AddServiceViewModel.init` **без** дефолтного репозиторію, як і `MyServicesView`
    після PR10.
  - `withoutPresentationAnimation(_:)` переїхав із приватного методу `ScheduleView` у
    `Assets/UICommons/PresentationAnimation.swift` — вільна функція, не метод на `View` (вона нічого
    не рендерить). Другий споживач — `MyServicesView`.
  - `FakeServiceRepository` став мутабельним `final class`: стрім більше не завершується, мутації
    транслюються підписникам, `add` сам присвоює `id`. Тепер це виключно прев'ю-дабл — **`#if DEBUG`
    підміна сервісів у `ScheduleView` знята**, а `ScheduleView.init(viewModel:)` став обов'язковим
    (`MasterRootView` створює `ScheduleViewModel()` у `body`, який `@MainActor` — це заодно закрило
    пункт 12 нижче для `ScheduleView`; лишається `AddNewSlotBlock`).
  - Сім нових ключів локалізації (`common.action.done` + шість `services.add.*`), en + uk.

## Next steps (in order)

The ordering below follows the **data chain**, not the mockup order: real services make real slots
possible, real slots make a client booking possible, and a client booking is the only thing that
creates a `pending` block — which is what "Заявки" lists and what "Статистика" counts. Building
either master screen before that link exists means inventing fake data for it twice.

1. **Master — "Мої послуги" (services CRUD)**. Deliberately split off from "Статистика" (which the
   MVP spec makes its permanent entry point) because it's self-contained and unblocks everything
   below. **The whole data layer already exists** — `Models/Service.swift`, all four methods on
   `ServiceRepository`, their `FirestoreServiceRepository` implementations, and
   `firestore.rules:52-55` (`allow write: if isMaster()`). These slices are pure UI. Three
   decisions settled up front: navigation is a real `NavigationStack` (the app has none yet — this
   is the first screen that isn't a popup); the add/edit form is a popup on the existing
   `PopupContainer`, not a full screen, since it's two fields; deleting a service used by
   existing blocks is **allowed** without a cross-collection check — the ids go dangling and the
   already-present `schedule.service.unknown` fallback covers it.
   - ~~**PR10 — read-only list**~~ — **done**, see the PR10 entry under "Done" above.
   - ~~**PR11 — add a service**~~ — **done**, see the PR11 entry under "Done" above. Note it also
     deleted `Service.durationMinutes` outright, so the form is two fields, not three.
   - **PR12 — edit + delete**: same form in edit mode (`update`), plus the existing `SwipeToDelete`
     wired to `delete` with a confirmation step. This is also where the mockup's per-row "Змінити"
     link finally gets an action — PR10 left it out rather than shipping a dead link per row.
2. **Client — "Запис" (Booking)** (mockup screen 03): month calendar → time chips → service picker
   → footer bar with "Продовжити". This is the first place a `pending` block can be born, so it
   gates steps 4 and 5.
3. **Client — "Мої записи" (My bookings)**: list of own pending/confirmed blocks, cancel action.
   Thin follow-on to step 2 — same repository, same models.
4. **Master — "Заявки" (Requests)**: list of `pending` blocks with confirm/decline, reusing
   `BlockDetailPopup` as the detail surface (PR9 shipped the detail half). By now steps 2–3 supply
   real `pending` data instead of hand-seeded documents. Two riders that belong with this slice:
   - Pull `UserRepository`/`FirestoreUserRepository`/`FakeUserRepository` out of `stash@{0}` and
     show the client's name on both the request row and the detail popup — this is the screen that
     finally gives `pending` blocks a way to exist, so the missing name from PR9 becomes visible.
   - Move `BlockStatusPill` + `BlockStatusStyle` from `Master/Schedule/Components/` to
     `Assets/UICommons/` once Requests becomes their second consumer. Note they'd be the first
     domain-aware components in that folder (they switch on `BlockStatus`); if two or three more
     accumulate, a separate `Assets/DomainUI/` is the alternative.
5. **Master — "Статистика" (Stats)**: month summary (revenue/visits/cancellations) inside the
   `Master/Stats/StatsView.swift` shell PR10 created, plus the permanent entry point to "Мої
   послуги" from step 1 replacing PR10's temporary text link. Last of the five because the numbers
   derive from real `confirmed`/cancelled blocks, which only exist once the booking chain above
   works.
6. **Client — "Акаунт" (Account)**: currently an `EmptyView()` placeholder behind the 3rd client
   tab (`ClientTab.account`) — needs real content (profile info, sign out moved here from the
   temporary root placeholder, etc.).
7. **"Забули пароль?"**: decide tappable-stub vs. real `sendPasswordReset` flow, then implement.
   (Was tracked as a task in a now-disconnected MCP tool — re-track here instead.)
8. ~~**Confirm `firestore.rules` deployment**~~ — **done (2026-08-07, during PR11)**: the rules
   published in the Firebase Console for project `manik-5a2b8` were diffed against the local
   `firestore.rules` and are identical line for line. Re-verify only after editing the file, since
   deployment is manual (Console copy-paste, no CLI/CI hookup).
9. **Live badge counter on "Заявки"**: `CustomTabBar`'s badge parameter currently always returns
   `nil` (`Master/MasterRootView.swift`, `CabinetKind.master`'s `badge` closure). Once the
   "Заявки" screen (step 4 above) exists, wire this to a live count of `pending`-status blocks
   from `BlockRepository`, likely via an `AsyncStream` observation similar to `observeBlocks()`.
10. **Accessibility debt (found in PR8 review, deliberately not fixed there)**:
    - `Font.elmsSans(_:_:)` calls `Font.custom(_:size:)` **without `relativeTo:`**, so Dynamic Type
      is effectively off app-wide. Adding it is one line, but the schedule also needs `@ScaledMetric`
      for `Size.hourHeight` or larger text will overflow the cards.
    - On a *card*, a block's status is still conveyed only by the accent-capsule color, and
      VoiceOver never reads it. PR9 built `BlockStatusPill` as the second signal and wired it to
      `\.accessibilityDifferentiateWithoutColor` in `ScheduleBlockCard`, then removed that wiring
      on request — the pill now appears only in `BlockDetailPopup`'s header, unconditionally.
      Re-adding it to the card is a three-line change.
    - `SwipeToDelete`'s trash button has no text label (removed on request), so VoiceOver announces
      the raw SF Symbol name.
11. **Slot creation can overlap an existing block**: since PR8 an hour still offers
    "+ Додати вільний час" while ≤20 min of it is taken, but `CreateBlockContext` carries only
    `startHour` (no minutes), so the popup opens at the top of the hour and can produce an
    overlapping block. Teaching the context minutes touches `AddNewSlotBlock` +
    `CreateBlockViewModel`. Deleting a `confirmed` block also has no confirmation step.
12. **Swift 6 language mode**: the project builds in Swift 5 mode with `minimal` concurrency
    checking. `AddNewSlotBlock` still constructs a `@MainActor` view model from its nonisolated
    `init` — legal today, an error under Swift 6 until `View` conformance carries main-actor
    isolation. Don't paper over it with per-`init` `@MainActor`. (`ScheduleView` no longer belongs
    on this list: since PR11 its view model is built in `MasterRootView.body`, which *is*
    main-actor isolated.) The same migration is where the deliberately-declined
    `FakeServiceRepository` race below should be revisited.
13. **A failed read is indistinguishable from empty data** (found in PR10 review, deliberately
    deferred): `observeServices()`/`observeBlocks()` swallow listener errors and yield `?? []`, so
    a permissions failure or a dropped connection renders as a confident "Поки що немає послуг" /
    an empty timeline. PR10 added a `hasLoaded` spinner, which fixes the flash-before-first-
    snapshot case but not this one. The real fix is the `AsyncThrowingStream` switch that
    `data-layer.md` already names as the intended escalation path; it touches both repository
    protocols, both Firestore implementations, the fakes, and both view models.
14. **Service names don't follow the device language** (raised during PR11 planning, deliberately
    out of its scope): `Service.name` is master-entered *data*, stored as one `String`, so a client
    on an English device sees whatever the master typed. Only the chrome around it localizes —
    field labels, buttons, the placeholder, and the price/decimal-separator formatting. Making
    names multilingual means turning `name` into a per-language map (e.g. `[String: String]` keyed
    by language code) plus a resolver that falls back to the salon's default language when the
    device's is missing, and it touches the model, the add/edit form (a field per language), the
    services list, the create-slot checklist, and every client-facing screen that prints a service
    name. Not scoped for the MVP — one salon, one master, who knows what language their clients
    speak — so treat this as a decision to revisit only if the salon actually serves two languages.

## Housekeeping

- Commit + push `feature/pr3/root-routing`, open PR, once the tab bar + first cabinet screen make
  it a coherent reviewable chunk (or sooner, at your discretion).
- **Three throwaway feature docs must be deleted once PR11 is merged**, per `CLAUDE.md`:
  `docs/superpowers/plans/2026-08-07-master-my-services-list.md` (PR10),
  `docs/superpowers/specs/2026-08-07-master-add-service-design.md` and
  `docs/superpowers/plans/2026-08-07-master-add-service.md` (PR11). Everything they carry that
  outlives the branch is already folded into this file.
- **Currency is settled: `PLN`.** The design mockup showed грн, but the salon works in the Polish
  time zone; `ServiceFormat.currencyCode` stays `"PLN"`. Decided 2026-08-07, before PR11 put a
  price field in front of the user — don't reopen without a product reason.
- **Three PR9 review findings were reviewed and declined** — don't re-raise them: popup buttons'
  44pt tap target (modifiers sit outside the `Button`), `PopupContainer`'s bare `Rectangle()`
  backdrop in dark mode, and `BlockDetailPopup`'s default `FirestoreBlockRepository()` reaching
  live Firestore from `ScheduleView`'s preview.
- **Two PR11 review findings were reviewed and declined** — don't re-raise them:
  - `swiftui-pro`: `.accessibilityAddTraits(.isHeader)` on the add-service popup title.
  - `swift-concurrency-pro`: `FakeServiceRepository` has a genuine race — the synchronous
    `observeServices()` runs on the caller (MainActor in previews) while the nonisolated `async`
    mutations hop to the generic executor — plus continuations that are never cleaned up, because
    `onTermination` was deliberately left out to avoid mutating the dictionary off-actor. An
    `OSAllocatedUnfairLock` fix was written and verified to compile warning-free under
    `-strict-concurrency=complete`, then declined: this is `#if DEBUG` preview scaffolding. Revisit
    with the Swift 6 migration (step 12), not before.
- **Two stashes are outstanding** (`git stash list`):
  - `stash@{0}` — the full first cut of PR8 (proportional timeline, block detail popup + delete,
    `UserRepository`, popup scaffold components, 13 localization keys). PR8 and PR9 between them
    re-implemented everything in it from a clean tree **except the `UserRepository` trio**, which is
    the only reason it's still around — the Requests screen (step 4) needs it for client names.
    Take those three files then, and drop the stash; popping it wholesale **will** conflict across
    `ScheduleView`/`ScheduleViewModel`/`HourlyTimelineView`/`MasterRootView`/`ScheduleMetrics`.
  - `stash@{1}` — the older PR5 stash (it shifted down from `stash@{0}` when the PR8 stash was
    pushed). Largely superseded by PR8; review, then drop.
