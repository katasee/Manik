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

- **M-21 — booking service snapshot (branch `feature/pr21-Booking-service-snapshot`, 6 tasks)**: a
  booking stopped pointing at a service and started carrying its name and price inside itself. This
  closes the backlog item "A booking points at a service by reference" — editing the price list no
  longer rewrites bookings that already exist. No new localization keys; `common.service.unknown` is
  reused. **This is also the first entry written in English after the language rule in `CLAUDE.md`**
  — see the note there about why PR11–M-20 stay Ukrainian.
  - **Two optional fields on `Block`**: `bookedServiceName: String?`, `bookedServicePrice: Int?`.
    Optional is **mandatory** here, per the `data-layer.md` rule: the synthesized `init(from:)` does
    not fall back to a property's default, so `var bookedServiceName = ""` would throw `keyNotFound`
    on every document written before this PR and empty the whole list. Optionality also kept the
    memberwise initializer source-compatible — not one existing `Block(...)` call site was touched.
  - **`struct BookedService { id, name, price }` lives in `BlockRepository.swift`**, above the
    protocol. All three fields are non-optional and it is deliberately **not `Codable`**: it carries
    the arguments of one repository call, it is not a nested document. There is exactly one real
    reason the type exists — its `id` is **non-optional**, unlike `Service.id`
    (`@DocumentID var id: String?`), so "the snapshot is complete" becomes a fact of the type and the
    repository has nothing to unwrap. The "a type stops the name and price drifting apart" argument
    is weak in Swift (argument labels already prevent the mix-up); three flat parameters would have
    been equally safe and lose only by inflating `book` to five.
    - **The plan specified a separate `Services/Repositories/BookedService.swift` file and it was
      dropped immediately after implementation** (2026-08-23). The plan's justification ("a domain
      type, the file doesn't import Firebase") does not survive inspection: `Block`, in that same
      signature, imports `FirebaseFirestore` for `@DocumentID`, so Firebase is in the contract
      either way. Precedent points the other way too — `BookingError` stands alone because it
      travels between layers (thrown by the repository, caught by a view model), while a type
      inseparable from a single declaration is co-located in this project: `BlockStatus` in
      `Block.swift`, the role enum in `UserProfile.swift`, the pair in `BlockAction.swift`.
      `BookedService` has exactly one consumer and means nothing outside `book`'s signature.
  - **`Models/Block/Block+BookedService.swift`** — `bookedServiceLabel`, i.e.
    `bookedServiceName ?? String(localized: "common.service.unknown")`. Introduced up front rather
    than after the fact: there are exactly three readers, which is the same threshold at which PR17
    extracted `Block.timeRangeLabel`. The separate file is not overthinking — the whole of
    `Models/Block/` is built as one derived attribute per `Block+X` file, and this is the fifth.
  - **`decline`/`cancel` wipe the snapshot** (`FieldValue.delete()` on both new fields alongside
    `clientId`/`bookedServiceId`), otherwise it would hang around inside a freed block. `confirm`
    leaves it alone — the block stays booked.
  - **The rules verify the snapshot with a cross-document `get()`**: a new `bookedService()` function
    reads `services/{bookedServiceId}`, and `isClientBooking()` requires the name and price to match.
    Without it a client — who now **writes** the price — could put any number there. The cost is one
    extra read per booking; the alternative (the master stamps the fields on `confirm`) would have
    left "Заявки", a screen of **exclusively** `pending` blocks, still resolving live, which defeats
    half the point of the PR. `isClientCanceling()` mirrors this by forbidding a leftover snapshot.
    Rules deployed by hand through the Console (see Housekeeping).
  - **There is deliberately no fallback** — none of the three read sites looks anything up any more,
    which is why noticeably more code left than arrived: `observeServices()` is gone from
    `MyBookingsViewModel` and `RequestsViewModel` entirely, together with `serviceRepository`,
    `services` and the matching `.task`s in the views; `MyBookingsList.sections` and
    `RequestsList.requests` lost their `services` parameter. **PR17's two-stream `hasLoaded`
    (`hasBlocks && hasServices`) collapsed** not because the condition was weakened but because the
    second stream no longer exists. In "Заявки" the gate stays compound
    (`hasBlocks && hasResolvedNames`) — client names still arrive separately.
  - **`ScheduleViewModel` kept its `services`**, and that is not an oversight. The neighbouring
    `serviceNames(for:)` resolves `offeredServiceIds`, which is the master's live list of offers, and
    resolving that live is correct. The snapshot only concerns what the client already picked.
    - Known consequence, reviewed on 2026-08-23 and **deliberately left as is**: on a booked block
      the schedule *card* prints the live offer list while that block's detail *popup* prints the
      snapshot, so after a rename one screen shows two different names for one booking. Making the
      card switch to `bookedServiceName` once a block is booked is a few lines, but it is a change to
      the schedule screen's behaviour rather than to the snapshot, and folding it in would make this
      PR's name false — the same reasoning that carved M-20 out of PR19.
  - **The `svc-removed` fixtures changed meaning**: `mine-5` and `req-3` no longer stand for "a
    deleted service" (a snapshot would have survived deletion) — they now stand for **a document
    written before this PR**, and they are what keeps the `common.service.unknown` branch alive. The
    `block(...)` helpers in both `*PreviewData` files now pull the name and price out of the local
    `services` array themselves.
  - `SchedulePreviewData.bookedServiceName(for:)` was **deleted rather than simplified**: after the
    snapshot it would have reduced to `block.bookedServiceName ?? ""` — a one-line wrapper with a
    single caller in the same file. The call was inlined; the neighbouring `offeredServiceNames(for:)`
    stays, since it genuinely resolves.

- **M-22 — Master «Статистика» (branch `feature/pr22-Master-stats`, 8 tasks)**: the `.stats` tab
  stopped being a placeholder and became the month summary. The data layer and `firestore.rules` were
  **not touched at all** — `observeBlocks()` already streams the whole `blocks` collection with no
  filter, so every figure on the screen is local arithmetic over data the client already holds. This
  closes screen 5 of the queue.
  - **Six metrics, agreed with the user during brainstorming**: revenue already earned, expected
    revenue for the month, visits, hours worked, free slots left, and a month-over-month comparison
    on money and on clients. A block counts as *completed* when it is `confirmed` and its
    `date + endTime` is in the past.
  - **"Скасовано" was dropped from the product, not deferred.** The MVP spec listed it as the third
    metric, but there is no data behind it: `cancel(blockId:)` returns the block to `available` and
    wipes `clientId`/`bookedServiceId`/`bookedServiceName`/`bookedServicePrice`, and
    `isClientCanceling()` in `firestore.rules` *requires* that wipe, so a cancelled slot is
    indistinguishable from one that was never booked. Counting cancellations would mean persisting a
    new record. On 2026-08-23 the call was to remove the metric outright — the MVP spec was edited to
    match (the flow line and the metric bullet), including the now-dangling parenthetical on the
    out-of-scope "No-show" line. Nothing about cancellations is left as a TODO anywhere.
  - **A pre-M-21 `confirmed` block contributes 0 to money** (`bookedServicePrice ?? 0`) but still
    counts as a visit and as hours. Resolving the price live from `services` would reinstate exactly
    the bug M-21 fixed, so the zero is deliberate. `done-legacy` in the fixtures keeps that branch
    alive.
  - **Browsing into a finished month changes two of the six.** "Очікувана сума" disappears from the
    revenue card (it would equal the earned figure exactly), and the slots tile keeps its number but
    switches its caption from «Вільні слоти» to «Не заброньовано» — the same count means "still
    free" in a live month and "never booked" in a dead one. Forward navigation stops at the current
    month, so a future month is unreachable and needs no rule.
  - **Comparison is whole month against whole month**, decided against a same-day-of-month
    comparison. Known cost, accepted: for the first weeks of every month the delta reads negative
    even when nothing is wrong. A previous month with zero revenue renders **no** comparison row at
    all — a percentage against zero is a division by zero or a meaningless "+∞%".
  - **A zero month shows zeros, not an empty state.** `ListStatusOverlay` is deliberately not used
    here: it draws `ContentUnavailableView` when a list is empty, and a month with no bookings is not
    missing data. Only the pre-first-snapshot spinner applies, so it is spelled out inline.
  - **Design came from a reference the user supplied**, not from a mockup — there has never been one
    for this screen. White cards on the light background, large corner radius, soft shadow, a rounded
    tinted icon badge, a big number with a small unit, a muted caption. That maps onto the existing
    palette without inventing a visual language — see the follow-up bullet below for which colour it
    landed on. **Icon badges reuse the palette**
    (`FreeSlot`/`StatusPending`/`StatusConfirmed`/`StatusAvailable` at 0.15 opacity with the glyph at
    full strength) — new pastel colorsets were rejected, both because the palette is a decision
    beyond this screen and because every colorset added today is one more with no dark half.
  - **No localization key takes a format argument**, and that shaped the copy. The trend renders as
    three separate `Text`s (arrow, value, `stats.trend.previousMonth`) and the expected row as label
    plus value. It is also why no tile label is a counted phrase: "12" + «Візити» never inflects,
    whereas «12 візитів / 1 візит / 2 візити» would have forced plural variations the catalog has
    never used. Ten new `stats.*` keys, `en`+`uk`; `master.placeholder.title` was deleted with its
    only reader, as PR17 did with `client.placeholder.title`.
  - `Master/Stats/`: `MonthlyStats` (+`StatsTrend`) as the presentation model carrying finished
    display strings, where the optionals encode **visibility** rather than absence; `StatsCalculator`
    (+`MonthlyTotals`) as pure arithmetic; `StatsViewModel`; `StatsMetrics`; `Components/`
    (`RevenueCard`, `StatCard`, `StatsTrendLabel`, `StatsLinkRow` +`StatsRoute`); `Preview/`.
    `Models/Block/Block+EndDate.swift` mirrors `Block+StartDate` — the sixth `Block+X` file.
  - **`StatsLinkRow` must not own its destination.** `NavigationLink(destination:)` builds its
    destination **eagerly**, when the link is created — so the old
    `MyServicesView(viewModel: MyServicesViewModel())` closure was constructing a fresh view model,
    and a fresh `FirestoreServiceRepository`, on every re-evaluation of the body. With a 60-second
    tick and a live snapshot stream that is constant. The row now pushes a `StatsRoute` value and
    `StatsView` registers `.navigationDestination(for:)`, which runs only on an actual push. Found by
    the `swiftui-pro` review of the plan, before any of it was written.
  - **`Grid` + `GridRow`, not `LazyVGrid`**, and `StatCard` carries a second
    `.frame(maxHeight: .infinity, alignment: .top)` after its padding. Without it the card with a
    trend line is taller than its neighbour and the grid reads as ragged; four static cards also make
    laziness pointless (the call PR17 made choosing `VStack` over `LazyVStack`).
  - **`monthTitle` is stored, not computed** — refreshed from `monthStart`'s `didSet`.
    `DateFormatter.string(from:)` on every body evaluation is not free. `canGoForward` stays
    computed: it depends on the wall clock as well as on `monthStart`, so caching it would need
    invalidating at midnight on a month's last day.
  - **`hasLoaded` is latched** (`guard hasLoaded == false else { continue }`). `@Observable`'s setter
    fires an invalidation on every assignment, equal value or not. `RequestsViewModel` latches it for
    a sharper reason — there a plain assignment could regress it to `false`; here it is purely about
    not re-invalidating on each snapshot.
  - **`MonthHeader` moved into `Assets/UICommons/`** — its second consumer, the threshold at which
    PR17 moved `BlockStatusPill` and PR19 moved `BlockAction`. It dropped `BookingMetrics` for a
    `private enum Layout` and became **symmetric**: booking disables the *back* arrow (no booking
    into the past), stats disables the *forward* one. The `booking.calendar.*` keys were kept without
    renaming, the same call PR17 made for `schedule.status.*`.
    - The `swiftui-pro` review proposed collapsing its `Button(action:) { Label(...) }` into
      `Button(_:systemImage:action:)` for consistency with `ScreenHeader`. **Declined**: the short
      form gives nowhere to put the 44×44 frame except on the `Button` itself, which is the exact
      regression PR14 fixed in this component.
  - **`profile` is gone from `MasterRootView` and `StatsView`.** PR19 moved sign-out here so the
    property would not be dead; the new screen shows no name, so carrying it down would make it dead
    again. `RootView` still uses `profile` for `.id(profile.uid)` and for the client cabinet.
    `statsViewModel` hoisted into `@State` alongside the other two, per PR19.
  - **`.bottomClearance(_:)` in `Assets/UICommons/`** — `StatsView` was the third screen owning a
    `NavigationStack` inside a tab, which is the condition `architecture.md` set for turning the
    repeated parameter into a shared modifier. The router still passes the value; the modifier
    deliberately does **not** read `TabBarMetrics`, since a UICommons component must not depend on a
    feature's metrics. `BookingView` and `BookingDatesView` migrated in the same pass and
    `architecture.md` was updated.
  - **Verified by build only.** There is no test target, so the calculator was checked against
    hand-computed expectations through a temporary text `#Preview` (the PR13/PR14 idiom), deleted in
    the final task. The simulator walkthrough — signing in as the master and confirming the figures
    against the Schedule — was **not** performed and is outstanding.
  - **A refinement pass followed the eight tasks**, same day, driven by the user reviewing the
    finished screen. Five changes, none of them altering what the screen computes:
    - **Cards are `Color.fieldBackground`, not `Color.surface`.** The reference was white cards
      lifted off the page, and `Surface` (`#D6D3DE`) is *darker* than `Background` (`#E4E3E9`) —
      light falls from above, so a shadow under a card darker than its page reads as a recess, not a
      lift. Two wrong turns were taken first and reverted: adding a shadow to the darker card, then
      darkening `Surface` further and deepening `cardShadow()` globally. The fix was the colour the
      Schedule's block cards already use — `FieldBackground` (`#FBFAF8`, cream). `MonthHeader`'s
      arrow circles followed. Neither `Surface.colorset` nor `View+Shadow.swift` ended up changed,
      so no other screen moved.
      - Worth keeping straight: a dark card with a genuinely darker shadow *does* read as lifted —
        a dark button on white is the everyday proof. The tell is not "card lighter than page" but
        "shadow clearly darker than both, soft, offset downward". Ours failed on the second half:
        `ink` at 10% with a 2pt offset is invisible at that contrast.
    - **`CardSurface` + `IconBadge` in `Assets/UICommons/`.** The user's question was why three card
      views exist instead of one configurable card. Answer kept them separate — they differ in
      *structure* (centred vs leading vs a row with a chevron, one of them a `NavigationLink`), and
      merging them would trade three honest 40-line files for a chain of `if`s behind six flags. The
      duplication was real but sat in the **chrome**, so that is what moved: padding, fill, corner
      radius and `.cardShadow()` behind `.cardSurface(fill:padding:cornerRadius:fillsHeight:)`, plus
      the ten badge lines that `StatCard` and `StatsLinkRow` had verbatim. `fill` is a parameter
      precisely so `RequestCard`/`MyBookingCard`/`ServiceOfferCard`, which draw the same chrome on
      `Color.surface`, can adopt it later. `fillsHeight` exists because that grid-equalizing
      `.frame(maxHeight: .infinity, alignment: .top)` has to sit **between** the padding and the
      background — apply it from outside and the padding lands on an already-expanded frame and the
      card outgrows its row. `StatsMetrics` lost `Size.iconBadge`, `Size.iconBadgeCornerRadius`,
      `Size.icon` and `Opacity.iconBadge` with the badge.
    - **`StatsRoute` folded into `StatsLinkRow.swift`**, its own three-line file deleted. The type
      itself is load-bearing — it is what keeps the link value-based, which is the whole point of
      the eager-destination fix above — but a type that exists only to serve one neighbour belongs
      beside it. Precedent: `BlockAction.swift` holds `BlockActionConfirmation` too, with the
      supporting type first and the file's namesake second.
    - **`StatsCalculator` stops formatting.** It returns `MonthlyTotals` (nine plain `Int`s plus
      `isMonthFinished`) and `MonthlyStats.init(totals:)` does every `ServiceFormat.price`,
      `.formatted()` and percent string; both trend constructors moved onto `StatsTrend` as
      `percent(current:previous:)` / `count(current:previous:)`. The mixing was the one real
      single-responsibility complaint, and it had a concrete cost: the Task 3 check had to compare
      *formatted strings*, which differ by locale. `MonthlyTotals` lives in `StatsCalculator.swift`
      by the same rule as `StatsRoute`. `monthStart(containing:)` deliberately stayed on the
      calculator — it is calendar work rather than statistics, but it has one caller.
    - The last two came from the user pushing back on file count and on responsibilities; both
      pushbacks were correct and are the reason `architecture.md` now states the companion-type rule
      and the arithmetic-versus-formatting split explicitly.
- **M-23 — Client "Акаунт": profile (branch `feature/pr23-Client-account`, 4 tasks)**: the third
  client tab stopped being the inline `VStack` PR13 parked in `ClientRootView` and became a real
  screen — profile card, contacts, statistics, sign-out — with one popup that edits everything
  except email. First write to `users/{uid}` since sign-up. Numbered M-23 to match the branch name.
  It was built in parallel with M-22 — both branch off `feature/pr21-Booking-service-snapshot` — and
  pulling the merged `main` in mid-flight is what produced the `StatCard` collision described below.
  - **The screen is the first of three.** The full design lived in
    `docs/superpowers/specs/2026-08-23-client-account-design.md`; stats (visits + favourite service)
    and security (change password, delete account) followed as M-24 and M-25, and that spec was
    deleted once the third landed, per the CLAUDE.md throwaway rule. Everything worth keeping from
    it is in the three "Done" entries.
  - `UserProfile` gained `phone`/`instagram`/`telegram`, all **optional** — the synthesized
    `init(from:)` ignores property defaults, so a non-optional field would have thrown `keyNotFound`
    on every account created before this PR and locked those clients out (the `Service.isActive`
    lesson from PR12).
  - `UserRepository` stopped being read-only: `updateProfile(uid:edit:)` writes **exactly four keys
    via `updateData`**, never `setData`. A whole-document write would drop `role`, which is the
    difference between a working account and one that can't reach its cabinet. A cleared field is
    written as `FieldValue.delete()`, not `""`, so "no Instagram" is one state rather than two.
    The dictionary is built through a small `put(_:at:into:)` helper instead of
    `"phone": edit.phone ?? FieldValue.delete()` — the literal form only compiles by inferring
    `T == Any` across two unrelated types, and this is the one write the whole PR exists for.
  - Handles are stored **bare** (`olena_nails`): the leading `@` is stripped on save and re-added by
    the view, so storage and display can't drift. A field holding only "@" clears the value instead
    of storing an empty string.
  - **The phone is Polish-only**, `+48` + exactly 9 digits, stored canonically as `+48600123456`
    through the new `Utilities/PhoneFormat.swift`. That file mirrors `DateFormat`'s storage/display
    split: one form in Firestore, a spaced form (`+48 600 123 456`) on screen. In the form `+48` is
    a static prefix, only digits are accepted, they are masked `600 123 456` as they are typed, and
    a tenth digit simply doesn't fit. A pasted `+48…` has its country code absorbed rather than
    duplicated, but **only** when that leaves exactly 9 digits: an earlier `count > 9` test ate the
    real leading "48" of a number like `481234567` the moment a tenth digit was typed.
    The accepted cost: **a non-Polish number cannot be entered at all.** One salon, one country —
    and if that changes, the prefix becomes a picker without touching the storage format. Nothing
    else in the app ever writes `phone`: `signUp` creates the document with `name`/`email` only and
    the synthesized encoder omits absent optionals, so a value outside this format can only get in
    by hand through the Firebase Console. Such a value is **not migrated** — `PhoneFormat.display`
    returns anything it can't parse verbatim, so it still reads correctly, and it is normalized the
    first time its owner opens the popup. `firestore.rules` deliberately does not validate the
    format — unlike a block's date, a malformed phone breaks nothing server-side.
  - **The mask is applied through `.onChange`, not a `Binding(get:set:)`.** The obvious version —
    a computed binding whose `set` filters and truncates — *silently fails to cap the length*: when
    the filtered result equals what the property already held, there is no observable change, so
    `TextField` keeps the text the user typed and the tenth digit stays on screen. Binding the field
    straight to `$viewModel.phone` and normalizing in `.onChange` works because the truncated value
    genuinely differs from the typed one. Consequence: `phone` holds the **display** text
    (`600 123 456`), and the view model derives digits from it (`phoneDigits`) rather than the other
    way round.
  - **Length is checked on submit, not while typing.** "Зберегти" stays enabled and the red hint
    appears only after it is pressed — live validation meant the field was red for the whole time
    it took to type nine digits, i.e. during the normal path. `showsPhoneError` is derived
    (`hasSubmitted && isPhoneValid == false`), so it clears itself as soon as the number is
    complete. Deliberately not a `didSet` on `phone`: property observers under `@Observable` are a
    macro-expansion question nobody needs to answer for a flag that can just be computed.
  - **`firestore.rules` unchanged and not redeployed** — the owner's `update` with an unchanged
    `role` was already allowed, and a merge update satisfies that rule.
  - **The screen never calls `fetchProfile`.** `RootViewModel` already fetched the profile at
    sign-in and passes it down. A saved profile travels back **up** through
    `AccountViewModel.apply(_:)` → `ClientRootView.onProfileUpdated` → `RootViewModel.update(profile:)`,
    so the "Запис" greeting picks up a rename without a relaunch. `.id(profile.uid)` in `RootView`
    stays: the uid doesn't change, so the tab view models are not rebuilt and the debt PR19 closed
    stays closed. A callback rather than a listener because `users` has no realtime stream anywhere
    in the app, and adding one just to observe our own write would be heavier.
  - `Client/Account/` — `AccountView`, `AccountViewModel` (tab composition root, the only place here
    allowed a defaulted repository), `AccountStats`, `AccountMetrics`, `Components/ProfileCard`,
    `Components/AccountRow`, `ProfileForm/`, `Preview/AccountPreviewData`. Outside the feature
    folder: `Models/ProfileEdit.swift` and `Utilities/PhoneFormat.swift`.
  - **A contact row is a label, not a `Button`** — the pencil on the profile card is the screen's
    single entry point into editing. Rows were briefly made tappable so the empty state could be
    reached directly; that was reverted, because two ways into one popup means the row has to look
    tappable, and a row that looks tappable in a list of three otherwise-static values reads as
    navigation. The empty state therefore says "Не вказано" ("Not set"), not "Додати" — a passive
    value, not an affordance that goes nowhere.
  - **No `bottomClearance` parameter** — the screen owns no `NavigationStack`, so the router's
    `safeAreaInset` reaches its `ScrollView` on its own, exactly as for `MyBookingsView`.
  - The keyboard toolbar is mandatory: `.phonePad` has no return key, so without it the keyboard
    couldn't be dismissed and a backdrop tap would close the whole form (the `.decimalPad` lesson
    from PR11). This is also the **first** such toolbar in a popup presented from a screen with no
    `NavigationStack` ancestor — worth a look on device rather than only in the canvas.
  - `FakeUserRepository` became a mutable `final class`, following `FakeServiceRepository` (PR11) and
    `FakeBlockRepository` (PR15), so previews run the whole edit loop without Firestore. Its
    `init(profiles:)` label was kept so `RequestsView`'s four previews needed no edits.
  - Localization: 19 new `account.*` keys, `en`+`uk`, `translated`, alphabetical. `account.field.email`
    was deliberately **not** added — the word is identical in both languages and the card labels the
    address by context. Reused `common.action.cancel`, `common.action.done`, `common.action.signOut`.
  - **The stats section ships here as UI, with no logic behind it**: `AccountStats` plus two tiles
    ("Візити", "Улюблена послуга"), always visible, reading `AccountStats.empty` — `0` and `—`. The
    section is built in one pass so it can be judged as part of the screen; PR-B swaps `.empty` for
    the real derivation and deletes the temporary `stats:` init parameter that currently lets both
    preview states exist.
  - **The tiles are M-22's `StatCard`, promoted to `Assets/UICommons/`.** Both branches had written
    a `StatCard` of their own, so pulling the merged `main` produced two types with one name in one
    module — `invalid redeclaration`, a red build. Renaming one would have shipped two stat tiles
    that must be restyled in lockstep forever; the client's statistics and the master's statistics
    are the same idea and now render through the same view. The move cost three things:
    `StatsMetrics` references became a private `Layout` enum (a UICommons component must not depend
    on a feature's metrics), `StatsTrend` + `StatsTrendLabel` came along as its dependencies
    (`StatsTrend` moved out of `MonthlyStats.swift` into the label's file, as the supporting type of
    the view that renders it), and the card gained `valueLineLimit` — the master's values are
    numbers on one line, the favourite service is a name that needs two.
  - **The whole screen moved onto `.cardSurface`** once the tiles did. `ProfileCard` and the
    sign-out button dropped their hand-rolled `Color.surface` background for the modifier M-22
    introduced, so the account screen now matches the master's stats: `FieldBackground` (near-white)
    plus `cardShadow`. That leaves the rest of the client cabinet — `MyBookingCard`,
    `ServiceOfferCard`, `ConfirmBar`, the popups — still on the older grey `Color.surface`.
    Converging them is a separate pass across ~6 files; backlog item below.
  - The sign-out button is deliberately **thinner than a card**: no `minHeight`, and 14 of padding
    rather than 16, which lands it at ~46pt. That is the floor, not a round number — the label is
    ~18pt, so 12 of padding would put it under the 44pt tap target.
  - Contact icons are filled glyphs with `glyphShadow()`, a third member of `View+Shadow.swift`
    beside `brandShadow` and `cardShadow`. `cardShadow`'s radius 10 at 10% opacity dissolves under a
    20pt glyph; a symbol needs a short, slightly denser shadow to keep its outline.
  - **The visits tile splits number and noun onto two lines**, which is what keeps
    `account.stats.visits` an invariant "Візити" instead of an inflected "12 візитів". Ukrainian
    has three plural forms, so the one-line phrasing would have forced the catalog's first plural
    variations for a label nobody asked to be a sentence. `account.delete.warning` in PR-C still
    needs them — there the count really is inside the phrase.
  - **Not in this PR**: the stats derivation and change-password/delete-account.

- **M-24 — Client "Акаунт": stats logic (branch `feature/pr24-Client-account-stats-logic`)**: the two
  tiles M-23 left sitting at `AccountStats.empty` now show real numbers. No writes, no new query, no
  new field, no `firestore.rules` change, and **no new localization keys** — all four `account.stats.*`
  shipped with M-23.
  - **The spec's definition of a visit was wrong and was corrected here.**
    `2026-08-23-client-account-design.md` defined a visit as a `confirmed` block whose `startsAt` has
    passed — the negation of `MyBookingsList.isUpcoming`. M-22 had already shipped the master's
    answer to the same question as `StatsCalculator.isCompleted`, which uses **`endsAt <= now`**.
    Taken literally the spec would have made an in-progress appointment a visit for the client and
    not yet a visit for the master, which is exactly the divergence that spec's own sentence ("the
    two cabinets must not report different numbers for the same events") forbids. `endsAt` won: an
    appointment that is still happening has not been completed.
  - **The rule now lives in one place** — `Models/Block/Block+Completed.swift`
    (`isCompleted(now:)`), joining `Block+Minutes`/`Block+StartDate`/`Block+EndDate`/`Block+TimeRange`
    as a derived property of a domain type. `StatsCalculator`'s private copy was deleted and its two
    call sites now read the shared method. That is the only file touched outside the feature folder,
    and the point of touching it: two cabinets agreeing today by coincidence is not the same as two
    cabinets that cannot disagree.
  - `AccountStats.make(blocks:clientId:now:)` sits beside `.empty` in the existing file — one type,
    no separate builder enum, because this is two numbers rather than `MyBookingsList`'s section
    tree. The favourite service is the most frequent `bookedServiceName` among visits, ties broken by
    the more recent visit. **Blocks with no `bookedServiceName` are skipped** — they still count as
    visits, they just don't vote. That keeps `common.service.unknown` out of a tile that is supposed
    to name something the client likes; the alternative would have let pre-M-21 bookings win the
    category. The private helper is `favorite(among:)`, not `favoriteServiceName(among:)`: the
    latter collides with the instance property of the same name and does not compile inside a
    `static func`.
  - `AccountViewModel` dropped the temporary `stats:` init parameter and gained `blockRepository`
    (defaulted — it is the tab's composition root), `blocks` with `didSet { rebuildStats() }`, and
    `observeBlocks()`, mirroring `MyBookingsViewModel`. **`clientId` was not added as a parameter** —
    `profile.uid` is already there, and it is the one field of the profile that an edit cannot
    change. `ClientRootView` needed no edit at all, since both repositories default.
  - **No 60-second tick**, unlike `MyBookingsViewModel.refreshSections()`. That tick exists so a
    booking crosses from "Майбутні" to "Минулі" while the screen is open; a visit count changes once
    per appointment, and rebuilding on every snapshot is enough.
  - **The tiles are `.redacted(reason: .placeholder)` until the first snapshot** (`hasLoadedStats`).
    Without it a returning client sees `0` / `—` for a beat and then a jump to the real figures —
    a rendered untruth, not merely a blank. It cannot get stuck: `FirestoreBlockRepository`'s
    listener yields `[]` even on error (`{ snapshot, _ in }`), so the flag always rises. Deliberately
    **not** paired with `.unredacted()` on the tiles' glyph and caption, and not with
    `.accessibilityHidden` while loading — see the accessibility item in the backlog for the latter.
  - `AccountPreviewData.stats` was replaced by a `blocks` fixture in the `MyBookingsPreviewData`
    shape: seven visits (3× gel, 2× classic, 1× pedicure, 1 pre-M-21 block with no service name) plus
    an upcoming `confirmed`, a past `pending`, another client's block and an `available` one, none of
    which may count. The filled preview therefore reads `7` / "Манікюр + гель-лак" only if every
    exclusion works. The second preview keeps an empty `FakeBlockRepository`, so its zero state is
    the genuine empty result rather than a fixture.
  - **The redacted state itself has no preview** — it needs a double that never yields, and a fourth
    fake for one canvas was not worth it. It is verifiable in the running app only.
  - **Reviews (`swift-concurrency-pro`, `swiftui-pro`)**: no defects in the diff. Two things surfaced
    and were consciously left: the three `Fake*Repository` doubles touch their mutable state from two
    executors (`observeBlocks()` is sync and runs on the caller's `MainActor`, while the `async`
    mutators hop to the generic executor under SE-0338) — DEBUG-only, dating to PR15, and a hard
    error the day the project leaves `SWIFT_VERSION = 5.0`; and redaction is a visual treatment only,
    so VoiceOver still reads the placeholder values aloud.
  - **Not in this PR**: change password and delete account (PR-C).
- **M-25 — Client "Акаунт": security (branch `feature/pr25-Client-account-security`)**: the last of
  the three account PRs. The actions block is complete — "Змінити пароль", "Вийти", "Видалити
  акаунт" — and the client can do both things the app never offered. Deleting an account is an
  App Store requirement (guideline 5.1.1(v)), not a product wish; that is why it shipped.
  - **`AuthRepository` gained three methods, not the spec's two.** The spec's
    `deleteAccount(currentPassword:)` reauthenticated inside itself, which put the password check
    *after* the bookings were cancelled and the profile deleted — a mistyped password would have
    destroyed both and still left the account. `reauthenticate(password:)` is now its own call and
    runs first.
  - Firebase `NSError`s are mapped to `Services/Repositories/AccountError.swift` inside
    `FirebaseAuthRepository`, so the protocol layer stays Firebase-free.
    **`.invalidCredential` maps to `.wrongPassword` alongside `.wrongPassword` itself** — with
    email enumeration protection on, that is the code a bad password actually returns. The mapping
    guards on `AuthErrors.domain` first, because `AuthErrorCode` is an `Int` enum and would happily
    match a Firestore error with a colliding code.
  - **Delete order is load-bearing**: reauthenticate → cancel every future booking → delete
    `users/{uid}` → delete the Auth user. Cancelling must precede the Auth delete because
    `isClientCanceling()` needs a live `request.auth.uid`; `deleteProfile` must precede it for the
    same reason. The orchestration is in `DeleteAccountViewModel` rather than a repository — it
    spans three of them.
  - **Stops at the first failure, rolls nothing back.** A cancelled booking is a normal state and
    the client is still signed in to retry. The one unrecoverable window — profile deleted, Auth
    user alive — is closed by `RootViewModel`.
  - **Two guards make that retry real rather than theoretical**, both found by reviewing the plan
    before writing the code:
    - `DeleteAccountViewModel` tracks `cancelledBlockIds`. Cancelling clears `clientId`, and
      `isClientCanceling()` requires `resource.data.clientId == request.auth.uid`, so re-cancelling
      an already-cancelled block is **denied**. Without the set, any retry after a partial failure
      restarts the loop, is refused at the first block it had already succeeded at, and can never
      get past it — the account would be permanently undeletable from inside the app.
    - The "Видалити акаунт" button is `.disabled(hasLoadedStats == false)`. The popup's booking
      list comes from `observeBlocks()`, which is empty until the first snapshot; deleting inside
      that window would cancel nothing and leave live `confirmed` blocks in the master's calendar
      that nobody can ever cancel, because the rule needs a `clientId` matching a uid that no
      longer exists. The stats tiles were already covered against the same window by `.redacted`;
      the button was not.
  - **Past bookings of a deleted client are left untouched**, `clientId` and all. The master's
    stats keep counting that visit and its revenue rather than rewriting history retroactively, and
    `RequestsList` already renders an unreadable client as "Клієнт недоступний".
  - **`fetchProfile` now checks `snapshot.exists` before decoding.** `getDocument(as:)` on a
    missing document feeds `NSNull()` to the decoder and throws an opaque `DecodingError`, so there
    was no way to recognize the condition. It throws `AccountError.profileNotFound`, and
    `RootViewModel.refresh()` treats that as `reset()` — which also **signs the orphaned session
    out**. Without that, `currentUserId` stays non-nil and every launch re-enters the same branch
    forever.
  - `firestore.rules`: `users/{uid}` gained `allow delete: if isSignedIn() && request.auth.uid ==
    uid`. **Deployed to the Console for `manik-5a2b8` before the app shipped** — the reverse of
    M-21's order, because this rule only permits something previously denied.
  - `Block.isUpcoming(now:)` was extracted to `Models/Block/Block+Upcoming.swift` from
    `MyBookingsList`'s private copy — the same move `Block+Completed.swift` made in M-24, and for
    the same reason: the delete popup's promised count and the "Мої записи" list must not be able
    to disagree about which bookings are still ahead.
  - The account screen's single `.fullScreenCover(isPresented:)` became one
    `.fullScreenCover(item:)` over a private `AccountPopup` enum. Two `isPresented` covers on one
    view are not reliably honoured by SwiftUI — one silently never presents.
  - Change-password is the only flow here with a success state (checkmark + "Готово"): a changed
    password is invisible everywhere else in the app. Deleting needs none — the screen it was
    launched from ceases to exist.
  - **First plural key in the String Catalog**: `account.delete.warning %lld`, with Ukrainian's
    four categories and English's two. The key carries the format specifier because that is how
    Xcode extracts `Text("… \(count)")`.
  - `FakeAuthRepository` and `FailingAuthRepository(error:)` are new — the second takes its error
    as a parameter, unlike `FailingBlockRepository`, because four different popup states need it.
  - Localization: 17 new `account.*` keys, `en`+`uk`, `translated`, alphabetical.
  - **Not done here, still in the backlog**: the three account-screen accessibility items. This PR
    was deliberately kept to security.

- **M-26 — Liquid Glass tab bar (branch `feature/pr26-Liquid-glass-tab-bar`, 3 tasks)**: the
  hand-built floating capsule is replaced by the system `TabView`, the first step of the redesign
  on the Manik Screens canvas (light theme = "Новий дизайн", dark theme = "Темне вино").
  - Both routers are `TabView(selection:)` over `ForEach(MasterTab/ClientTab.allCases)` with
    `Tab(titleKey, systemImage:, value:)`; the `switch` lives in the `Tab` closure (no
    `screen(for:)` helper). Liquid Glass on iOS 26, the standard bar on 18, same code, no
    `#available`. `TabBar/` (5 files) and `View+BottomClearance.swift` are deleted, and the
    `bottomClearance` parameter is gone from `StatsView`, `BookingView`, `BookingDatesView` — the
    system bar owns the bottom safe area, even inside a screen's `NavigationStack`.
  - **The target's deployment target was 17.2, not 18.1.** The project-level setting said 18.1
    but the `Manik` target overrode it; `Tab` is iOS 18+, so the target now says 18.1 too.
  - **Live "Заявки" badge** (closes the backlog item): `.badge(requests.count)`. Hidden tabs don't
    run their `.task`s, so `RequestsViewModel`'s `observeBlocks()`/`refreshRequests()` moved from
    `RequestsView` to `MasterRootView`; the four `RequestsView` previews start `observeBlocks()`
    themselves. The badge equals the list, so it can lag a client-name fetch by a moment.
  - **Tabs keep state now**, which exposed one bug the old `switch` hid: after booking from the
    pushed dates screen, "Запис" reopened on that screen. `BookingView` owns
    `path: [ServiceOffer]` and `finishBooking()` clears it before `onBooked()`.
  - **App locked to light** (`INFOPLIST_KEY_UIUserInterfaceStyle = Light`): the system bar follows
    the system scheme, the palette has no dark half. This is the "pin to light" option from the old
    "Dark mode makes typed text invisible" backlog item (done via the Info.plist key rather than
    `.preferredColorScheme`), which also fixes that bug; the item is now "Dark theme" in the backlog. `AccentColor` (was empty) = `#0A0A0B`, the light redesign's `tab--on`; it is app-wide, so
    alert buttons and text carets are black instead of system blue. No `.tint` in code.
  - **Bottom padding on every scrolling tab screen** (found on a device after the first pass): the
    system inset ends scroll content flush against the bar's top edge — the old 112pt reserve had
    been hiding the missing padding. Account, My bookings, Requests, Stats, Booking and My services
    now end with 24pt from their own metrics (`contentBottomPadding`/`listBottomPadding`).
  - Accepted: tab labels are in the system font (documented exception in `code-style.md`); the
    raised active circle is gone; no minimise-on-scroll.
  - Reviewed twice with the SwiftUI Pro skill before implementation (the 17.2 target, the dark
    accent appearing on Dark Mode devices, the booking stack and the previews all came from those
    reviews).

- **M-27 — Light redesign foundation (branch `feature/pr27-Redesign`, 9 tasks)**: the design
  system of the canvas's "Новий дизайн" page, applied app-wide; screen layouts are still the old
  ones until M-28…M-32 (later dropped, see "Screens"). Spec: `docs/superpowers/specs/2026-10-05-light-redesign-design.md`.
  - **Tokens**: `Background` is white, `Ink` `#0A0A0B`, `TextSecondary` `#6E6E73`, `Destructive`
    `#C42F2F`; the three `Status*` colours are now the pill's *text* colour. New: `Card`,
    `Hairline`, `Stroke`, `TextTertiary`, `StatusPendingFill`, `StatusConfirmedFill`. Deleted:
    `Surface`, `FieldBackground`, `Badge` (unused — the system `TabView` draws the badge).
  - **Surfaces are three modifiers**: `.cardSurface` (contour + two soft shadows; `padding: 0` for
    cards that pad themselves asymmetrically), `.raisedSurface(shape)` (chips, round buttons,
    fields, tiles) and `.insetSurface(shape)` (outlined summary boxes, the Auth segment track — a
    small addition to the spec). Shadows moved onto the surface's background shape, so card text no
    longer casts its own shadow. This closes the old "two card surfaces" backlog item.
  - **Components**: `CapsuleButton` (`.primary`/`.secondary`/`.destructive`, 50pt, optional
    `systemImage`, `fillsWidth`) replaces `PopupPrimaryButton` and `CardActionButton`;
    `BlockAction.iconName` is optional so only "Підтвердити" carries the ✓. New
    `RoundIconButton` (44/36pt, dims itself from `\.isEnabled`), `LargeTitleHeader`,
    `SectionLabel`, `.inputFieldStyle()`. Restyled: `BlockStatusPill` (tinted, with a dot),
    `ScreenHeader` (navbar with a round back button; `onBack` now required), `MonthHeader`,
    `WeekDayStrip`, `DashedSlot`, `PopupContainer` (ink 22% scrim, 28pt sheet), `IconBadge`
    (monochrome — `tint` is gone from it, `StatCard` and `StatsLinkRow`), `StatsTrendLabel`.
  - **Root tabs on `LargeTitleHeader` already**: Заявки, Статистика, Мої записи, Акаунт moved in
    M-27, because `ScreenHeader` became a 17pt navbar and their headings would otherwise have shrunk
    until their screen PR. Schedule and Booking draw their own headers (M-29/M-31).
  - **Popups keep two close shapes on purpose**: ✕ only on the informational `BlockDetailPopup`,
    a bottom text button paired with the primary action on the four form popups — the artboards
    draw exactly this, which settles the old "popups disagree" backlog item.
  - **Week strip trade-off, for M-29 to decide**: `WeekDayStrip` kept its 32pt prev/next chevrons
    (the artboard has none) because they are the only non-gesture way to change week; the cost is
    that seven flexible day cells come out ≈40pt wide on a 390pt screen and the chevrons are 32pt —
    both under the 44pt minimum, as before M-27. Options: 44pt chevrons with narrower cells, or no
    chevrons plus `accessibilityAdjustableAction` on the strip.
  - Reviewed with the SwiftUI Pro skill at plan stage; of its five findings three were applied
    (pill fill + stroke chain instead of an `if` overlay, the field-tap note, the week-strip note)
    and two were deliberately not (an `accessibilityLabel` on `CapsuleButton` while loading, `Label`
    instead of `Image` in `RoundIconButton`).
  - **Device-pass follow-ups** (commit `M-27 small fixes` + review fixes, 2026-10-06), decided
    screen by screen from device screenshots:
    - **Auth mode switch → footer link.** Five variants were compared on an HTML artifact; the black
      segment lost because it stacked a second black capsule over the submit button. `ModeSwitcher`
      is deleted; `ModeSwapPrompt` sits under the button ("Немає акаунта? **Зареєструватися**" /
      "Вже є акаунт? **Увійти**"). New keys `auth.swap.noAccount`/`auth.swap.haveAccount`;
      `auth.mode.signUp` removed as unused. A system `Picker(.segmented)` (Liquid Glass on iOS 26)
      was tried first and reverted — glass on a white page has nothing to refract.
    - **Wine accent**: `Wine` `#7D2E3E` and `WineSoft` `#F6E9EC`, explored on a Claude Design
      canvas. Applied by name, in small doses: the auth link, `IconBadge` (wine glyph on a flat
      `WineSoft` tile — Stats and Account), the expected-revenue amount, today's number in
      `WeekDayStrip`. **The tab bar stays ink** (user decision), so `AccentColor` stays `#0A0A0B`.
      Canvas-only ideas not built: client initials on request cards, a "Сьогодні" button, a
      current-time line, a dot after the wordmark, a focus ring on fields.
    - **Nothing readable as an object is flat**: both popup summaries moved from `.insetSurface` to
      `.cardSurface`, and `.insetSurface` was deleted. `SlotChip` is a white `.raisedSurface`
      (selected = ink + `brandShadow`, as an explicit `if`/`else`); the chip row uses
      `.scrollClipDisabled()` so shadows aren't clipped (an inner/outer padding variant was tried
      after review and reverted by the user). The offer chevron is a white raised circle instead of ink. The
      Account avatar is a top-lit raised circle (`Card` → ink 7% gradient, card shadow, contour).
    - `Background` became Display P3 (0.990, 1, 1).
    - Tried and reverted: a backdrop blur behind popups, and a wine `MeshGradient` page background.
    - Reviewed with SwiftUI Pro: `SlotChip`'s stacked layers, `ProfileCard`'s literal `1` and
      `Hairline`-as-fill were fixed; the clip stays. **Open**: `ModeSwapPrompt`'s `HStack` cannot
      wrap, so a long translation or large text truncates — `ViewThatFits` (HStack → VStack).
    - Still ink on purpose, for a later call: the "+" circle in Мої послуги is the last ink round
      button.

- **PR28 — Dark theme ("Темне вино") + appearance switcher** (commits prefixed `M-28`; the M-28
  Auth screen milestone it would have collided with was dropped).
  - **Palette**: every colorset has a dark appearance from the canvas page "Темний + темне вино"
    (`manik3-dark.css` + `manik3-merlot.css`): page `#0B080B`, card `#1F1A1F`, raised `#2C252C`,
    secondary text `#9C939B`, wine fill `#6B3442`, accent `#D7ADB5`, statuses from the base dark
    page. The light theme is pixel-identical except unavailable calendar days, which moved from
    `TextSecondary` to `TextTertiary` to match both canvas pages (user decision).
  - **Role tokens**: `Ink` was text, selected fill, shadow and backdrop at once, which cannot work
    in two themes. It is now text and glyphs only; the other roles got `PrimaryFill`/`OnPrimary`,
    `Raised`, `DestructiveFill`, `Shadow`, `Backdrop`, `HeaderFill` (booking header: ink in light,
    card tone in dark) and `Highlight`. `Primary` was avoided as a name because the generated
    `Color.primary` collides with SwiftUI's. The table lives in `code-style.md`.
  - **Depth in dark**: black shadows vanish on the near-black page, so after a device pass the
    surfaces got a top rim and a top-down sheen tinted with `Highlight` (clear in light).
  - **Switcher**: `AppAppearance` (System / Light / Dark) in `@AppStorage("appearance")`, applied by
    `.preferredColorScheme` on `RootView`, so it also covers Auth and survives sign-out. The light
    lock `INFOPLIST_KEY_UIUserInterfaceStyle` is gone. A round button next to the "Акаунт" and
    "Статистика" titles (new trailing slot in `LargeTitleHeader`) opens `AppearancePopup` — three
    rows, applies on tap, stays open.
  - **Tab bar**: the selected tab is `.tint(Color.ink)` (white in dark). Wine `#6B3442` and the
    canvas's `#D7ADB5` were both tried on a device and rejected. Tab content is re-tinted with the
    accent so the tint doesn't reach carets and pickers.
  - Deliberate canvas deviations: fields on `Raised` (a card-tone field vanishes in a card-tone
    popup), the "Вільно" pill keeps its outline, the booking header stays (the per-screen
    layout milestones were dropped), the
    free-day dot stays green, the unchecked checklist circle is `Ink`.
  - Fixed on the way: `AccountRow`'s hard-coded `.black` icon (black on black in dark) and the PR9
    bare-`Rectangle()` popup backdrop.
  - Reviewed with SwiftUI Pro (plan) and a whole-branch review. **Open, low impact**: no launch
    screen colour, so a theme choice opposite to the device's flashes the other theme at launch;
    `LargeTitleHeader` keeps its 12pt title-row spacing even without a trailing view.

- **PR29 — Slot creation: no overlaps, no double submit** (commits prefixed `M-29`, branch
  `feature/pr-29-Fix-slot-overlap`): closes the backlog items "Slot creation can overlap an
  existing block" and "`CreateBlockViewModel.submit()` can double-submit".
  - **Why it overlapped**: the popup always opened at `HH:00` for an hour, while an hour still
    offers "+ Додати вільний час" with up to 20 min taken; and the free-typed `HH:mm` fields were
    never checked against the day's blocks. `firestore.rules` cannot check this (rules can't query
    other documents), so the check is client-side only.
  - **Wheels instead of text fields**: hours | minutes `00/15/30/45`, start hours 8–21, end hours
    8–22 with only `00` at 22. One wheel is expanded at a time, by tapping the time. The free-text
    parsing (`*Text` + `didSet` + `parseTime`) is gone. A wheel was rejected in PR7 when it was a
    `UIDatePicker`/`DatePicker`; this one is two plain `Picker(.wheel)`s, which is what allows the
    15-minute step and the 8–22 range.
  - **Opening range**: the first free 15-minute mark of the tapped hour (block 10:00–10:15 →
    10:15); end = +60 min, capped by the next block — rounded *down* to the grid, because legacy
    blocks may start off it (10:50 → 10:45) — and by 22:00. Moving the start shifts the end by the
    same amount (user choice, like iOS Calendar), clamped to 08:00–22:00.
  - **Disabled "Створити" with a hint**: "Цей час уже зайнятий" when the range overlaps any block of
    the date selected in the popup (touching ends are fine), "Кінець має бути пізніше за початок"
    when end ≤ start. A Firestore error, if present, wins over the hint. The popup gets **all**
    blocks via `CreateBlockContext.blocks` because the date can change inside it; it is a snapshot
    taken on open (accepted: one master, one device).
  - **One overlap predicate**: `Models/Block/Block+Overlap.swift`, also used by the timeline
    cascade, which inlined the same formula. `WorkHours` gained `slotStepMinutes`,
    `openingMinutes`, `closingMinutes`; `DateFormat.storageTime(minutesOfDay:)` writes stored times.
  - **`ClockTime` instead of `Binding(get:set:)`** (SwiftUI Pro review): the wheels bind by key path
    to a small value type (`$time.hour` / `$time.minute`); the "22 → `00`" snap is a `didSet` on
    that plain struct, not on `@Observable` state.
  - **Double submit**: `guard isSaving == false` first in `submit()`. Reproducible only by calling
    `create(then:)` twice per tap — a real double tap lands on a button already disabled by
    `isLoading` one frame later — so this is a cheap guard, not a bug users could hit. The backlog
    wording ("a fast double tap can create two identical blocks") overstated it.
  - **Open**: side-by-side wheels may steal each other's drags (`.clipped()` clips drawing, not
    hit-testing) — needs a device check; fallbacks in order: `.contentShape(.rect)`, fixed
    per-column width + `.compositingGroup()`, then a `.menu` minutes column (system font — needs a
    user OK). Deferred minors from the whole-branch review: a stale Firestore error hides the time
    hint until the next submit; the popup doesn't scroll, so an open wheel (+150pt) can push
    "Створити" off a small screen with many services; the time buttons' VoiceOver label is only the
    time, not "Початок"/"Кінець".
  - Not a bug after all: the old backlog note "deleting a `confirmed` block has no confirmation
    step" was stale — `ScheduleView` already asks (`schedule.confirm.deleteBooked`).

- **M-30 — Remove the client side, one cabinet per master** (branch
  `feature/pr-30-Remove-client-side`; first PR of the pivot, item 9).
  - **Removed**: `Client/` (Запис, Мої записи, Акаунт) and `Master/Requests/` — 56 Swift files, `Role` and
    every role check, `UserRepository` (+ Firestore, fake), `ProfileEdit`, `BookingError`,
    `BlockRepository.book(...)` and `BookedService`, `SectionLabel`, the auth fakes, and 70 String
    Catalog keys (`account.*`, `booking.*`, `myBookings.*`, `requests.*`, four tab titles). The tab
    bar is Розклад / Статистика until M-32 adds Клієнтки.
  - **Every account is a master**: sign-up stays and writes `users/{uid}` as `name` + `email`;
    `UserProfile` has no `role` (old documents that still carry one decode fine — unknown keys are
    ignored). `AuthRepository` lost `reauthenticate`/`updatePassword`/`deleteAccount`.
  - **Independent cabinets**: services and blocks moved to `users/{uid}/services` and
    `users/{uid}/blocks`. `Firestore.userCollection(_:)` (`Services/Firestore/Firestore+UserCollection.swift`)
    builds the path from the signed-in user, so protocols, view models and screens are unchanged;
    with nobody signed in it throws (`observe…` streams just finish) instead of building an empty
    document path. `firestore.rules` is one `isOwner(uid)` gate on `users/{uid}` and below.
  - **Restore point for M-31**: the client cabinet's `ChangePassword`/`DeleteAccount` popups are
    in commit `12262eb` (and `main` at `98e8882`) under `Manik/Manik/Client/Account/` —
    `git show 98e8882:Manik/Manik/Client/Account/DeleteAccount/DeleteAccountViewModel.swift`.
  - Catalog cleanup was done as a text-level block removal (a JSON re-dump re-sorts keys
    differently from Xcode); `git diff --minimal` shows deletions only.
  - **By hand, in the Console — rules first, then the build**: deploy the new rules *before* running
    the M-30 build. Under the old rules a sign-up's `users/{uid}` write is rejected after the Auth
    account already exists, and that account is stuck (every sign-in hits `profileNotFound` and is
    signed out; signing up again says the email is taken) until it is deleted in the Console. Then
    delete the top-level `services`/`blocks`, every `users` doc but the master's, and those Auth
    accounts (all test data).
  - Conventions updated where their examples cited removed files; the rules themselves stand.
  - **Verified 2026-10-09**: rules deployed and test data wiped in the Console; on a device sign-in,
    both tabs, adding a service and a slot, and a second master signing up into an empty cabinet that
    doesn't see the first one's data.

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
5. ~~**Master — "Статистика" (Stats)**~~ — **done** (M-22, under "Done" above): month summary inside
   the `Master/Stats/StatsView.swift` shell PR10 created, plus the permanent entry point to "Мої
   послуги" replacing PR10's temporary text link. Two departures from what was planned here:
   - **Cancellations were dropped from the product**, not built and not deferred — nothing in the
     data model survives a cancellation. The MVP spec was edited to match.
   - **Four metrics were added** that this line never asked for: expected revenue, hours worked, free
     slots left, and a month-over-month comparison on money and clients. All four were already
     computable from `observeBlocks()` without a single new query.
6. ~~**Client — "Акаунт" (Account)**~~ — **done** (M-23 + M-24 + M-25, all three under "Done"
   above): profile, stats, and the actions block of three — "Змінити пароль", "Вийти", "Видалити
   акаунт". Designed as one screen shipping in three PRs; the design doc
   (`docs/superpowers/specs/2026-08-23-client-account-design.md`) was deleted once the third landed,
   per the throwaway-artifact rule in CLAUDE.md. Two departures worth keeping, since a reader would
   otherwise have to rediscover them from the code:
   - ~~**PR-A — profile**~~ — **done (M-23)**: name, email (read-only), phone, Instagram, Telegram,
     edited through one popup that writes `users/{uid}`, plus the whole "Статистика" section as UI
     sitting at `AccountStats.empty`.
   - ~~**PR-B — stats**~~ — **done (M-24)**: `AccountStats.make(blocks:clientId:now:)` fed by the
     existing `observeBlocks()` stream, replacing the temporary `stats:` init parameter. One
     departure from what was planned here: a visit is a `confirmed` block that has **ended**, not one
     that has started — the wording above (and in the design doc) predated M-22, which had already
     settled the same question as `endsAt <= now`. The rule was extracted to
     `Models/Block/Block+Completed.swift` so both cabinets read one predicate instead of two copies.
   - ~~**PR-C — security**~~ — **done (M-25)**: change password and delete account, plus the
     `users/{uid}` `allow delete` rule (deployed manually to the Console). One departure from what
     was planned here: `AuthRepository` gained **three** methods, not two — `reauthenticate(password:)`
     is its own call rather than living inside `deleteAccount`, because the spec's shape put the
     password check *after* the bookings were cancelled and the profile deleted, so a mistyped
     password would have destroyed both and still left the account alive.

7. **Light redesign** ("Новий дизайн" on the canvas; spec
   `docs/superpowers/specs/2026-10-05-light-redesign-design.md`). Layout follows the artboards, data
   stays as it is; the dark theme shipped separately in PR28 (see "Done").
   - ~~**M-27 — foundation**~~ — **done**, see "Done" above.
   - ~~**M-28…M-32 — per-screen layouts**~~ — **dropped** (user decision, 2026-10-07): after M-27
     and the dark theme the screens are close enough to the artboards; no further layout work is
     planned. The remaining canvas differences (e.g. the booking screen still has `BookingHeader`
     where the artboard has a large title) are accepted. Reopen screen by screen only on a product
     reason.

8. ~~**Next up, in order** (user priority, 2026-10-07)~~ — **superseded by item 9** (2026-10-09).
   Item 1 (slot overlap + double-submit) shipped as PR29; the rest was overtaken by the pivot.

9. **Pivot: a calendar for nail masters** (decided 2026-10-09; screens on the "Manik Screens"
   canvas, page "Тільки майстриня"; full design in
   `docs/superpowers/specs/2026-10-09-master-only-pivot-design.md`, the product summary in the MVP
   spec). Clients don't install an app to book one manicure, so the client cabinet goes and Manik
   becomes the master's own tool: a client base, free windows published as a stories image and as
   text, booking a client into a window, rescheduling, and personal plans in the same calendar.
   **Every master signs up and gets an independent cabinet** — her data lives under
   `users/{uid}/`, no roles, no salons. Firebase stays; existing Firestore data is test data, so
   there is no migration. One PR each, in this order, every one shippable:
   1. ~~**M-30 Remove the client side, one cabinet per master**~~ — **done** (under "Done"). `Client/`, Requests, roles;
      sign-up creates a master; `services`/`blocks` move under `users/{uid}/`; owner-only rules;
      tab bar Розклад / Статистика for one PR. Removal goes first so Клієнтки lands in the final
      tab bar instead of a throwaway fourth tab.
   2. **M-31 Master account** — forgot password, change password, delete account (wipes all her
      data); required by the App Store once sign-up exists. The client cabinet's
      `ChangePassword`/`DeleteAccount` popups are deleted in M-30 and restored from git history
      here (`git show <M-30 parent>:Manik/Manik/Client/Account/…`), rebuilt for the master.
   3. **M-32 Клієнтки** — `clients`, tab (Розклад / Клієнтки / Статистика), search,
      add/edit/delete, client card with Instagram DM (`ig.me/m/`) or call/SMS.
   4. **M-33 Windows** — `slots` (date + start time), new Розклад day list, Заповнити місяць;
      `Block`/`blocks` removed.
   5. **M-34 Booking** — book a client into a window (search + inline add), booking actions,
      history on the client card.
   6. **M-35 Publishing** — free windows as a 9:16 image (layout A) and as text, Надіслати прайс,
      favourite services, "Надіслати @нік".
   7. **M-36 Reschedule**.
   8. **M-37 Personal plans** — `events` + `eventTemplates` (Мої справи), weekly repeat, conflict
      warnings.
   9. **M-38 Statistics on slots**.

## Backlog and tech debt (unordered)

Not a queue. These accumulate as they're found and get picked up when they block a screen, or when
something nearby is already being touched. **No numbers on purpose** — cite them by name, since
numbering drifts every time an item is added or closed (it already did once: PR9's entry pointed at
"step 9" for what was item 10).

- **Verification emails don't reach ukr.net — own sender before release** (found 2026-10-10 during
  M-31's manual pass). With Firebase's default sender (`noreply@<project>.firebaseapp.com`) the
  verification email arrives at Gmail within a minute but never at `@ukr.net` — not in Inbox, Spam
  or search, after waiting and after "Надіслати ще раз" reported success (Firebase accepted the
  send; delivery fails afterwards). Not a code problem, and not a blanket ukr.net block of
  `firebaseapp.com`: the same mailbox did receive another product's Firebase verification email in
  Dec 2024. The app cannot detect delivery — Firebase only confirms the send. Fix in the Console,
  not in code, **before release** (Polish/Ukrainian masters use ukr.net, i.ua, meta.ua):
  - quick: Authentication → Templates → **SMTP settings** through a dedicated Gmail
    (`smtp.gmail.com:587`, STARTTLS, an app password; ~500 emails/day) — also the cheapest test of
    whether the sender is the cause;
  - proper: a domain we own — **Customize domain** with the DNS records (SPF/DKIM) Firebase shows,
    or an email service (Brevo, SendGrid) on that domain. The domain must be ours; an arbitrary
    name such as `manik.app` cannot be verified.
  - In the app, worth adding regardless: a "Не прийшов лист? Перевірте «Спам» або спробуйте іншу
    пошту" hint on the verify-email screen, and surfacing a failed first send (sign-up sends it
    with `try?`, so a rejected send is invisible).
- ~~**Three accessibility items left open on the account screen**~~ — **superseded by the pivot** (the client account is removed in M-30). (two from M-23's review, one from
  M-24's). None blocks a PR, all are one line each: the contact rows' SF Symbols are announced by
  VoiceOver ("phone. Телефон. +48 600 123 456") and want `.accessibilityHidden(true)`, since the
  label beside them already carries the meaning; a failed phone validation moves neither focus nor
  VoiceOver's cursor to the offending field, so the popup just appears not to close —
  `focusedField = .phone` when `submit()` returns `nil` on `showsPhoneError` fixes both at once; and
  M-24's `.redacted` placeholder on the stats tiles is a visual treatment only, so while the first
  snapshot is in flight VoiceOver still reads "0, Візити" and "—, Улюблена послуга" — precisely the
  untruth the redaction removes from the screen. `.accessibilityHidden(viewModel.hasLoadedStats ==
  false)` beside the existing modifier covers it without a new catalog key. Worth doing in whichever
  account PR is opened next rather than as a standalone change.
- ~~**Show the client's contacts to the master**~~ — **superseded by the pivot** (contacts live on the master's own client records (M-32, M-34)). (requested 2026-10-07, not yet ordered —
  see "Next up"). Today a client's phone / Instagram / Telegram appear only on
  her own «Акаунт»; the master sees them nowhere. Add them to «Заявки» cards and the Schedule's
  `BlockDetailPopup`, each tappable: `tel:` for the phone, `https://instagram.com/<handle>` and
  `https://t.me/<handle>` (universal links — they open the app if installed, Safari otherwise; no
  `LSApplicationQueriesSchemes` needed). Rules already let the master read `users/{uid}`, so no
  deploy. Build a URL only from a valid handle (letters, digits, `.`, `_`; the stored value already
  has `@` stripped) and fall back to plain text otherwise. `RequestsViewModel` already fetches
  client names per `clientId` (`fetchNames`) — extend that rather than adding a second lookup.
- ~~**Booking reminders for the client**~~ — **superseded by the pivot** (there is no client app to remind; out of scope). (requested 2026-10-07; approach undecided). The MVP spec
  lists push notifications and reminders as out of scope, so picking this up changes scope — update
  the spec's out-of-scope list in the same PR. Two approaches were weighed:
  - **Local notifications** (`UNUserNotificationCenter`, no server). The client's app schedules
    "tomorrow at 10:00 — <service>" when it sees her booking and removes it when the booking goes
    away. No APNs key, no paid plan, app-only code. Weakness: the app learns of changes only while
    it runs, so a booking the master confirms or cancels while the app stays closed leaves a missing
    or stale reminder. Mitigations: schedule already at `pending`, and reconcile all reminders on
    every launch / foreground. Recommended as the first step for a single salon.
  - **Real push** (FCM + scheduled Cloud Functions). Always reflects the current booking state, and
    the same pipe would carry "your booking was confirmed" and the master's "new request". Costs:
    an APNs key, the Firebase Blaze plan, server code (TypeScript), stored FCM tokens per user, and
    adopting the Firebase CLI the project deliberately avoids (rules are deployed by hand today).
  - Still to decide either way: when to remind (day before / a few hours before / both), and
    whether the client can turn it off.
- ~~**Rescheduling a booking**~~ — **superseded by the pivot** (redone for the new model as M-36 (a slot's date/time moves; no block-to-block transaction)). (requested 2026-10-07). Today there is none: blocks have only
  confirm / decline / cancel, and the rules pin `date`/`startTime`/`endTime` for the client. The
  workaround is cancel + book again. In this model a reschedule never edits a block's time — it
  **moves the booking from one block to another free block** in a single Firestore transaction:
  the old block goes back to `available`, the new one is booked with the same service snapshot
  (`bookedServiceId`/`Name`/`Price`).
  - **By the client** — "Перенести" on an upcoming booking in «Мої записи», then the existing
    date/slot picker. The new booking lands in `pending`, so **the master confirms it again**
    (user requirement). No rules change: each half of the transaction is already allowed on its
    own (`isClientCanceling()` on the old block, `isClientBooking()` on the new one). Decide what
    the master sees in «Заявки» — a plain new request, or one marked "перенесено з <old slot>"
    (the latter needs a field on `Block`, optional per `data-layer.md`).
  - **By the master** — "Перенести на…" in `BlockDetailPopup`, picking a free block. The master's
    writes are unrestricted by the rules. Open question: does the moved booking stay `confirmed`
    (the master chose it) or go back to `pending` for the client's consent? The user asked only
    that the master can do it, so `confirmed` is the working assumption. The client learns about it
    only when she opens the app — with no pushes, consider a visible "перенесено" marker on her
    booking card; this ties into the booking-reminders item.
  - Both paths must handle the target block being taken mid-transaction (the transaction fails;
    show the same "time taken" message as booking, and keep the old booking intact).
- ~~**Master: find a client by Instagram handle**~~ — **superseded by the pivot** (became the Клієнтки tab, M-32). (requested 2026-10-07). The master has no client
  list today — she meets clients only through their bookings. Wanted: type a handle, get the
  **client card + her bookings** (user choice over a plain filter or a bare client list).
  - **Card**: name and tappable contacts (shares the UI of the "Show the client's contacts to the
    master" item — build that first, then reuse it here), upcoming and past bookings for her
    `clientId` from the blocks the master already observes.
  - **Data**: no rules change — `allow read: if isMaster() || …` on `users/{uid}` also covers a
    list query by the master. For one salon the simplest search is to read the `role == "client"`
    profiles once and filter on device with `localizedStandardContains`, which also gives prefix
    and partial matches; a Firestore range query would need a normalized field. Instagram handles
    are case-insensitive but stored as typed (only `@` is stripped), so compare lowercased.
  - **Open**: where the entry point lives — a fourth master tab («Клієнтки»), or a search field on
    an existing screen (the master's tabs are Розклад / Заявки / Статистика). Whether search also
    matches name and phone, which is nearly free once the profiles are loaded.
- **Changing the email address is not offered.** The account screen (M-23) shows `email` read-only.
  Firebase requires verifying the new address before it takes effect, so `users/{uid}.email` and the
  Auth record can disagree for an unbounded window, and the UI has nowhere to show that pending
  state. Decided 2026-08-23 while specifying the account screen; revisit only if a client actually
  needs it.
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
  - The `price` audit that came with it is **also done**: at the time the `services` collection held
    a single document, written by a post-PR12 build (it already carried `isActive`), with
    `price: 1000` — whole, so it decodes into `Int` cleanly. No fractional prices existed to
    migrate. (By M-21 the collection holds **four** documents, all app-written, so the audit's
    conclusion still stands — but don't quote "a single document" as current fact.) Note this also
    means the "legacy document without `isActive`" case has no instance in the live database; the
    optional stays anyway, since a hand-made Console document would recreate it for free.
  - ~~**Re-deploy for M-21**~~ — **done (2026-08-23)**: the file gained `bookedService()` plus the
    snapshot checks in `isClientBooking()`/`isClientCanceling()`, and was published to the Console
    for project `manik-5a2b8`. The Console text was diffed against the local file and matches line
    for line. Order was deliberate and matters: the app shipped the two new fields **before** the
    rules began requiring them — publishing first would have broken booking between deploys.
  - ~~**Re-deploy for M-25**~~ — **done (2026-08-24)**: `users/{uid}` gained
    `allow delete: if isSignedIn() && request.auth.uid == uid`, published to the Console for project
    `manik-5a2b8` and diffed against the local file line for line. Published **before** the app
    shipped, unlike M-21: the rule only permits something previously denied, so early is safe and
    late would ship a broken delete button.
  - **Both halves were verified in the Rules Playground** (2026-08-23), and it is worth recording
    that only the pair proves anything: a correct snapshot → *allowed*; the same request with
    `bookedServicePrice: 1` → *denied*. Three earlier "denied" results were false positives, each
    from a different cause, and each looked like success:
    - the seeded blocks' `offeredServiceIds` point at `svc-classic`/`svc-hybrid`/
      `svc-gel-correction`, which are **preview fixture ids that do not exist in `services`** — so
      `bookedService()`'s `get()` returned null and the rule errored out before ever comparing a
      price. (Real service ids are Firestore auto-ids.)
    - the Playground's document builder is typed: `offeredServiceIds` entered as a `string` rather
      than an `array`, or `bookedServicePrice` as a `string` rather than `int64`, fails an unrelated
      comparison. Check the grey JSON preview for brackets and for the absence of quotes around the
      price before trusting a result.
    - `clientId` typed by hand differed from `request.auth.uid` by `I` vs `l`, which the Console
      font renders identically. Copy the uid from the auth payload into both places.
  - **The builder resets on every open** — nine fields per run, no JSON paste, no retained state.
    That is the argument for `@firebase/rules-unit-testing` against the local emulator if rules
    verification ever needs repeating; it would also mean adopting the Firebase CLI, which this
    project deliberately does not have. Not scoped — noted so the next person doesn't rediscover the
    cost from scratch.
- ~~**Duration on offer cards and booking confirmation**~~ — **superseded by the pivot** (the client booking screens are removed in M-30). (raised by the light redesign). The
  artboards show "1 год" on the client's offer cards and in the confirmation popup; `Service` has
  no duration field since PR11. A slot's length is derivable from its block, but that is new
  presentation logic, not styling, so the redesign does not build it.
- **Popup scrim blur** (dropped from the light redesign). The artboards blur the backdrop by 3px;
  on iOS 18 that means a `Material` with its own tint, and 3px is barely visible.
- **Input fields focus only on their text line** (found in M-27's SwiftUI Pro review).
  `.inputFieldStyle()` pads 15/16pt around a `TextField`/`SecureField`, which hit-tests only its
  text frame, so tapping the padding does nothing. Predates M-27 (it was the same with 12pt). A fix
  needs a `FocusState`-aware field, which changes the modifier's API.
- **Deleting a block rewrites past revenue** (created by M-22). The master can swipe away a completed
  `confirmed` block in the Schedule, and last month's reported income changes retroactively with no
  trace. Same shape as the existing "deleting a `confirmed` block has no confirmation step" item, and
  they should probably be fixed together — but note a confirmation dialog only slows the mistake
  down; keeping history intact would mean not hard-deleting a block that has already happened.
- **Stats reads the entire `blocks` collection** (created by M-22). `observeBlocks()` has no date
  filter, which is exactly what makes every figure on the Stats screen free — no new query, no new
  index, no rules change. The flip side is that the screen's cost grows with the salon's whole
  history, and `StatsCalculator` makes six passes over it on every snapshot and every 60-second tick.
  Fine for one salon today; revisit with a date-bounded query if a season's worth of blocks ever
  makes it noticeable. Deliberately not pre-optimized.
- **"Забули пароль?"**: decide tappable-stub vs. real `sendPasswordReset` flow, then implement.
  (Was tracked as a task in a now-disconnected MCP tool — re-track here instead.)
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
  - M-22 added three, all declined by the same precedent: the icon badges in `StatCard`/`StatsLinkRow`
    are decorative but not `.accessibilityHidden(true)`, so VoiceOver reads the raw SF Symbol name
    before the metric's label; `StatsTrendLabel`'s arrow reads as its own element ("arrow up, 18%,
    до минулого місяця"); and the metric cards are multi-`Text` stacks with no
    `.accessibilityElement(children: .combine)`, matching the PR11/PR17 decisions.
  - PR19 added one more, and it is the same shape: every card in «Заявки» carries a "Підтвердити"
    and a "Відхилити" button, so a queue of requests reads to VoiceOver as several identically
    labelled pairs with no way to tell which request each belongs to. Fix is an `accessibilityLabel`
    naming the client and the slot on both buttons. Declined in PR19 by the same precedent.
- **Schedule week navigation keeps the weekday instead of landing sensibly** (reported 2026-10-07).
  `WeekDayStrip.shiftWeek` adds ±7 days to the selected date (`WeekDayStrip.swift:45`), so Thursday
  the 8th becomes Thursday the 15th; and since tabs keep their state, returning to «Розклад» keeps
  whatever day was last selected. Wanted:
  - switching week (arrows and swipe alike) lands on the **first day of the week**, or on **today**
    when the target week contains it — one static rule in `WeekDayStrip`, e.g.
    `landingDate(forWeekStarting:today:)`;
  - **switching back to the «Розклад» tab resets to today**. Do it in `MasterRootView` with
    `.onChange(of: selectedTab)` calling a `ScheduleViewModel.showToday()`, not with `.onAppear` in
    `ScheduleView` — `onAppear` can also fire when a slot / block popup closes, which would yank the
    master off the day she is working on. Re-tapping the already active tab doesn't reset.
  - Master-only: the client's calendar is the month grid, `WeekDayStrip` has no other caller.
  Verify on a device: Thu 8 → next week = Mon 12; back to this week = today; swipe = arrows;
  Розклад → Заявки → Розклад = today; closing a popup on another day keeps that day.
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
  - M-22 added three instances, none new in kind — all three already existed elsewhere, which is why
    nothing was changed for them: `MasterRootView` now builds a **third** `@MainActor` view model
    from a nonisolated property initializer (`@State private var statsViewModel = StatsViewModel()`);
    `[Block]` crosses the `AsyncStream` boundary from the Firestore listener into a `@MainActor` view
    model for the fourth time, and `Block` is not `Sendable` because `@DocumentID` is not; and
    `MonthHeader` takes `@MainActor` methods as plain `() -> Void`, losing the global actor on
    conversion, exactly as `BookingDatesView` has passed `viewModel.goToPreviousMonth` since PR14.
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
- ~~**A booking points at a service by reference, so editing the service rewrites history**~~ —
  **done in M-21** (see its entry under "Done"). Shipped exactly as the receipt pattern below
  describes, including the cross-document `get()` in the rules; the "master stamps on confirm"
  alternative was rejected for the reason named here. Kept in full because the reasoning is the
  design record. The **soft-delete half-measure below is no longer needed for this problem** — the
  snapshot survives a hard delete, so hard-deleting services stays fine; revisit soft delete only if
  some other feature wants the document to survive. Original wording follows. (raised
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
- ~~**`permissionDenied` now means two different things, and the client is told the wrong one**~~ — **superseded by the pivot** (client booking is removed in M-30).
  (created by M-21, 2026-08-23). `FirestoreBlockRepository.book` maps any `permissionDenied` to
  `BookingError.slotUnavailable` → «Цей час уже зайняли» (PR15's mapping, which was accurate when
  the only client-facing rule was `resource.data.status == "available"`). M-21 added a second way to
  fail the same rule: if the master edits the service's name or price while the confirm popup is
  open, the snapshot the client is about to write no longer matches the service document, the write
  is denied — and she is told her time was taken, which is a lie. The slot is still free.
  - Narrow window (popup open across a master edit) and no data damage — she can retry and the
    second attempt carries the fresh snapshot. Filed so the wrong message isn't mistaken for a
    booking bug later.
  - **Deletion is the same window and fails harder**: if the service document is gone,
    `bookedService()`'s `get()` returns null, `.data` errors, and the rule denies — again reported as
    "time taken". Confirmed in the Playground on 2026-08-23, where blocks pointing at non-existent
    service ids denied for exactly this reason. Unreachable through the UI (a deleted service leaves
    the offer list, so it can't be picked), but reachable across an open popup.
  - The fix belongs with the **`AsyncThrowingStream` / real domain error types** item above: one
    `permissionDenied` cannot be split apart at the `NSError` level, so distinguishing "slot taken"
    from "price changed" needs the rules failure to carry more than a status code, or a re-read of
    the block before mapping. Don't add a second guess-by-heuristic mapping inside the repository.
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
  - **The PR17/PR18/PR19 artifacts were deleted on 2026-08-23**, once M-17/M-18/M-19/M-20 were all
    on `main`: `plans/2026-08-17-client-my-bookings.md`,
    `specs/2026-08-17-client-my-bookings-design.md`,
    `plans/2026-08-17-client-booking-cancellation.md`,
    `plans/2026-08-21-master-requests.md`, `specs/2026-08-21-master-requests-design.md`.
    Everything from them that outlives a branch is folded into the PR17/PR18/PR19 entries above.
  - **Still on disk, pending the merge of their branches**:
    `plans/2026-08-22-booking-service-snapshot.md` and
    `specs/2026-08-22-booking-service-snapshot-design.md` (M-21) — delete both once
    `feature/pr21-Booking-service-snapshot` lands on `main`;
    `plans/2026-08-23-master-stats.md` and `specs/2026-08-23-master-stats-design.md` (M-22) — same,
    once `feature/pr22-Master-stats` lands. M-22's own plan told the final task to delete them
    immediately; that was wrong and was not followed — `CLAUDE.md` says "implemented **and merged**",
    which is also why M-21's pair is still here. M-22's plan file now opens with a **superseded**
    banner: the same-day refinement pass changed the card fill, extracted `CardSurface`/`IconBadge`,
    moved `StatsRoute` and split the calculator, so its code blocks no longer describe the tree. The
    banner points here rather than rewriting the plan — a plan records what was planned, and
    back-dating it would erase the fact that those four decisions were made *after* review.
- **Currency is settled: `PLN`, whole units only.** The design mockup showed грн, but the salon
  works in the Polish time zone; `ServiceFormat.currencyCode` stays `"PLN"`. Decided 2026-08-07,
  before PR11 put a price field in front of the user — don't reopen without a product reason. PR12
  additionally settled the *type*: `Service.price` is `Int`, formatted with `.fractionLength(0)`,
  and the form uses `.numberPad`. Groszy are not representable by design; if the salon ever needs
  them, switch to minor units (`Int` groszy), not back to `Double`.
- **Three PR9 review findings were reviewed and declined** — don't re-raise them: popup buttons'
  44pt tap target (modifiers sit outside the `Button`), `PopupContainer`'s bare `Rectangle()`
  backdrop in dark mode, and `BlockDetailPopup`'s default `FirestoreBlockRepository()` reaching
  live Firestore from `ScheduleView`'s preview. **The dark-mode one was reopened** (device testing
  after PR12 showed the same root cause makes typed text invisible) **and fixed in PR28**: the
  backdrop is the `Backdrop` token and every colorset has a dark appearance.
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
