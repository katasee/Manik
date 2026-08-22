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
  - **Задача 1 — доменний шар**: `Models/Block/Block+StartDate.swift` (`startsAt: Date?`),
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
    дату, а час перейшов у чіпи.
    **Картка навмисно не загорнута в `NavigationLink` цілком.** Тригерів два й вони різні: чіп веде
    на `BookingConfirmView` тієї конкретної години, кругла кнопка «›» — на `BookingDatesView` з
    усіма датами. Спершу було зроблено навпаки — картка цілком була лінком, а чіпи просто
    малювались, — але тоді чіп не міг стати кнопкою: вкладений `NavigationLink` у SwiftUI не працює
    передбачувано (внутрішній або не отримує тапів, або спрацьовують обидва). Тіло картки (назва,
    ціна, підпис дати) тепер не натискне — так само, як у макеті, де афорданс це кнопка «›».
    Іконочна кнопка отримала `accessibilityLabel` (`booking.card.allDates`), бо для VoiceOver вона
    інакше німа.
  - **Задача 4 — екран + view model**: `BookingViewModel` (`@MainActor @Observable`,
    `observeBlocks()`/`observeServices()`/`refreshAvailability()` — 60-секундний тик,
    навмисно без `clientId`, бо PR13 нічого не пише; `nearestSlot` береться з уже порахованих
    `offers`, а не окремим слабшим фільтром — інакше пілюля в шапці могла показувати вікно над
    порожнім списком, бо видалення послуги не чистить `offeredServiceIds`), `BookingView` (власний
    `NavigationStack`, ховає нав-бар сам, реєструє два призначення — `ServiceOffer` →
    `Dates/BookingDatesView`, `BookingSlot` → `Confirm/BookingConfirmView`; обидва екрани поки
    порожні, лише заголовок і «назад»).
    `BookingView` приймає `bottomClearance: CGFloat` і кладе його нижнім відступом контенту
    `ScrollView`. Це не косметика: `ClientRootView` резервує місце під таб бар через
    `.safeAreaInset(edge: .bottom)`, і для `MyServicesView` цього досить, а для `BookingView` ні —
    він єдиний екран із власним `NavigationStack`, а стек розширюється в безпечну зону, тож інсет
    із роутера до `ScrollView` не доходить і остання картка лишалась підрізаною навіть у самому
    низу прокрутки. **Будь-який наступний екран із власним `NavigationStack` усередині таба матиме
    те саме**; якщо такий зʼявиться третім, це має стати спільним модифікатором, а не параметром.
  - **Задача 5 — роутер**: `Client/ClientRootView.swift` переписано — таб «Запис» показує
    `BookingView(viewModel: BookingViewModel(), clientName: profile.name)` замість заглушки; кнопка
    виходу переїхала в таб «Акаунт» (як і раніше — простий `Text(name)` + `Text(email)` + кнопка,
    повноцінний екран лишається кроком 6 черги нижче). Таб «Мої записи» лишається заглушкою.
    Тимчасове прев'ю `BookingAvailability`'s `#Preview("Availability")` (задача 2, крок 2) видалено
    в межах задачі 5, оскільки жодна наступна задача не мала б це зробити.
  - Локалізація: 10 нових ключів (`booking.greeting`, `booking.title`, `booking.nearestWindow`,
    `booking.card.nearest`, `booking.card.allDates`, `booking.section.services`,
    `booking.empty.title`, `booking.empty.message`, `booking.dates.title`, `booking.confirm.title`)
    — усі `en`+`uk`, `translated`; плюс переюзані
    `client.placeholder.title`/`common.action.back`/`common.action.signOut`/`tabBar.tab.*`.
    Каталог перевпорядковано за абеткою — задачі 3-4 вставили `booking.*` перед `auth.*`, а Xcode
    пересортовує файл при першому ж збереженні й дав би ~130 рядків шумного дифу в чужому PR.
  - **Прибирання по ходу PR**, усе за наслідками рев'ю або обговорення:
    - `ServiceOffer.id` став збереженим `let id: String` замість обчислюваного
      `service.id ?? service.name`. Фолбек був недосяжний — `offer(for:among:)` вище стоїть
      `guard let serviceId = service.id`, — і при цьому приховував інваріант. Тепер id приходить у
      конструктор уже розгорнутим, і з типу видно: якщо `ServiceOffer` існує, у нього є справжній id.
    - `DateFormat.dayMonth`/`dayMonthShort` перейшли з фіксованих патернів (`"d MMMM"`) на
      `setLocalizedDateFormatFromTemplate` (`"dMMMM"`). Фіксований патерн жорстко задає порядок:
      українською «12 серпня» правильно, англійською виходило «12 August» замість «August 12».
      Зʼявилась третя фабрика `templateFormatter(_:)`, і `clockTime` згорнувся в один рядок через
      неї. `monthYear` навмисно лишився `"LLLL y"` — `LLLL` це standalone форма, називний відмінок
      («Серпень 2026»); шаблон дав би родовий («серпня 2026»), що для заголовка місяця неправильно.
    - `Block.swift`, `Block+Minutes.swift`, `Block+StartDate.swift` переїхали в `Models/Block/`.
      `Service`/`UserProfile`/`WorkHours` лишились на верхньому рівні — теку типу заводимо тоді,
      коли в нього більше одного файлу.
  - **Була зроблена й відкочена спроба окремого «екрана годин»** (2026-08-11). Вона додавала
    `BookingDay` + `BookingAvailability.days(in:)`, і `BookingDatesView` показував секції днів із
    сіткою чіпів. Відкочено не через якість — код пройшов рев'ю, — а тому що список днів стоїть на
    місці календаря-місяця з дизайну і його довелося б викидати. `SlotChip` і `BookingConfirmView`
    з тієї спроби лишились, бо переживуть появу календаря. Даних на цей екран вистачає без моків:
    `ServiceOffer.slots` уже несе **всі** майбутні слоти послуги, а не лише найближчий.
    Єдиний справжній дефект, знайдений тоді, вартий запамʼятовування:
    `LazyVGrid(columns:spacing:alignment:)` **не компілюється** — SwiftUI оголошує `alignment`
    перед `spacing`, а Swift вимагає позначені аргументи в порядку оголошення.

- **PR14 — Client «Запис»: календар послуги (UI, branch `feature/pr-14-calendarAndBooking`,
  6 задач)**: `BookingDatesView` із заглушки став справжнім екраном — місячний календар доступних
  дат обраної послуги, ряд чипів годин обраного дня і футер вибору. Запису в Firestore досі немає й
  нових запитів теж: усе похідне від `ServiceOffer.slots`, які вже вичитав `BookingViewModel`.
  - **Задача 1 — спільний календар**: `DateFormat.salonCalendar` став internal і отримав
    `firstWeekday = 2`; `WeekDayStrip` викинув власну ідентичну копію. Сітка місяця була б третім
    споживачем — саме той момент, коли дубль виносять.
  - **Задача 2 — сітка як дані**: `Dates/BookingDay.swift`, `Dates/BookingMonth.swift` і
    `BookingAvailability.month(startingAt:for:now:)` — чиста побудова 6×7 без жодного SwiftUI.
    Доступні дати — `Set` з `offer.slots`, тож перевірка дня це хеш-лукап, а не пошук по масиву.
    `BookingDay.isSelectable` (`isAvailable && isPast == false`) — єдине місце, де живе правило
    «можна тапнути». Перевірялось тимчасовим текстовим `#Preview("Month")`, видаленим у задачі 6 —
    той самий прийом, що в PR13.
  - **Задача 3 — компоненти**: `Dates/Components/CalendarDayCell.swift` (темне коло для обраного,
    зелена риска `Color.freeSlot` для доступного, бліді дні сусідніх місяців),
    `Dates/Components/MonthHeader.swift` (стрілки місяців, ліва блідне на поточному місяці).
    `SlotChip` отримав `var isSelected = false` — саме `var`, бо memberwise-ініціалізатор тоді дає
    параметру дефолт і обидва наявні виклики лишились валідними без правок.
  - **Задача 4 — `Dates/Components/MonthGrid.swift`**: 7 колонок, шапка днів тижня з понеділка.
  - **Задача 5 — `Dates/BookingDatesViewModel.swift`** (`@MainActor @Observable`): тримає видимий
    місяць, обраний день і обрану годину. **Репозиторію тут навмисно немає** — усе похідне від
    `offer`, а `now` фіксується в `init`, бо за нього відповідає батьківський екран із 60-секундним
    тиком. `daySlots` — збережена похідна на `didSet` від `selectedDate` (як у `ScheduleViewModel`),
    а не фільтр у `body`; початкове значення присвоюється в `init` вручну, бо `didSet` під час
    ініціалізації не спрацьовує — без цього екран відкрився б без чипів.
  - **Задача 6 — складання**: `Dates/Components/ConfirmBar.swift` + переписаний
    `BookingDatesView`. Сигнатура змінилась на `BookingDatesView(viewModel:bottomClearance:)`, тож
    `BookingView` правився в тій же задачі. `init(viewModel:)` **без дефолту** — правило з
    PR10/PR11; тут репозиторію немає, але діє друга причина: view model `@MainActor`, а `init`
    в'юхи нонізольований, тож будувати його треба в головноакторному `BookingView.body`.
    `bottomClearance` — не косметика: `ClientRootView` малює `CustomTabBar` у `ZStack` над
    контентом, а цей екран пушиться в той самий `NavigationStack`, тож без відступу футер
    «Продовжити» опинявся б під баром.
  - Локалізація: 5 нових ключів (`booking.action.continue`, `booking.calendar.nextMonth`,
    `booking.calendar.noSlots`, `booking.calendar.pickTime`, `booking.calendar.previousMonth`) —
    усі `en`+`uk`, `translated`, вставлені за абеткою.
  - Кнопка «Продовжити» має **порожню дію** — це домовлений обсяг PR14. Попап підтвердження
    приходить у PR15 і змінить рівно цю одну точку.
  - **Після рев'ю (skill `swiftui-pro`)** доробки, які варто памʼятати:
    - `SlotChip` став пілюлею з обведенням (`Capsule().fill(...).stroke(...)`, iOS 17 chaining
      замість `background` + `overlay`). Причина не косметична: чип народився всередині
      `ServiceOfferCard` на `Color.surface` і читався контрастом до неї, а на цьому екрані лежить
      просто на `Color.background` — тобто був невидимий. Компонент, який переїжджає на інший фон,
      треба перевіряти на власну межу.
    - `bottomClearance` рахувався двічі: `safeAreaInset` додає висоту футера (в якій уже є
      clearance) **плюс** нижній padding контенту скролу. Лишився один — на футері.
    - Тап-таргет 44×44 у `MonthHeader` мусить бути **всередині** лейбла кнопки; `.frame` на самій
      `Button` збільшує лише її layout-рамку, а не зону натискання.
    - `MonthGrid` тримає `GridItem`-колонки одним `private static let` — інакше два `LazyVGrid`
      перебудовували б однаковий масив на кожен рендер. Ряд днів тижня свідомо йде по
      `indices, id: \.self`: українські символи «П В С Ч П С Н» містять дублікати, тож самі рядки
      унікальними ключами бути не можуть.
  - **Спроба, яку відкотили (`bebb9d9`)**: рев'ю запропонувало прибрати `GeometryReader`/`topInset`
    із `BookingView`/`BookingHeader` і залити шапку через `.background { … .ignoresSafeArea(edges:
    .top) }`. Усередині `ScrollView` це **не працює** — фон не розтягується під статус-бар, і шапка
    перестає бути суцільною. Не повторювати; `topInset` через `GeometryReader` тут лишається
    свідомим рішенням.
  - Найменування: футер називається `ConfirmBar`, а не `BookingFooterBar` — суфікс `Bar` уже
    каже, що це смуга, а `Booking` дублює теку. Тоді ж у `code-style.md` дописано, що **трейлінг-
    клоужер не рахується** в правилі «3+ аргументи — по рядку на аргумент»: рахуються лише
    аргументи в дужках, інакше довелося б розбивати кожен `VStack`/`ForEach` у застосунку.

- **PR15 — Client «Запис»: підтвердження і бронювання (branch `feature/pr-15-confirmBooking`,
  6 задач)**: клієнтка реально записується — блок стає `pending` у Firestore, і це **перший запис
  клієнта в застосунку**. PR15 і PR16 з черги нижче свідомо злиті в один: попап без запису був би
  декоративною заглушкою, а зріз має бути наскрізним.
  - **Доменні дрібниці**: `BookingSlot.startsAt: Date?` (дзеркалить `Block+StartDate`),
    `Confirm/BookingConfirmContext.swift` (`Identifiable`, **не** `Hashable` — у навігацію не йде,
    тож `Service` не довелось робити `Hashable` заради попапа), `Confirm/BookingFailure.swift`
    (enum із `messageKey`, за зразком `ServicesFailure` — сирий `error.localizedDescription`
    від Firestore англійський і технічний).
  - **`permissionDenied` → `BookingError.slotUnavailable`**: `firestore.rules` має
    `resource.data.status == "available"` в `isClientBooking()`, тож перехоплений слот сервер
    відбиває `permissionDenied` — це не мережева помилка, це «час зайняли». Мапінг живе
    **всередині** `FirestoreBlockRepository` (private `NSError.isSlotUnavailable`), бо шар
    протоколів не імпортує Firebase; `Services/Repositories/BookingError.swift` — доменний тип,
    який бачить view model. Самі правила **не змінювались**, передеплой не потрібен.
  - **`BookingConfirmViewModel`**: два guard-и (`Service.id`, `isUpcoming`), виклик репозиторію,
    три помилки, `isBooked`. `isUpcoming` читає `.now`, а **не** зафіксований `now` батька — список
    фільтрує минуле раз на 60 с, тож на момент тапу дані протухлі до хвилини. Це закриває пункт
    беклогу «past filter is up to 60 s stale». `guard isSaving == false` — той самий фікс, що PR12
    зробив `ServiceFormViewModel.submit()`.
  - **`BookingConfirmPopup` — один попап, два стани** (підтвердження → успіх: галочка, текст про
    очікування підтвердження, «Готово»), на наявному `PopupContainer`. Помилки **інлайн у попапі**,
    не алертом: алерт поверх попапа поверх `fullScreenCover` це три шари презентації.
    `.animation(_:value:)` обовʼязково **з `value:`** — контейнер анімує лише власну появу, без
    цього картка стрибком міняє висоту; тривалість 0.2 збігається з `PopupContainerLayout.fade`.
    `PopupContainer(onDismiss:)` отримує `exit`, а не `onDismiss`: після успіху **обидва** виходи
    (тап по фону і «Готово») мусять перемикати таб, інакше однаковий стан поводиться по-різному.
  - **Попап показується з двох екранів**: чіп години на картці списку відкриває його **напряму**
    (а не веде в календар), і кнопка «Продовжити» у `ConfirmBar`. Тому `ServiceOfferCard` отримав
    `onSelect: (BookingSlot) -> Void`, чіп із `NavigationLink` став `Button`, а
    `.navigationDestination(for: BookingSlot.self)` і заглушка `Confirm/BookingConfirmView.swift`
    (PR13) видалені. `NavigationLink(value: offer)` під карткою лишився — кнопка й лінк це різні
    контроли, вкладених лінків не зʼявилось.
  - **`BookingViewModel` став композиційним коренем** клієнтського таба: єдиний тримає `clientId`
    (з `profile.uid`, не з `AuthRepository`) і `BlockRepository`, роздає дочірні VM фабриками
    (`makeDatesViewModel(for:)`, `makeConfirmViewModel(context:)`), тож репозиторій не витікає у
    вʼюхи — прийом із `MyServicesViewModel.makeFormViewModel(for:)` (PR11). Дефолтні репозиторії
    дозволені **тільки тут**. `BookingDatesViewModel` теж отримав `clientId`/`blockRepository` і
    власну фабрику, бо попап відкривається і з календаря.
  - **Після «Готово» перемикається таб** на «Мої записи» (поки заглушка — усвідомлено: факт запису
    вже підтверджено попапом). Стек «Запису» попити не треба: роутер перебудовує вʼюху при зміні
    таба, тож `NavigationStack` скидається сам — PR15 **спирається** на пункт беклогу про
    перебудову view models, але не лікує його.
  - **`FakeBlockRepository` став мутабельним `final class`** (як `FakeServiceRepository` після
    PR11): стрім більше не завершується після першого `yield`, мутації транслюються підписникам, а
    `book` повторює серверне правило (`guard status == .available else throw .slotUnavailable`).
    Завдяки цьому прев'ю проганяє весь ланцюг без Firestore: тап по чіпу → попап → «Забронювати» →
    успіх → картка перебудувалась, слот зник із чипів. Друге прев'ю попапа віддає фейк **без
    блоків** і показує червоний рядок «час зайняли». Це заодно оживило `BookingPreviewData.clientId`
    (був мертвим із PR13).
  - `withoutPresentationAnimation` на обох показах/закриттях кавера — без нього системний слайд-ап
    бʼється з власним фейдом `PopupContainer`.
  - Локалізація: 7 нових ключів (`booking.action.book`, `booking.confirm.note`,
    `booking.error.expired`, `booking.error.generic`, `booking.error.slotTaken`,
    `booking.success.message`, `booking.success.title`) — `en`+`uk`, `translated`, за абеткою.
    Переюзано `booking.confirm.title` (тепер заголовок попапа, не екрана),
    `common.action.cancel`, `common.action.done`.
  - **Не в цьому PR**: скасування запису клієнткою і справжній екран «Мої записи».

- **PR17 — Client «Мої записи», read-only список (branch `feature/pr-17-myBookings`, 8 задач)**:
  таб «Мої записи» показує справжні записи клієнтки замість `client.placeholder.title`. Дата-шар не
  змінювався взагалі — `observeBlocks()` віддає всі блоки, фільтрація по `clientId` локальна, як у
  `BookingView`; `firestore.rules` не чіпались (`allow read: if isSignedIn()` на `blocks` уже є).
  - **Дві секції — «Майбутні» + «Минулі»**, минулі обрізані до `MyBookingsList.pastLimit = 5`.
    Порожня секція не рендериться зовсім (не заголовок над пусткою). Скасовані записи відпадають
    самі: скасування повертає блок у `available` і чистить `clientId`, тож фільтр
    `status != .available` покриває це без окремої логіки.
  - **Картка показує діапазон часу, а не тривалість** — `Service` не має поля тривалості з PR11
    (його видалили саме тому, що межі блоку і є тривалістю). Це заодно дало
    `Models/Block/Block+TimeRange.swift` (`timeRangeLabel`): рядок `"14:00 – 15:30"` уже був
    продубльований у `ScheduleBlockCard` і `BlockDetailPopup`, картка «Моїх записів» була б третьою
    копією. Тире — **en dash**, як в обох оригіналах.
  - **У минулих немає піла статусу** — секція вже і є статусом. Приглушення тримається на двох
    речах: піл не рендериться і акцентна смужка стає сірою напівпрозорою
    (`MyBookingsMetrics.Opacity.pastAccent`, застосована **лише** до смужки). `.opacity(0.5)` на всій
    картці опустив би `Color.textSecondary` на `Color.surface` до ~2:1 і зробив би рядок дати
    нечитним — текст навмисно лишається повноконтрастним.
  - **`BlockStatusPill` + `BlockStatusStyle` переїхали з `Master/Schedule/Components/` у
    `Assets/UICommons/`** (райдер із черги нижче) — це їхній другий кабінет-споживач. Піл отримав
    власний `private enum Layout` замість `ScheduleMetrics.StatusPill`, який видалено; ключі
    лишились із префіксом `schedule.status.*` — перейменування зачепило б каталог і три екрани
    майстра без користі. Окрему `Assets/DomainUI/` **не заводили** — двох компонентів замало.
  - **`schedule.service.unknown` → `common.service.unknown`**: запасна назва видаленої послуги тепер
    спільна для двох кабінетів (`ScheduleViewModel` і `MyBookingsList`).
  - `Client/MyBookings/`: `MyBooking` (презентаційна модель — без `clientId`/`bookedServiceId`/сирих
    дат, `priceLabel` опціональний, бо видалена послуга ціни не має), `MyBookingSection` (+`Kind`,
    **без** `LocalizedStringKey` — модель рівня даних не тягне SwiftUI, мапінг живе в
    `MyBookingSectionView`), `MyBookingsList` (чиста `sections(blocks:services:clientId:now:)`),
    `MyBookingsViewModel`, `MyBookingsView`, `MyBookingsMetrics`, `Components/`, `Preview/`.
  - **`hasLoaded` вимагає обох потоків** (`hasBlocks && hasServices`): після самих блоків блимало б
    «Записів ще немає», поки їдуть послуги; після самих послуг назви були б запасними.
    `refreshSections()` — 60-секундний тик за зразком `BookingViewModel.refreshAvailability()`, без
    нього запис не переїжджав би з «Майбутніх» у «Минулі», поки екран відкритий; `rebuild()` бере
    `.now` сам, а не збережений момент. `clientId` — **без дефолту**, репозиторії з дефолтами.
  - **Екран не бере `bottomClearance`** — він не володіє власним `NavigationStack` (переходити
    нікуди), тож `safeAreaInset` роутера доїжджає до скролу сам. Конвенція вимагає цей параметр
    лише для екрана з власним стеком, як `BookingView`.
  - `VStack`, не `LazyVStack`: ліні на рівні максимум двох секцій не буває, справжній список карток
    лежить у вкладеному стеку і будується однаково в обох випадках.
  - **`.accessibilityElement(children: .combine)` на картці свідомо не додано** — рев'ю це
    пропонувало, але `ServiceOfferCard.nearestLabel` уже той самий тришаровий `Text`, а схожу
    пропозицію відхилили ще в PR11. Додати «заодно» означало б розійтися з рештою застосунку.
  - Локалізація: 5 нових ключів (`myBookings.title`, `myBookings.section.upcoming`,
    `myBookings.section.past`, `myBookings.empty.title`, `myBookings.empty.message`) — `en`+`uk`,
    `translated`, за абеткою. Заголовки секцій у каталозі у звичайному регістрі, верхній робить
    `.textCase(.uppercase)` у в'юсі — локаль без регістру тоді нічого не ламає.
    `client.placeholder.title` видалено разом із мертвою властивістю `ClientRootView.placeholder`.
  - **Не в цьому PR**: скасування запису (PR18).

- **PR18 — Client скасування запису (branch `feature/pr-18-cancelBooking`, 5 із 6 задач плану)**: клієнтка
  скасовує майбутній запис із «Моїх записів», блок повертається в `available`. Дата-шар і
  `firestore.rules` **не змінювались взагалі** — `BlockRepository.cancel(blockId:)` існує з PR1,
  `isClientCanceling()` уже дозволяє рівно цю операцію. Цим закривається екран 3 повністю і
  замикається повний цикл клієнтки: запис → список → скасування.
  - **Афорданс — текстова кнопка в картці**, не свайп і не попап деталей. Свайп із кошиком у цьому
    застосунку означає «видалити» (`SwipeToDelete` у «Моїх послугах»), а тут дія інша; попап
    деталей вимагав би дзеркала майстерського `BlockDetailPopup` заради однієї дії.
  - **Підтвердження — попап на наявному `PopupContainer`, не `.alert`**: алерт малюється системним
    шрифтом і випадає з дизайн-системи, а помилку довелось би показувати другим алертом.
    `Client/MyBookings/Cancel/`: `CancelBookingContext` (id + три готові рядки), `CancelBookingPopup`,
    `CancelBookingViewModel`. VM видає фабрика `MyBookingsViewModel.makeCancelViewModel(context:)`,
    тож `BlockRepository` не витікає у в'юху — той самий прийом, що `makeConfirmViewModel` у PR15.
  - **Скасувати можна будь-який майбутній запис** — і `pending`, і `confirmed`, без часового вікна,
    і **без guard'а «час уже минув»** (на відміну від `BookingConfirmViewModel.book()`).
    Забронювати слот у минулому неправильно; скасувати запис, що почався хвилину тому — ні, і
    сервер це дозволяє. Клієнтського правила, якого немає в `firestore.rules`, не вигадуємо.
  - **Success-стану в попапі немає** — після успіху він просто фейдиться назад. PR15 показував
    галочку, бо новий `pending` було ніде не видно; тут картка зникає зі списку через realtime, і
    це саме́ й є підтвердженням.
  - **Помилка — інлайн у попапі, один кейс**: `hasFailed: Bool` + `myBookings.error.generic`, без
    enum на один варіант (як `BookingFailure` у PR15). Заведемо enum, якщо кейсів стане два.
  - **`MyBooking.cancelId: String?` гейтить кнопку** (`nil` для минулих і для блока без документного
    id) — одне опціональне поле кодує і «чи є кнопка», і «що саме скасовувати», як `priceLabel`
    поруч. У `CancelBookingContext` `id` уже **необов'язковий**: урок PR13 (`ServiceOffer.id`) —
    недосяжний фолбек ховає інваріант.
  - `priceRow` став `footerRow` (ціна ліворуч, «Скасувати» праворуч) і рендериться, лише якщо є
    бодай одне з двох. Тап-таргет `44` — через `.frame(minHeight:)` **всередині** лейбла кнопки, не
    на самій `Button` (урок PR14: рамка на кнопці збільшує layout, а не зону натискання).
  - **`PopupContainerLayout` перестав бути `private`**, обидва попапи беруть `.fade` звідти замість
    літерала `.easeOut(duration: 0.2)` — правився **і** `BookingConfirmPopup`, лишати дубль в
    одному з двох місць не можна (принцип, за яким PR12 відхилив вибіркове прибирання
    `Button("common.action.ok")`). Показ/закриття кавера — через `withoutPresentationAnimation`, як
    у PR15.
  - **`FailingBlockRepository` — окремий файл** у `Services/Fakes/`, а не хвіст
    `FakeBlockRepository.swift`: кожен метод кидає, і друге прев'ю попапа показує червоний рядок
    помилки без Firestore.
  - **`accessibilityLabel` на кнопці «Скасувати» свідомо не додано** — у списку було б кілька кнопок
    з ідентичним VoiceOver-лейблом. За прецедентом PR9/PR12/PR17 accessibility-борг ведеться
    списком у беклозі, а не гаситься попутно.
  - Локалізація: 5 нових ключів (`myBookings.action.cancel`, `myBookings.cancel.confirm`,
    `myBookings.cancel.note`, `myBookings.cancel.title`, `myBookings.error.generic`) — `en`+`uk`,
    `translated`, за абеткою. Переюзано `common.action.back`.
  - **Не в цьому PR**: борг «view models перебудовуються при перемиканні табів» був у плані
    задачею 6 (`@State` на `ClientRootView` + `.id(profile.uid)` у `RootView`), але **не
    реалізований**. Закрито пізніше, у PR19.

- **PR19 — Master «Заявки» (branch `feature/pr-19-masterRequests`, 6 задач)**: таб «Заявки» показує
  майбутні `pending`-блоки з іменем клієнтки й парою кнопок «Відхилити»/«Підтвердити». Цим
  замикається повний цикл обох кабінетів: клієнтка записалась → майстер підтвердив. `firestore.rules`
  **не змінювались і не передеплоювались** — `users` уже читається майстром
  (`allow read: if isMaster() || request.auth.uid == uid`), а `confirm`/`decline` існують у
  `BlockRepository` з PR1.
  - **Дії — дві кнопки прямо в картці, не тап у попап деталей.** Це свідоме скасування того, що
    планувалось у пункті екрана 4 нижче: `BlockDetailPopup` (PR9) у PR19 не змінювався взагалі.
    Причина — заявки це черга, де кожен рядок вимагає рішення; додатковий тап на кожну заявку це
    податок на основний сценарій. Переюзано не попап, а `BlockAction` + `BlockActionButton`, які
    вже несуть спінер, `disabled` і алерт підтвердження для «Відхилити».
  - **`BlockAction` + `BlockActionButton` переїхали в `Assets/UICommons/`** — той самий переїзд, що
    PR17 зробив для `BlockStatusPill`/`BlockStatusStyle`, коли з'явився другий кабінет-споживач.
    Наслідок: у `UICommons/` тепер **чотири** доменно-обізнані компоненти, тобто умова беклогу про
    `Assets/DomainUI/` настала (див. нижче).
    - **Це не був чистий переїзд** (початкова редакція цього запису казала «вміст не змінювався ні
      на рядок» — неправда, виправлено 2026-08-21). `BlockActionButton` отримав
      `enum BlockActionButtonStyle { case popup, card }` і параметр `style` з дефолтом `.popup`;
      `button` став `@ViewBuilder` зі `switch`, де гілка `.popup` — це колишній
      `PopupPrimaryButton` слово в слово, а `.card` — новий `CardActionButton`. `BlockAction`
      доріс двома властивостями суто для картки: `iconName` (SF Symbol) та `isPreferred`
      («цю дію пропонуємо за замовчуванням» → залита капсула проти обведеної).
    - Дефолт `.popup` — навмисний: єдиний наявний споживач `BlockDetailPopup.swift:49` не
      змінився жодним рядком і виглядає точно як до PR19. Тобто попап не переробляли, а **додали
      другий стиль поруч**.
    - `isPreferred` спершу звався `isAffirmative`, перейменований на прохання після рев'ю: назва
      описує намір, а не оформлення, і не конфліктує з наявним `PopupPrimaryButton`, де слово
      «primary» означає інше. Споживач і далі приймає його як `isProminent` — межа між
      «яку дію пропонуємо» (домен дії) і «намалюй акцентно» (оформлення) лишається явною, тому
      `CardActionButton` не знає нічого про записи.
  - **Минулі заявки ховаються.** Блок, що лишився `pending` після свого часу, зі списку зникає й
    лишається `pending` назавжди, видимий лише в «Розкладі». Свідомий компроміс: черга має показувати
    те, що ще має сенс підтверджувати. Саме через цей фільтр екрану потрібен 60-секундний тік
    (`refreshRequests()`), інакше заявка, чий час минув при відкритому екрані, висіла б у списку.
  - **Імена клієнток — ледачий fetch із кешем, а не батч і не денормалізація.** Це перше місце, де
    асинхронне джерело мусить співіснувати з синхронним `didSet → rebuild()`, на якому побудовані всі
    наявні view models. Рішення: імена це **третє джерело в тому ж патерні** —
    `clientNames: [String: String]` з власним `didSet`, а білдер `RequestsList` лишається чистою
    синхронною функцією. `inFlightNames: Set<String>` не дає читати той самий uid двічі, поки
    снепшоти йдуть частіше за читання; невдале читання **не кешується** (наступний снепшот спробує
    ще раз) — кеш негативних результатів додав би стан заради випадку, якого в одному салоні бути
    не повинно.
  - **`hasLoaded` чекає й на імена, а фолбек-напису більше немає** — переглянуто в кінці PR19
    (2026-08-21) після скарги, що при перемиканні табів на секунду блимає «Клієнтка», а тоді
    підміняється справжнім іменем. Початкове рішення було зворотним (`hasBlocks && hasServices`,
    як у PR17, плюс ключ `requests.client.unknown` як заглушка). Обидві половини скасовані:
    ключ **видалено з каталогу**, а `hasLoaded` тепер додатково вимагає `hasResolvedNames(now:)`.
    Спалах був подвійної природи — гейт не чекав імен *і* view models перебудовувались на кожному
    перемиканні таба (див. хойстинг нижче); полагоджено обидві.
    - **`hasLoaded` залатчений**: `guard hasLoaded == false else { return }` перед присвоєнням.
      Без латча звичайне присвоєння регресує — нова `pending`-заявка від некешованої клієнтки
      знову зробила б його `false` і підмінила **вже намальований** список повноекранним
      `ProgressView`. Хойстинг зробив це не теоретичним: VM тепер справді отримує снепшоти,
      поки екран не видно.
    - **Заявка з нечитабельним профілем не ховається мовчки.** `unreadableClientIds: Set<String>`
      (з власним `didSet → rebuild()`, четверте джерело в тому ж патерні) наповнюється тими uid,
      чиє читання провалилось, і `RequestsList` малює для них маркер
      `requests.client.unavailable` замість того, щоб викидати рядок. Інакше заявка зникала б
      зовсім, екран показував би «Заявок немає» — брехню — а разом із фільтром минулих заявок
      така заявка ставала б **назавжди невидимою й вічно `pending`**. Найгірше це в офлайні з
      холодним кешем: блоки приходять зі снепшот-кешу, а `getDocument` падає.
    - Три стани імені тепер розрізняються явно: є в `clientNames` → ім'я; є в
      `unreadableClientIds` → маркер; немає ніде → `nil`, тобто **«ще летить»**, і рядок чекає.
      Приховування лишилось, але стало тимчасовим, а не остаточним.
    - **Що свідомо лишилось зламаним**: офлайн і видалений `users/{uid}` дають однаковий маркер.
      `fetchProfile` не має клієнтського таймауту, а нечитабельний uid перечитується кожні 60 с
      без кінця. Розрізнення причин вимагає доменного типу помилки в репозиторії (щоб VM і далі
      не імпортувала Firebase) — винесено в окремий PR «Стани помилок» разом із error-станом у
      `ListStatusOverlay` (його зараз бракує всім трьом спискам) і переходом на
      `AsyncThrowingStream`.
  - **`loadMissingNames()` запускається окремою `Task`, а не через `await` у циклі снепшотів** —
    знахідка рев'ю `swiftui-pro` на етапі планування. `fetchProfile` іде в мережу без клієнтського
    таймауту; поки він висить, `for await` не забирає наступні снепшоти, і список перестає
    оновлюватись у реальному часі, хоча дані вже прийшли (`AsyncStream` буферизує unbounded, тож
    губиться не дата, а свіжість). Незструктурована `Task` тут прийнятна саме тому, що робота
    коротка й ідемпотентна завдяки `inFlightNames`.
  - **`Block.chronologically` винесено в `Models/Block/Block+Chronological.swift`** — `RequestsList`
    була б третьою копією, рівно поріг, на якому PR17 витягнув `Block.timeRangeLabel`. Важлива
    деталь: дві наявні копії **не були ідентичні** — `MyBookingsList` порівнював
    `date` → `startMinutes` → `id`, а `ScheduleViewModel` лише `startMinutes` → `id`, бо його вхід
    уже звужений до одного `selectedDate`. Спільною стала **повна** версія з датою: для одноденного
    входу порівняння дат — гарантований no-op, тож поведінка «Розкладу» не змінилась. Зворотний
    напрямок був би багом.
  - **Кнопка виходу майстра переїхала в `StatsView`**, який тепер бере `profile` і `onSignOut`. Вона
    жила в заглушці таба «Заявки», і новий екран її витіснив. Четвертий таб «Акаунт» не заводили —
    MVP-спека фіксує три таби в майстра, а «Статистика» вже є входом у налаштування («Мої послуги»).
    Без цього переїзду `MasterRootView.profile` став би мертвим полем.
  - `Master/Requests/`: `BookingRequest` (презентаційна модель — **без `status`**, бо всі рядки
    `pending` за побудовою і піл на кожній картці повторював би заголовок екрана; статус несе лише
    акцентна смужка), `RequestsList` (чиста
    `requests(blocks:services:clientNames:unreadableClientIds:now:)` + `pendingClientIds(in:now:)` —
    обидві через спільний приватний `pending(in:now:)`, щоб «які рядки показуємо» і «чиї імена
    вантажимо» не розійшлись), `RequestsViewModel`, `RequestsView`, `RequestsMetrics`,
    `Components/RequestCard`, `Preview/RequestsPreviewData`.
  - **Екран не бере `bottomClearance`** — власного `NavigationStack` немає, тож `safeAreaInset`
    роутера доїжджає до скролу сам (правило PR17). `VStack`, не `LazyVStack`.
  - **`FailingBlockRepository` отримав `init(blocks: [Block] = [])`** — його `observeBlocks()` віддавав
    порожній масив, тобто в прев'ю помилки не було на що натиснути. Дефолт лишив єдиного наявного
    споживача (`CancelBookingPopup`, PR18) без правок.
  - Локалізація: 5 нових ключів (`requests.title`, `requests.empty.title`, `requests.empty.message`,
    `requests.client.unavailable`, `requests.error.generic`) — `en`+`uk`, `translated`, за абеткою.
    `requests.client.unavailable` («Профіль недоступний») з'явився наприкінці PR19 **замість**
    видаленого `requests.client.unknown` («Клієнтка»): перший — маркер збою, який показується
    поруч із реальною заявкою, другий був заглушкою на час завантаження. Підміна не косметична —
    див. блок про `hasLoaded` вище.
    Переюзано без перейменування `schedule.action.confirm/decline`, `schedule.confirm.decline.*`,
    `common.service.unknown`, `common.action.ok`, `common.action.signOut`. Префікс `schedule.*` на
    екрані заявок лишено свідомо — те саме рішення, що PR17 прийняв для `schedule.status.*`.
  - **Хойстинг view models у роутери таки зроблений** — спершу планувався поза PR19, але виявився
    другою половиною причини блимання імені, тож без нього гейт на іменах не мав сенсу.
    `MasterRootView` тримає `scheduleViewModel`/`requestsViewModel`, `ClientRootView` —
    `bookingViewModel`/`myBookingsViewModel` (обидві через `init` + `State(initialValue:)`, бо їм
    потрібен `profile.uid`), плюс `.id(profile.uid)` на обох роутерах у `RootView`. Закриває
    беклог-пункт «View models are rebuilt on every tab switch», який PR17 і PR18 по черзі
    відкладали. Роутери й далі **не читають** ці view models у `body` — лише передають униз, тобто
    лишаються роутерами, а не екранами; ознака зриву була б у зверненні на кшталт
    `myBookingsViewModel.count` заради бейджа.
  - **Не в цьому PR**: живий бейдж на табі, виділення `Assets/DomainUI/` — обидва лишаються в
    беклозі. Туди ж, уже після роботи над екраном, відклався **редизайн `BlockDetailPopup`**
    (картковий стиль дій замість зелено-червоних капсул + хрестик замість текстового «Close»):
    зроблений, зістешений і випущений окремо як M-20 нижче. Відділився чисто саме завдяки
    дефолту `style: .popup` — тобто розв'язка, закладена самим PR19, окупилась одразу.

- **M-20 — редизайн `BlockDetailPopup` (branch `M-20-Block-detail-popup-restyle`)**: суто вигляд,
  жодної зміни поведінки. Виник як хвіст PR19 і був **свідомо з нього вирізаний** — зістешений
  посеред роботи, коли стало видно, що гілка перетворюється на кашу з двох історій. Це перший
  випадок у проєкті, коли готовий код відкладали заради чистоти PR, а не навпаки.
  - **Дії перейшли на картковий стиль.** Були зелена й червона капсули `PopupPrimaryButton`, стали
    залита `Color.ink` («Підтвердити») і обведена («Відхилити») з іконками `checkmark`/`xmark` —
    ті самі `CardActionButton`, що в картці заявки. Мотив був саме в цьому: та сама пара дій
    виглядала по-різному в черзі й у попапі.
  - **Текстовий «Close» замінено хрестиком** у заголовку, по діагоналі від годин. Хрестик живе в
    одному `HStack` із `timeRangeLabel`, а піл статусу — під ними; завдяки цьому він вирівнюється
    по центру рядка сам, без магічних відступів. Область натискання 44×44 за HIG, `.contentShape(.rect)`
    щоб працювали порожні кути, `.padding(.trailing, -closeEdgeCompensation)` — інакше гліф висів би
    за 35 pt від краю картки проти 20 pt зліва в годин. Обов'язковий `accessibilityLabel`
    (переюзаний ключ `schedule.detail.close`), бо кнопка лише з іконкою — VoiceOver інакше читає
    сиру назву SF Symbol. Нових рядків у каталог не додано.
  - **Рядок дій став `@ViewBuilder` і зникає повністю** для блока зі статусом `available`
    (`availableActions` порожній). Раніше там була умовна `Spacer()`, яка тримала «Close» ліворуч;
    після його зникнення потреба відпала, і `VStack` контейнера більше не отримує порожній `HStack`,
    що з'їдав би 16 pt міжрядкового інтервалу.
  - **Мертвий код прибрано в тому ж PR**, бо він став мертвим саме тут: `BlockActionButtonStyle`
    разом із параметром `style` (обидва споживачі тепер малюють картковий вигляд, отже гілка
    `.popup` втратила виклики), і `BlockAction.color`, який читала лише та гілка. `BlockActionButton.button`
    перестав бути `@ViewBuilder` зі `switch` і став одним прямим викликом. Заразом зникло питання
    назви: `.card` брехав би, малюючись у попапі, але енума більше немає.
  - **`PopupPrimaryButton` живий і не змінений** — його прямо викликають чотири інші попапи.
    Мертвою була гілка всередині `BlockActionButton`, не сама кнопка.
  - **Свідомо не робили**: решту чотирьох попапів не чіпали, тож `BlockDetailPopup` тепер єдиний
    без текстової кнопки скасування внизу. Рішення від 2026-08-22 — лишити винятком, щоб PR
    відповідав своїй назві; неузгодженість занесена в беклог нижче.
  - Розмін, ухвалений свідомо: повернути кольорові капсули тепер не однорядковий відкат, а
    відновлення `BlockAction.color` плюс гілки стилю.
  - `firestore.rules` не змінювались. Локалізація не змінювалась.

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
   already-present unknown-service fallback covers it (the key was `schedule.service.unknown` then;
   PR17 renamed it to `common.service.unknown` once both cabinets needed it).
   - ~~**PR10 — read-only list**~~ — **done**, see the PR10 entry under "Done" above.
   - ~~**PR11 — add a service**~~ — **done**, see the PR11 entry under "Done" above. Note it also
     deleted `Service.durationMinutes` outright, so the form is two fields, not three.
   - ~~**PR12 — edit + delete**~~ — **done**, see the PR12 entry under "Done" above. Two departures
     from what was planned here: deletion ships **without** a confirmation step, and the mockup's
     per-row "Змінити" link was still not built — editing is entered by tapping the row instead,
     while the row's star became a real activity toggle (a scope addition, not a substitution).
2. ~~**Client — "Запис" (Booking)**~~ (mockup screen 03) — **done** (PR13 + PR14 + PR15, усі три
   під "Done" above): the service list is wired to real `available` blocks, a card's chevron opens
   the month calendar with green-underlined available dates and hour chips, and an hour — from
   either screen — opens a confirmation popup that really writes the `pending` block and drops the
   client into the "Мої записи" tab. The planned PR15/PR16 split was collapsed into one PR: a popup
   that doesn't write would have been a decorative stub. No longer gates screens 3–5.
3. ~~**Client — "Мої записи" (My bookings)**~~ — **done** (PR17 + PR18, both under "Done" above):
   list of own pending/confirmed blocks in two sections, plus a cancel action that really returns
   the block to `available`. This closes the client's full loop — book → see it → cancel it.
   Thin follow-on to screen 2 — same repository, same models. Shipped as **two** PRs, split by
   capability rather than by layer (decided 2026-08-17): a UI-only PR on fixtures would be the
   decorative stub that PR15 deliberately avoided when it collapsed the planned PR15/PR16 split.
   Both halves read real data; `firestore.rules` and `BlockRepository` need no changes at all
   (`allow read: if isSignedIn()` on `blocks`, and `cancel(blockId:)` exists since PR1).
   - ~~**PR17 — read-only list**~~ — **done**, see the PR17 entry under "Done" above. Two things it
     settled beyond the plan: the card shows a **time range**, not a duration (`Service` has had no
     duration field since PR11), which produced the shared `Block.timeRangeLabel`; and past bookings
     are capped at five with no status pill, since the section heading already carries that meaning.
   - ~~**PR18 — cancel a booking**~~ — **done**, see the PR18 entry under "Done" above. Two things it
     settled beyond the plan: the affordance is a **text button in the card** (not a swipe — that
     reads as "delete" here), and the confirmation is a `PopupContainer` popup rather than an
     `.alert`, so the error can render inline instead of stacking a second alert. It also did
     **not** ship the tab-switch debt fix its plan had queued as task 6 — that stays in the backlog.
   - ~~Rider for whichever of the two first needs it: move `BlockStatusPill` + `BlockStatusStyle` out
     of `Master/Schedule/Components/`~~ — **done in PR17**: both now live in `Assets/UICommons/`, the
     pill carries its own `private enum Layout`, and `ScheduleMetrics.StatusPill` is gone.
4. ~~**Master — "Заявки" (Requests)**~~ — **done** (PR19, under "Done" above): list of upcoming
   `pending` blocks with the client's name and inline confirm/decline. Two departures from what was
   planned here:
   - **`BlockDetailPopup` was not reused.** The plan expected it as the detail surface; PR19 put the
     two actions straight in the card instead, because a queue where every row needs a decision
     shouldn't charge an extra tap per row. What got reused is `BlockAction` + `BlockActionButton`
     (spinner, disabled state, and the decline confirmation alert), both moved into
     `Assets/UICommons/`. The popup is untouched.
   - **Past `pending` blocks are hidden**, so a request the master never answered stays `pending`
     forever and is visible only in the Schedule. Deliberate: the queue lists what is still worth
     confirming.
   - ~~Pull `UserRepository`/`FirestoreUserRepository`/`FakeUserRepository` out of the stash and show
     the client's name~~ — **done in PR19**. Note the stash index in the old text was wrong; see
     Housekeeping.
   - ~~Move `BlockStatusPill` + `BlockStatusStyle` out of `Master/Schedule/Components/` once Requests
     becomes their second consumer~~ — **done in PR17** (screen 3 got there first). The open question
     it carried is now a standalone backlog item below.
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

- ~~**Extract the screen header and the list status overlay into `Assets/UICommons/`**~~ — **done
  (PR16, see the entry under "Done" above)**. Two departures from what was planned here: the
  constants live in a nested `private enum Layout` rather than at file scope (that matches four of
  the six existing components; file scope is only forced on the generic `SwipeToDelete`), and
  `ListStatusOverlay` takes `isEmpty` as a parameter — the planned
  `ListStatusOverlay(hasLoaded:titleKey:messageKey:)` had no way to know the list was empty.
- **PR13 leftovers from the final whole-branch review** — all Minor, none blocking:
  - ~~`BookingPreviewData.clientId` is dead~~ — **fixed by PR15**: it feeds every confirm-popup and
    calendar preview now that the fake repository actually books.
  - ~~`ServiceOffer.id`'s unreachable fallback~~ — **fixed before merge**: `id` is now a stored
    `let`, assigned from the already-unwrapped `serviceId`.
  - ~~The past filter is up to 60 s stale~~ — **fixed by PR15**: `BookingConfirmViewModel.book()`
    guards on `.now` at the call site instead of trusting the list's ticked `now`.
  - The booking design spec (`docs/superpowers/specs/2026-08-08-client-booking-design.md`) was
    **deleted** together with the PR13 plan file once the code landed, per the CLAUDE.md rule that
    these are throwaway artifacts. The parts of it worth keeping are folded into the PR13 entry
    above and into the screen-2 item below; the month calendar with green-underlined available
    dates is the one design decision that has not shipped yet, so it is recorded there rather than
    only in a deleted file.
- ~~**View models are rebuilt on every tab switch**~~ — **done in PR19** (see its entry under
  "Done"). Both routers now hold them as `@State` above the `switch`; `ClientRootView` builds its
  two in `init` from `profile.uid`, and `RootView` carries `.id(profile.uid)` on both routers so a
  change of account rebuilds them. Kept below in full because three PRs deferred it and the
  reasoning is worth preserving — including the part that turned out to be **wrong**: this was
  filed as a performance/flash item, but the sharper bug was correctness. A `body` re-evaluation
  while *staying* on a tab injected a fresh empty view model into a view whose identity had not
  changed, so its `.task` did **not** restart — the old task kept observing the old object while
  the screen read the new, permanently empty one. That failure is intermittent and does not
  reproduce by switching tabs, which is why it survived three reviews.
  - Original wording: in both routers — `MasterRootView.swift:14` and
    `ClientRootView.swift:14,21` construct them inside `body`, and the `switch` gives each tab its own
    view identity, so leaving and returning tears down the Firestore listeners and re-registers them:
    a full re-read plus a spinner flash per visit. Pre-existing pattern, but «Запис» is the client's
    default tab, so it's now user-facing. Fix means hoisting the view models above the `switch` in
    both routers.
  - **PR17 made this two-for-two on the client side** — `MyBookingsViewModel` is now built in the
    same `switch`, so switching tabs back and forth resets `hasLoaded` to `false` and empties
    `sections`/`offers`: a spinner blinks instead of the already-loaded list. Deliberately not fixed
    in PR17 because it touches PR13's code. The fix is `@State` on `ClientRootView` itself, built in
    its `init` from `profile.uid`. It does **not** reduce allocations (`init` runs on every parent
    re-evaluation too, and `State(initialValue:)` only takes on the first) — the win is purely
    keeping the state. **Not verified in the simulator** — derived from the code; confirm by
    switching tabs back and forth.
  - **PR18 queued exactly that fix as its task 6 and did not ship it** — the commit touches neither
    `ClientRootView` nor `RootView`, so all three client view models are still built inside the
    `switch`. The written-out fix (`@State` on `ClientRootView` built in its `init`, plus
    `.id(profile.uid)` on it in `RootView` as insurance for `State(initialValue:)` taking only on
    the first evaluation) is the plan of record; it just needs doing.
- **Split off `Assets/DomainUI/` — the condition has now been met.** `BlockStatusPill`/
  `BlockStatusStyle` landed in `Assets/UICommons/` in PR17 as the first two components that switch on
  a domain type (`BlockStatus`) rather than being purely presentational; **PR19 added
  `BlockAction`/`BlockActionButton`**, making four. The original wording said "if a couple more
  accumulate" — they have. PR19 deliberately did not do it, to keep its diff about the Requests
  screen; it's a pure file move (Swift has no intra-module imports, so nothing else changes).
- ~~**Deploy `firestore.rules`**~~ — **done (2026-08-08, after PR12)**: the file was edited by PR12
  (`hasValidServiceFormat()`, and `services`' `write` split into `create, update` / `delete`) and
  published to the Console for project `manik-5a2b8`. Deployment stays manual — Console
  copy-paste, no CLI/CI hookup — so re-verify after any future edit to the file.
  - The `price` audit that came with it is **also done**: the `services` collection holds a single
    document, written by a post-PR12 build (it already carries `isActive`), with `price: 1000` —
    whole, so it decodes into `Int` cleanly. No fractional prices exist to migrate. Note this also
    means the "legacy document without `isActive`" case has no instance in the live database; the
    optional stays anyway, since a hand-made Console document would recreate it for free.
- **Popups disagree on how you close them** (created by M-20, 2026-08-22, deliberately not fixed
  there). `BlockDetailPopup` now closes via a small `xmark` in its header; the other four —
  `AddNewSlotBlock`, `ServiceFormPopup`, `BookingConfirmPopup`, `CancelBookingPopup` — still carry a
  text button at the bottom (`PopupDismissButton`, labelled "Скасувати" / "Скасувати" / "Скасувати" /
  "Назад"). All five also dismiss on a backdrop tap, so this is about the visible affordance, not
  reachability.
  - Left as an exception on purpose: folding four more screens across both cabinets into M-20 would
    have made its name ("Block detail popup restyle") false, which is the mistake M-20 itself was
    carved out of PR19 to avoid.
  - If it gets unified, the close control belongs in `PopupContainer` rather than copy-pasted five
    times — the container already owns the backdrop and its `dismissLabel` (currently only an
    accessibility label for the backdrop button), so it is the natural home. Note the four remaining
    popups are **forms**, where a bottom "Скасувати" sits next to a primary action and reads as a
    deliberate pair; `BlockDetailPopup` is the only one that is purely informational. That may be a
    reason to keep two shapes rather than one — decide before doing the work, not during.
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
    on request — on the master's side the pill appears only in `BlockDetailPopup`'s header,
    unconditionally. Re-adding it to the card is a three-line change. (Since PR17 the pill also
    renders on the client's `MyBookingCard` for upcoming bookings, and lives in
    `Assets/UICommons/` — the master's card is still the gap.)
  - `SwipeToDelete`'s trash button has no text label (removed on request), so VoiceOver announces
    the raw SF Symbol name.
  - PR12 added one more: the star toggle in `ServiceRow` is a `Button` with no `accessibilityLabel`
    or `accessibilityValue`, and the row's `onTapGesture` carries no `.isButton` trait. Both were
    explicitly cut from PR12's scope, not overlooked.
  - PR18 added one more: every "Скасувати" button in `MyBookingCard` reads as the bare word
    "Скасувати" to VoiceOver, so a list of upcoming bookings gives several identically-labelled
    buttons with no way to tell which is which. The fix is an `accessibilityLabel` naming the
    service and the slot — declined in PR18 by the same precedent as PR9/PR12/PR17, which is why
    it lands here rather than in that PR.
  - PR19 added one more, and it is the same shape: every card in «Заявки» carries a "Підтвердити"
    and a "Відхилити" button, so a queue of requests reads to VoiceOver as several identically
    labelled pairs with no way to tell which request each belongs to. Fix is an `accessibilityLabel`
    naming the client and the slot on both buttons. Declined in PR19 by the same precedent.
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
  - PR19 added one instance of a different flavour: `RequestsViewModel.fetchNames(for:)` passes
    `userRepository` into a `withTaskGroup` child task via a capture list, and `UserRepository` is a
    plain protocol with no `Sendable` conformance. Legal under `minimal` checking, a warning under
    `-strict-concurrency=complete`. Don't paper over it with `@unchecked Sendable` on the protocol —
    fix it as part of the migration.
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
- **A booking points at a service by reference, so editing the service rewrites history** (raised
  while walking through `RequestsList` after PR19, 2026-08-21). Every screen that needs a booked
  service's name or price resolves it live — `RequestsList.swift:51`, `MyBookingsList.swift:43`,
  `ScheduleViewModel.swift:123` all do `services.first { $0.id == block.bookedServiceId }`. That
  asks "what is this service *now*", where the honest question is "what was it *when she booked*".
  - Deletion is only the loudest symptom (the row falls back to `common.service.unknown` and loses
    its price). Renaming and repricing corrupt the same data more quietly: raise 250 → 300 and a
    booking the client agreed to at 250 retroactively displays 300, with nothing to signal it.
  - Fix is the shopping-receipt pattern — snapshot the values onto the booking instead of linking
    to them: `var bookedServiceName: String?` and `var bookedServicePrice: Int?` on `Block`,
    **optional** per the `data-layer.md` rule about new fields on a populated collection, written
    alongside `bookedServiceId` at booking time (`FirestoreBlockRepository.swift:28-34`, reached
    from `BookingConfirmViewModel.swift:57`). `bookedServiceId` stays — the rules validate against
    it, and "book the same thing again" will want it. The three read sites then stop looking
    anything up, and `common.service.unknown` narrows to pre-migration documents only.
  - **The rules wrinkle, which is the reason this isn't trivial**: `isClientBooking()` currently
    lets a client's write touch only `status`/`clientId`/`bookedServiceId`, so she cannot influence
    price at all. Make her write `bookedServicePrice` and she can put any number there. Either the
    rule verifies it with a cross-document
    `get(/databases/$(database)/documents/services/$(...))` — supported, but it bills a read on
    every booking — or the master stamps the fields on confirm, which leaves «Заявки» (a
    pending-only screen) still resolving by reference and so defeats half the point.
  - Cheaper half-measure worth weighing: stop hard-deleting services
    (`FirestoreServiceRepository.swift:33-34`) and reuse the existing `isActive`/`isOffered` flag as
    a soft delete, so the document survives and every reference still resolves. Fixes deletion only;
    rename and reprice still rewrite the past.
  - **Timing matters**: `StatsView` is still a stub and nothing sums prices anywhere, so today this
    is display-only. Do this **before** the Stats screen computes revenue, or reported income will
    drift every time the master edits her price list.
  - Same shape as, and should probably ship with, denormalizing `clientName` onto `Block` — which
    would also retire the whole `clientNames`/`unreadableClientIds`/`fetchNames` machinery in
    `RequestsViewModel` and the `requests.client.unavailable` marker PR19 added.
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
  branch is folded into this file. `docs/superpowers/` tracks only the permanent MVP spec —
  `plans/` and `specs/*` are gitignored, so newer artifacts never reach a commit and exist only on
  the machine that wrote them.
  - **Still on disk, pending the merge of their branches**: `plans/2026-08-17-client-my-bookings.md`,
    `specs/2026-08-17-client-my-bookings-design.md` (PR17),
    `plans/2026-08-17-client-booking-cancellation.md` (PR18),
    `specs/2026-08-21-master-requests-design.md` and `plans/2026-08-21-master-requests.md` (PR19).
    Everything from all five that outlives its branch is already folded into the PR17/PR18/PR19
    entries above — delete each once its branch lands on `main`.
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
- **Stacked `.padding` calls that share one value should be merged with an `Edge.Set` literal** —
  `.padding([.vertical, .leading], inset)`, not two calls with the same constant. Purely mechanical:
  the edges don't overlap, so one modifier produces identical geometry with one less wrapper view.
  PR17 applied it in the only two places that existed (`MyBookingCard`'s and `ScheduleBlockCard`'s
  accent capsules, both `[.vertical, .leading]` on `accentInset`) and an app-wide sweep found **no
  other candidates** — every remaining stack uses two *different* constants (`horizontal` +
  `top`, `horizontal` + `vertical`), where merging is impossible. So this is a convention for new
  code, not outstanding cleanup. Do **not** "fix" pairs whose distinct constants happen to hold the
  same number (`ServicesMetrics.rowHorizontalPadding`/`rowVerticalPadding`): the separate names
  document intent and are meant to be able to diverge. Not written into
  `.claude/conventions/code-style.md` yet — do that if it comes up a second time.
- **Two stashes are outstanding** (`git stash list`) — and the indices in this file were wrong until
  PR19 checked them. The actual list is:
  - `stash@{0}` — `pr-14 calendar wip`. Superseded by PR14, which shipped; review, then drop.
  - `stash@{1}` — the full first cut of PR8 (proportional timeline, block detail popup + delete,
    `UserRepository`, popup scaffold components, 13 localization keys). **The `UserRepository` trio
    was the only reason it survived, and PR19 took it**, so this stash can now be dropped.
    Note the trio lived in the stash's **untracked** commit, not its index — the working extraction
    was `git show 'stash@{1}^3:<path>'`, three files, no `pop`. Popping wholesale **will** conflict
    across `ScheduleView`/`ScheduleViewModel`/`HourlyTimelineView`/`MasterRootView`/`ScheduleMetrics`.
  - The old PR5 stash referenced here previously is gone — it is not in the list any more.
