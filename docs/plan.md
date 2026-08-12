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
  collection — no CRUD screen yet (screen 1 below, since done), so services are hand-seeded via Firebase
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
  - Accessibility scorecard for the accessibility-debt item in the backlog below: nothing was paid off. `ScheduleBlockCard` briefly
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

- **PR12 — Master «Мої послуги»: редагування, активність, видалення (branch
  `feature/pr-12-editAndDeleteService`)**: CRUD послуг закритий. Тап по рядку відкриває ту саму
  форму в режимі редагування, зірочка стала перемикачем «пропонувати при створенні слота», свайп
  вліво видаляє. Дата-шар не змінювався — `update`/`delete` існують із PR1.
  - **Зірочка з декоративної стала функціональною**, тобто PR вийшов ширшим за початкове «edit +
    delete». `Service` отримав `isActive: Bool?` + обчислювану `isOffered`. Поле **мусить** бути
    опціональним: синтезований `init(from:)` не використовує дефолтне значення властивості, тож із
    `var isActive = true` відсутній ключ дав би `keyNotFound`, і всі документи, створені до PR12,
    перестали б декодуватись. Форма створення пише `isActive: true` явно, тож на `?? true`
    покладаються лише легасі-документи; решта коду читає `isOffered`, ніколи `isActive`.
  - **Дезактивація не чіпає вже створені блоки** — послуга зникає лише з чекліста нових слотів.
    Узгоджено з рішенням для видалення (id йдуть у дангл, покриває `schedule.service.unknown`);
    дезактивація м'якша за видалення, тож діяти агресивніше не має права. Технічно це **друга,
    похідна** властивість `ScheduleViewModel.offeredServices` — фільтрувати наявний `services`
    не можна, він паралельно резолвить назви для вже створених блоків (`ScheduleViewModel:114,121`),
    і відфільтрований масив зробив би дезактивовану послугу «невідомою».
  - **Видалення без підтвердження** — свідома зміна рішення (початково планувався confirmation
    step): свайп плюс тап по кошику вже два навмисні жести. Alert лишився тільки на **невдале**
    видалення. Undo не будували.
  - `Master/Services/AddService/` → `ServiceForm/`: `ServiceFormMode` (`enum .add / .edit(Service)`,
    `Identifiable`, несе `titleKey`/`submitKey`), `ServiceFormPopup`, `ServiceFormViewModel`.
    Різниця між додаванням і редагуванням звелась до двох звернень до `mode` — другого екрана не
    знадобилось. У гілці `.edit` **обов'язково** передається `isActive: service.isOffered`:
    `update` перезаписує документ цілком, і пропущене поле мовчки скинуло б перемикач.
  - `MyServicesView` перейшла з `.fullScreenCover(isPresented:)` на `.fullScreenCover(item:)` з
    `ServiceFormMode?` — окремий enum-обгортка на кшталт `SchedulePopup` не потрібен, попап один і
    режим сам є ідентичністю. Рядок обгорнуто в `SwipeToDelete` (`openRowId` у `@State`, за зразком
    `openBlockId`), тап рядка — `onTapGesture`, не `Button` (прецедент PR9 із червоною підкладкою).
  - **Ціна переведена з `Double` на `Int`**, клавіатура з `.decimalPad` на `.numberPad`. Разом із
    цим зникли `priceStyle`/локале-залежний парсинг (`.numberPad` фізично не має клавіші
    роздільника) і `ServiceFormat` перейшов на `.fractionLength(0)`. Це не косметика: `Double` для
    грошей накопичує похибку при сумуванні, а крок «Статистика» рахує місячну виручку. **Міграція
    даних:** документи, записані PR11, містять `price` як double; ціле значення (`800.0`)
    декодується в `Int` нормально, дробове (`450.5`) — ні, і ламає весь список. Перед запуском
    звірити колекцію в Console.
  - `firestore.rules` **змінено вперше з PR1**: додано `hasValidServiceFormat()` (`name` —
    непорожній рядок, `price` — невідʼємний `int`), а `write` розщеплено на `create, update` /
    `delete`. Розщеплення обов'язкове: при видаленні `request.resource` дорівнює `null`, тож
    спільне `allow write: if isMaster() && hasValidServiceFormat()` зламало б свайп-видалення.
  - Локалізація: `services.add.*` → `services.form.*` для спільних полів форми (у режимі
    редагування ключ зі словом «add» бреше), плюс `services.edit.title`, `services.edit.submit`,
    `services.alert.updateFailed`, `services.alert.deleteFailed`.
  - **Рев'ю `swiftui-pro`** — три знахідки, усі виправлені: тап по вже зсунутому свайпом рядку
    відкривав форму замість закрити свайп (`guard openRowId == nil`); `parsePrice`/`formatPrice`
    мали різні формат-стилі (питання зняте переходом на `Int`); `.alert(item:)`, що повертає
    `Alert`, задепрекейчений з iOS 15 — замінено на `.alert(_:isPresented:)`.
  - **Рев'ю `swift-concurrency-pro`** — дві знахідки виправлені. `Task {}` у трьох попапах
    (`ServiceFormPopup`, `AddNewSlotBlock`, `BlockActionButton`) викликав **синхронне**
    `dismiss()`/`onSuccess()` після `await`: `Task` успадковує ізоляцію статично, за обгортаючим
    оголошенням, тож із нонізольованого методу `View` замикання йде на глобальний виконавець і
    мутує `@State` поза головним потоком. Виправлено як `Task { @MainActor in }` — анотація на самі
    методи тягла б каскад угору по `actions(dismiss:)`. Другa: `submit()` отримав
    `guard isSaving == false` — прапорець ставиться асинхронно, тож між тапом і його встановленням
    кнопка ще активна, і подвійний тап міг створити дубль послуги.
  - `AuthView:85` і `ScheduleViewModel:52,65` перевірені й не потребували фікса — перший робить
    `await onAuthenticated()` (асинхронний виклик сам стрибає на потрібний актор), другі живуть
    усередині `@MainActor`-класу.

- **PR13 — Client «Запис» (Booking, branch `feature/pr-13-clientBooking`, 5 задач)**: перший
  клієнтський екран, що читає реальні `available`-блоки й пропонує послуги. Дата-шар лишився
  read-only — жодного запису в PR13 (немає `clientId`, немає бронювання; вибір дати — порожній
  екран-заглушка до наступного зрізу).
  - **Задача 1 — доменний шар**: `Models/Block+StartDate.swift` (`startsAt: Date?`),
    `Client/Booking/BookingSlot.swift`, `ServiceOffer.swift`, `BookingAvailability.swift`
    (`offers(blocks:services:now:)` — фільтр `available` + майбутній час + непорожні
    `offeredServiceIds`, сортування хронологічно потім за назвою; тайбрейкер по `id` при однаковому
    старті, як у `ScheduleViewModel.chronologically`). `DateFormat` отримав `dateTime` (storage) та
    `dayMonth`/`dayMonthShort` (display). Тут уперше в застосунку зʼявилось поняття «минуле» —
    код майстра його ніде не фільтрує.
  - **Задача 2 — фікстури прев'ю**: `Client/Booking/Preview/BookingPreviewData.swift`. Прийняте
    відхилення від `code-style.md` (людина підтвердила 2026-08-11): літеральні масиви
    `Service(...)`/`block(...)` лишились компактними — табличний вигляд читається краще, файл суто
    `#if DEBUG`, і `ServicesPreviewData.swift` уже змішує обидва стилі. Не зафіксовано окремим
    пунктом у `code-style.md` — якщо конвенція знову спливе поза прев'ю-фікстурами, розглянути
    формальний запис винятку.
  - **Задача 3 — картки списку**: `Assets.xcassets/FreeSlot.colorset` (display-p3,
    `localizable: true` — нормалізовано під сиблінгів, план-файл мав застарілий JSON),
    `Client/Booking/BookingMetrics.swift`, `Components/BookingHeader.swift`,
    `Components/ServiceOfferCard.swift`. Картка несе **до трьох чіпів годин** найближчого дня
    (`Components/SlotChip.swift`, `ServiceOffer.nearestDaySlots`), як у макеті — підпис показує саму
    дату, а час перейшов у чіпи. Чіпи всередині того самого `NavigationLink`, що й уся картка, тож
    тап по годині веде туди ж, куди тап по картці; окремого призначення для години немає, бо його
    нема куди вести до появи екрана підтвердження.
  - **Задача 4 — екран + view model**: `BookingViewModel` (`@MainActor @Observable`,
    `observeBlocks()`/`observeServices()`/`refreshAvailability()` — 60-секундний тик,
    навмисно без `clientId`, бо PR13 нічого не пише; `nearestSlot` береться з уже порахованих
    `offers`, а не окремим слабшим фільтром — інакше пілюля в шапці могла показувати вікно над
    порожнім списком, бо видалення послуги не чистить `offeredServiceIds`), `BookingView` (власний
    `NavigationStack`, ховає нав-бар сам).
  - **Задача 5 — роутер**: `Client/ClientRootView.swift` переписано — таб «Запис» показує
    `BookingView(viewModel: BookingViewModel(), clientName: profile.name)` замість заглушки; кнопка
    виходу переїхала в таб «Акаунт» (як і раніше — простий `Text(name)` + `Text(email)` + кнопка,
    повноцінний екран лишається кроком 6 черги нижче). Таб «Мої записи» лишається заглушкою.
    Тимчасове прев'ю `BookingAvailability`'s `#Preview("Availability")` (задача 2, крок 2) видалено
    в межах задачі 5, оскільки жодна наступна задача не мала б це зробити.
  - Локалізація: 8 нових ключів (`booking.greeting`, `booking.title`, `booking.nearestWindow`,
    `booking.card.nearest`, `booking.section.services`, `booking.empty.title`,
    `booking.empty.message`, `booking.dates.title`) — усі `en`+`uk`, `translated`; плюс переюзані
    `client.placeholder.title`/`common.action.signOut`/`tabBar.tab.*`.
    Каталог перевпорядковано за абеткою — задачі 3-4 вставили `booking.*` перед `auth.*`, а Xcode
    пересортовує файл при першому ж збереженні й дав би ~130 рядків шумного дифу в чужому PR.
  - **Спроба «екран годин» була зроблена й відкочена** (2026-08-11, рішення людини). Задача 6
    додавала `BookingDay`/`SlotChip`/`BookingConfirmView` + `BookingAvailability.days(in:)`, і
    `BookingDatesView` показував секції днів із сіткою чіпів годин. Відкочено повністю. Причина
    відкоту не в коді — він пройшов рев'ю; це рішення не роздувати PR13 і робити цей екран одразу
    з календарем, як у дизайні, а не списком днів, який довелося б викидати. Даних для нього
    вистачає без моків: `ServiceOffer.slots` уже несе **всі** майбутні слоти послуги.

## Screens (in order)

This is the actual work queue, and the only numbered list here. The ordering follows the **data
chain**, not the mockup order: real services make real slots possible, real slots make a client
booking possible, and a client booking is the only thing that creates a `pending` block — which is
what "Заявки" lists and what "Статистика" counts. Building either master screen before that link
exists means inventing fake data for it twice.

Everything that is *not* a screen lives in "Backlog and tech debt" below, deliberately unnumbered —
those items are referred to by name, so the list can grow without renumbering anything.

1. ~~**Master — "Мої послуги" (services CRUD)**~~ — **done** (PR10 + PR11 + PR12, усі три під
   "Done" вище). Deliberately split off from "Статистика" (which the
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
   - ~~**PR12 — edit + delete**~~ — **done**, see the PR12 entry under "Done" above. Two departures
     from what was planned here: deletion ships **without** a confirmation step, and the mockup's
     per-row "Змінити" link was still not built — editing is entered by tapping the row instead,
     while the row's star became a real activity toggle (a scope addition, not a substitution).
2. ~~**Client — "Запис" (Booking)**~~ (mockup screen 03) — **partially done** (PR13, see the PR13
   entry under "Done" above): service list wired to real `available` blocks, plus a placeholder
   "Оберіть дату" screen behind the chevron. What's left is the whole second half: the **month
   calendar** with green-underlined available dates, the hour grid under it, the footer with the
   chosen service, and actually writing the `pending` block. Build the calendar and the hours in one
   slice — an hours-only version was written and reverted precisely because a day list without the
   calendar is code you throw away. Still gates screens 4 and 5.
3. **Client — "Мої записи" (My bookings)**: list of own pending/confirmed blocks, cancel action.
   Thin follow-on to screen 2 — same repository, same models.
4. **Master — "Заявки" (Requests)**: list of `pending` blocks with confirm/decline, reusing
   `BlockDetailPopup` as the detail surface (PR9 shipped the detail half). By now screens 2–3 supply
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
   послуги" from screen 1 replacing PR10's temporary text link. Last of the data-chain screens because the numbers
   derive from real `confirmed`/cancelled blocks, which only exist once the booking chain above
   works.
6. **Client — "Акаунт" (Account)**: behind the 3rd client tab (`ClientTab.account`) — PR13 moved
   sign-out here (name + email + sign-out button, same minimal content the booking-tab placeholder
   used to show) so the account still has an exit once "Запис" became a real screen, but it's not a
   real screen yet — still needs actual profile-management content.

## Backlog and tech debt (unordered)

Not a queue. These accumulate as they're found and get picked up when they block a screen, or when
something nearby is already being touched. **No numbers on purpose** — cite them by name, since
numbering drifts every time an item is added or closed (it already did once: PR9's entry pointed at
"step 9" for what was item 10).

- **Extract the screen header and the list status overlay into `Assets/UICommons/`** — agreed after
  PR13's final review to ship as its own small refactor PR, so PR13 stays purely client-side. The
  back-button header now exists in **two** copies (`MyServicesView`, `BookingDatesView`) — the
  reverted hours slice briefly made it three, and the next one will too — identical modifier for
  modifier, and the `ProgressView` /
  `ContentUnavailableView` status overlay in two (`MyServicesView`, `BookingView`). Both are
  domain-free, so unlike `BlockStatusPill` there's no "does UICommons get to know about the domain"
  question. Target: `ScreenHeader(titleKey:onBack:)` and `ListStatusOverlay(hasLoaded:titleKey:messageKey:)`,
  each with file-scope private constants; then delete `backIcon`/`backTapTarget` from both
  `BookingMetrics` and `ServicesMetrics` (they hold the same 26/44 twice).
- **PR13 leftovers from the final whole-branch review** — all Minor, none blocking:
  - `BookingPreviewData.clientId` is dead (PR13 writes nothing); the confirm-popup slice re-adds it.
  - `ServiceOffer.id`'s `service.id ?? service.name` fallback is unreachable —
    `BookingAvailability.offer(for:among:)` already guards `service.id != nil`. Harmless, but it
    hides the invariant.
  - The past filter is up to 60 s stale (`now` is re-read on the tick, not per render). Harmless
    while read-only; once booking writes exist, guard at the call rather than ticking faster.
  - `docs/superpowers/specs/2026-08-08-client-booking-design.md` still describes time chips on the
    service card and says the round chevron "у PR13 її немає" — both superseded by what shipped.
    That spec survives until the booking feature fully lands, so reconcile it before the next slice
    reads it.
- **View models are rebuilt on every tab switch** in both routers — `MasterRootView.swift:14` and
  `ClientRootView.swift:14` construct them inside `body`, and the `switch` gives each tab its own
  view identity, so leaving and returning tears down the Firestore listeners and re-registers them:
  a full re-read plus a spinner flash per visit. Pre-existing pattern, but «Запис» is the client's
  default tab, so it's now user-facing. Fix means hoisting the view models above the `switch` in
  both routers.
- ~~**Deploy `firestore.rules`**~~ — **done (2026-08-08, after PR12)**: the file was edited by PR12
  (`hasValidServiceFormat()`, and `services`' `write` split into `create, update` / `delete`) and
  published to the Console for project `manik-5a2b8`. Deployment stays manual — Console
  copy-paste, no CLI/CI hookup — so re-verify after any future edit to the file.
  - The `price` audit that came with it is **also done**: the `services` collection holds a single
    document, written by a post-PR12 build (it already carries `isActive`), with `price: 1000` —
    whole, so it decodes into `Int` cleanly. No fractional prices exist to migrate. Note this also
    means the "legacy document without `isActive`" case has no instance in the live database; the
    optional stays anyway, since a hand-made Console document would recreate it for free.
- **"Забули пароль?"**: decide tappable-stub vs. real `sendPasswordReset` flow, then implement.
  (Was tracked as a task in a now-disconnected MCP tool — re-track here instead.)
- **Dark mode makes typed text invisible** (found on a real device after PR12): entering a date,
  a time, a service name or a price shows white glyphs on a light field. Reproduces only in dark
  mode — the simulator and the previews default to light, which is why it survived this long.
  Deliberately parked until the screens are done, per an explicit call on 2026-08-08.
  - Cause, and it is app-wide rather than specific to those fields: **every colorset in
    `Assets.xcassets` has a single appearance** (`Background`, `Ink`, `FieldBackground`,
    `Surface`, `TextSecondary`, `Badge`, `Destructive`, all three `Status*`). The palette never
    flips. But `TextField` and `DatePicker` set no foreground colour of their own, so they fall
    back to `Color.primary`, which *does* flip — white text lands on a permanently light field.
    Labels around them are fine precisely because they say `.foregroundStyle(Color.ink)`
    explicitly. Nothing in the app calls `preferredColorScheme`.
  - Three ways out, and they are not equivalent. (a) Pin the app to light —
    `.preferredColorScheme(.light)` on the root — one line, honest about a palette that has no
    dark half, and instantly consistent. (b) Give every `TextField`/`DatePicker` an explicit
    `.foregroundStyle(Color.ink)` — fixes the symptom, leaves the next system-coloured control to
    rediscover the bug. (c) Add real dark variants to all eleven colorsets — the only true fix,
    and a design task, not a code one.
  - Recommendation is (a) now and (c) whenever dark mode becomes a product decision; (b) is the
    one to avoid, since it spreads the workaround instead of naming the cause.
  - Related, and now confirmed rather than hypothetical: a PR9 review finding about
    `PopupContainer`'s bare `Rectangle()` backdrop in dark mode was reviewed and declined at the
    time (see Housekeeping). Same root cause — fold it into whichever option is taken.
- **Live badge counter on "Заявки"**: `CustomTabBar`'s badge parameter currently always returns
  `nil` (`Master/MasterRootView.swift`, `CabinetKind.master`'s `badge` closure). Once the
  "Заявки" screen (screen 4) exists, wire this to a live count of `pending`-status blocks
  from `BlockRepository`, likely via an `AsyncStream` observation similar to `observeBlocks()`.
- **Accessibility debt (found in PR8 review, deliberately not fixed there)**:
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
  - PR12 added one more: the star toggle in `ServiceRow` is a `Button` with no `accessibilityLabel`
    or `accessibilityValue`, and the row's `onTapGesture` carries no `.isButton` trait. Both were
    explicitly cut from PR12's scope, not overlooked.
- **Slot creation can overlap an existing block**: since PR8 an hour still offers
  "+ Додати вільний час" while ≤20 min of it is taken, but `CreateBlockContext` carries only
  `startHour` (no minutes), so the popup opens at the top of the hour and can produce an
  overlapping block. Teaching the context minutes touches `AddNewSlotBlock` +
  `CreateBlockViewModel`. Deleting a `confirmed` block also has no confirmation step.
- **`CreateBlockViewModel.submit()` can double-submit** (found in PR12's concurrency review,
  deliberately left out of that PR's scope): it does `guard canSubmit` then `isSaving = true`,
  but `isSaving` is only set once the `Task` reaches the main actor, so the button is still
  enabled in between and a fast double tap can create two identical blocks. The fix is the same
  one-liner PR12 applied to `ServiceFormViewModel` — `guard isSaving == false else { return false }`
  at the top, which is atomic because the method is `@MainActor` and has no `await` before the
  assignment.
- **Swift 6 language mode**: the project builds in Swift 5 mode with `minimal` concurrency
  checking. `AddNewSlotBlock` still constructs a `@MainActor` view model from its nonisolated
  `init` — legal today, an error under Swift 6 until `View` conformance carries main-actor
  isolation. Don't paper over it with per-`init` `@MainActor`. (`ScheduleView` no longer belongs
  on this list: since PR11 its view model is built in `MasterRootView.body`, which *is*
  main-actor isolated.) The same migration is where the deliberately-declined
  `FakeServiceRepository` race below should be revisited.
  - PR12 patched a symptom of the same root cause: helper methods on `View` structs are
    nonisolated, so a `Task {}` created inside one does **not** inherit `MainActor` and any
    synchronous UI call after an `await` runs off the main thread. Three popups were fixed with
    `Task { @MainActor in }` (`ServiceFormPopup`, `AddNewSlotBlock`, `BlockActionButton`). Under
    Swift 6.2's default main-actor isolation the annotation becomes redundant — drop it then
    rather than sprinkling more of it now.
- **A failed read is indistinguishable from empty data** (found in PR10 review, deliberately
  deferred): `observeServices()`/`observeBlocks()` swallow listener errors and yield `?? []`, so
  a permissions failure or a dropped connection renders as a confident "Поки що немає послуг" /
  an empty timeline. PR10 added a `hasLoaded` spinner, which fixes the flash-before-first-
  snapshot case but not this one. The real fix is the `AsyncThrowingStream` switch that
  `data-layer.md` already names as the intended escalation path; it touches both repository
  protocols, both Firestore implementations, the fakes, and both view models.
- **Service names don't follow the device language** (raised during PR11 planning, deliberately
  out of its scope): `Service.name` is master-entered *data*, stored as one `String`, so a client
  on an English device sees whatever the master typed. Only the chrome around it localizes —
  field labels, buttons and the placeholder. Making names multilingual means turning `name` into a
  per-language map (e.g. `[String: String]` keyed by language code) plus a resolver that falls back
  to the salon's default language when the device's is missing, and it touches the model, the
  add/edit form (a field per language), the services list, the create-slot checklist, and every
  client-facing screen that prints a service name. Not scoped for the MVP — one salon, one master,
  who knows what language their clients speak — so treat this as a decision to revisit only if the
  salon actually serves two languages.

## Housekeeping

- Commit + push `feature/pr3/root-routing`, open PR, once the tab bar + first cabinet screen make
  it a coherent reviewable chunk (or sooner, at your discretion).
- **Throwaway feature docs are cleaned up**: the PR10 plan, both PR11 artifacts and both PR12
  artifacts (spec + plan) were deleted, per `CLAUDE.md`; everything from them that outlives a
  branch is folded into this file. `docs/superpowers/` now holds only the permanent MVP spec.
- **Currency is settled: `PLN`, whole units only.** The design mockup showed грн, but the salon
  works in the Polish time zone; `ServiceFormat.currencyCode` stays `"PLN"`. Decided 2026-08-07,
  before PR11 put a price field in front of the user — don't reopen without a product reason. PR12
  additionally settled the *type*: `Service.price` is `Int`, formatted with `.fractionLength(0)`,
  and the form uses `.numberPad`. Groszy are not representable by design; if the salon ever needs
  them, switch to minor units (`Int` groszy), not back to `Double`.
- **Three PR9 review findings were reviewed and declined** — don't re-raise them: popup buttons'
  44pt tap target (modifiers sit outside the `Button`), `PopupContainer`'s bare `Rectangle()`
  backdrop in dark mode, and `BlockDetailPopup`'s default `FirestoreBlockRepository()` reaching
  live Firestore from `ScheduleView`'s preview. **The dark-mode one has since been reopened** —
  device testing after PR12 showed the same root cause makes typed text invisible — see the dark-mode item in the backlog.
- **Two PR11 review findings were reviewed and declined** — don't re-raise them:
  - `swiftui-pro`: `.accessibilityAddTraits(.isHeader)` on the add-service popup title.
  - `swift-concurrency-pro`: `FakeServiceRepository` has a genuine race — the synchronous
    `observeServices()` runs on the caller (MainActor in previews) while the nonisolated `async`
    mutations hop to the generic executor — plus continuations that are never cleaned up, because
    `onTermination` was deliberately left out to avoid mutating the dictionary off-actor. An
    `OSAllocatedUnfairLock` fix was written and verified to compile warning-free under
    `-strict-concurrency=complete`, then declined: this is `#if DEBUG` preview scaffolding. Revisit
    with the Swift 6 language mode item in the backlog, not before. PR12 leans on the fake harder (previews now
    exercise `update`/`delete` too) — the decision still stands, but that's why it's worth
    revisiting rather than forgetting.
- **Three PR12 findings were reviewed and declined** — don't re-raise them:
  - `swiftui-pro`: splitting `MyServicesView`'s `some View` computed properties into separate
    `View` structs. Already reviewed and declined in PR10; the skill raises it every time.
  - `swiftui-pro`: dropping the explicit `Button("common.action.ok", role: .cancel) {}` from the
    services alert. SwiftUI supplies a localized dismiss button for an empty `actions` closure, but
    `ScheduleView` spells it out — remove it in both places in one pass or not at all.
  - `swift-concurrency-pro`: an in-flight guard on `MyServicesViewModel.toggleActive`. Both taps
    capture the same `Service` value and compute the same new `isActive`, so the second write is
    redundant rather than a flip-back — no data corruption, and an `isToggling` flag would add more
    state than it removes.
- **Two stashes are outstanding** (`git stash list`):
  - `stash@{0}` — the full first cut of PR8 (proportional timeline, block detail popup + delete,
    `UserRepository`, popup scaffold components, 13 localization keys). PR8 and PR9 between them
    re-implemented everything in it from a clean tree **except the `UserRepository` trio**, which is
    the only reason it's still around — the Requests screen (screen 4) needs it for client names.
    Take those three files then, and drop the stash; popping it wholesale **will** conflict across
    `ScheduleView`/`ScheduleViewModel`/`HourlyTimelineView`/`MasterRootView`/`ScheduleMetrics`.
  - `stash@{1}` — the older PR5 stash (it shifted down from `stash@{0}` when the PR8 stash was
    pushed). Largely superseded by PR8; review, then drop.
