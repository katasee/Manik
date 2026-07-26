# Master — Schedule: Create Free-Time Slot — Design Spec

Date: 2026-07-26 (last synced to shipped code: 2026-07-27)
Status: Shipped
Branch: `feature/pr-7-createFreeSlot`

## Мета

Наступний крок після PR5 (view-only Schedule shell): зробити пунктирний
"+ Додати вільний час" (`DashedSlot`) в `HourlyTimelineView` активним — тап відкриває
попап, який створює новий `Block` зі статусом `available` через
`BlockRepository.addBlock(_:)`.

## Скоуп цієї ітерації

**Тільки створення нового вільного слоту.** Не входить:

- Приховування "+" для годин, де вже є блок — вирішиться природно в наступному кроці
  (рендер `pending`/`confirmed` карток на таймлайні), коли з'явиться концепція "чи ця
  година вже зайнята блоком". У поточній реалізації кожна робоча година завжди показує
  "+", незалежно від наявних блоків.
- Перевірка на накладання блоків одне на одне — за спеком (`2026-07-15-manik-mvp-design.md`)
  майстер сам відповідає за коректність своїх блоків, автоматичної валідації в MVP нема.
- CRUD-екран "Мої послуги" — це окремий майбутній крок (`docs/plan.md`, крок 2, вхід
  через "Статистика"). На цій ітерації 4 реальні послуги (Манікюр гібридний (гель-лак),
  Класичний манікюр, Корекція гелем, Френч) мали заноситись вручну через Firebase
  Console у колекцію `services`. **Тимчасово це обійдено інакше:** `MasterRootView`
  зараз (`#if DEBUG`) підмінює реальний `ServiceRepository` на
  `FakeServiceRepository(services: SchedulePreviewData.services)`, тож у DEBUG-збірці
  чекліст завжди показує ці 4 захардкожені послуги, а не те, що реально в Firestore.
  Це свідомий, тимчасовий стан — прибрати разом із кроком 2 плану (CRUD послуг), коли
  Firestore матиме реальні дані.

## Архітектура і компоненти

Feature-папка розрослася до 11 файлів у плоскому `Master/Schedule/` і була розбита на
підпапки:

- **`Master/Schedule/`** (корінь фічі "Розклад"): `ScheduleView`, `HourlyTimelineView`,
  `ScheduleMetrics`, `SchedulePreviewData` (`#if DEBUG` sample `Service` дані).
- **`Master/Schedule/CreateBlock/`** (вкладена міні-фіча "створення слоту"):
  `AddNewSlotBlock` (сам попап; кілька разів перейменовувався — `CreateBlockPopup` →
  `AddNewSlotBlock`), `CreateBlockContext` (`Identifiable`-payload для презентації),
  `CreateBlockViewModel`, `ServicesChecklist`.
- **`Services/Fakes/`**: `FakeBlockRepository`, `FakeServiceRepository` — переїхали сюди
  з `Master/Schedule/` (це загальні дублери репозиторіїв, а не щось специфічне для
  розкладу; знадобляться і `Client/Booking` пізніше).

`CreateBlockFieldRow` (окрема generic `View`-структура для рядка "лейбл + контрол") була
введена, а потім **згорнута назад** у приватний метод `AddNewSlotBlock.fieldRow(_:control:)`
— мала рівно одного споживача (сам попап) без реальної потреби в переюзності, тож окремий
файл/generic-тип додавав накладні витрати без користі (YAGNI).

`MinuteIntervalTimePicker` (`UIViewRepresentable` над `UIDatePicker`, для кроку 15 хв) теж
був доданий, а потім **повністю видалений**: спочатку замінений на нативний
`DatePicker(displayedComponents: .hourAndMinute)` (без кроку хвилин), а тоді — на ручний
текстовий ввід (див. нижче), тож обгортка над UIKit більше не потрібна.

`CreateBlockViewModel` (`@MainActor @Observable`) — окрема відповідальність від будь-якої
"спостерігальної" view model (аналогічний поділ, що між `AuthViewModel`/`RootViewModel`).
Стан:
```swift
var date: Date
var startTime: Date
var endTime: Date
var startTimeText: String   // "HH:mm", ручний ввід — didSet парсить у startTime
var endTimeText: String     // "HH:mm", ручний ввід — didSet парсить у endTime
var selectedServiceIds: Set<String>
var errorMessage: String?
var isSaving: Bool
```
Валідація: `canSubmit == (endTime > startTime && !selectedServiceIds.isEmpty)`.
`isSelected(_:)`/`toggleSelection(of:)` — логіка вибору послуг живе тут, а не як
`Binding(get:set:)` у view (уникнутий антипатерн). `submit()` конвертує `date`/
`startTime`/`endTime` через `DateFormat.date`/`DateFormat.time` (storage-формати,
`en_US_POSIX`) у `Block(id: nil, ..., status: .available, ...)`, викликає
`blockRepository.addBlock(_:)`.

`AddNewSlotBlock` отримує від `ScheduleView` (через `CreateBlockContext`) як звичайні
дані — `date`, `startHour`, `services: [Service]` (уже завантажені `ScheduleView`, без
окремого Firestore-запиту в попапі) — і колбек `onDismiss: () -> Void`.

## Потік даних / взаємодія

1. Майстер тапає `DashedSlot` навпроти якогось рядка години в `HourlyTimelineView`.
   `HourlyTimelineView` викликає `onTapHour(hour)`.
2. `ScheduleView` не показує попап сам — повідомляє нагору через
   `onCreateSlotRequested: (CreateBlockContext) -> Void`, збираючи в `CreateBlockContext`
   поточну обрану дату, тапнуту годину, і **вже завантажені** `services` (захоплені в
   момент тапу — якщо `observeServices()` ще не встиг доставити перший снепшот, чекліст
   у попапі буде порожнім; відомий, прийнятий для MVP edge case).
3. **`MasterRootView`** (не `ScheduleView`!) тримає `@State private var
   creatingBlockContext: CreateBlockContext?` і рендерить `AddNewSlotBlock` як верхній
   шар свого `ZStack` (після `CustomTabBar`). Це навмисно піднято на рівень
   `MasterRootView`, бо це єдине місце зі спільним `ZStack`, що охоплює і контент
   Schedule, і плаваючий `CustomTabBar` — попап, показаний лише всередині `ScheduleView`,
   рендерився б *позаду* таб-бару (той малюється останнім у `MasterRootView.body` і
   тому завжди зверху) і лишав би його тапабельним поки попап відкритий.
4. Показ/приховування анімується вручну через `withAnimation(.easeOut(duration: 0.2))`
   навколо присвоєння `creatingBlockContext` (не системний `.sheet`/`.fullScreenCover` —
   обидва пробувались і були відкинуті, див. "Візуальна частина").
5. Майстер редагує дату (тап на "Дата" розгортає нативний `DatePicker`), вручну вписує
   час у "Початок"/"Кінець" (текстові поля, формат "17:30"), відмічає чекбоксами послуги.
6. "Створити" → валідація → `addBlock(_:)` → `onDismiss()` закриває попап. "Скасувати",
   або тап на затемнений фон навколо картки, теж закриває без запису.

## Візуальна частина

**Презентація попапу**: спершу спробували системний `.fullScreenCover(item:)` (щоб
безкоштовно отримати правильний z-order над таб-баром) — але в нього фіксована системна
анімація "виїзд знизу", яку неможливо змінити публічним API. Оскільки потрібен був
fade+scale по центру, презентацію замінили на кастомний `ZStack`-оверлей, піднятий у
`MasterRootView` (див. потік даних, крок 3) — це дало і потрібний z-order, і повний
контроль над анімацією.

**Фон попапу**: спершу суцільний `Color.black.opacity(0.4)` — замінений на
`Rectangle().fill(.ultraThinMaterial).opacity(0.9)` (розмиття контенту позаду, як у
системних sheet/popover, замість плаского затемнення). Фон **не** анімується
(з'являється/зникає миттєво); анімується (`.opacity.combined(with: .scale(scale: 0.92))`)
лише картка. Тап на фон закриває попап — реалізовано як `Button` (не `onTapGesture`,
щоб коректно читалось VoiceOver), з `.accessibilityLabel` рівним ключу
"schedule.createSlot.cancel".

**Тінь картки**: `.brandShadow()` (спільний `View+BrandShadow.swift`, той самий, що на
вибраному дні в `WeekDayStrip` і кнопці в `AuthView`) — обов'язково після
`.compositingGroup()`, інакше SwiftUI малює тінь кожному дочірньому елементу картки
окремо (тексту, роздільнику) замість одної тіні навколо зовнішньої рамки.

**Рядки дати/часу**: 3 рядки — "Дата", "Початок", "Кінець", кожен через приватний метод
`AddNewSlotBlock.fieldRow(_:control:)` (лейбл + контрол). "Дата" — нативний
`DatePicker(displayedComponents: .date)` (тап розгортає стандартний wheel). "Початок"/
"Кінець" — **не** DatePicker і не колесо: звичайний `TextField` для ручного вводу у
форматі "17:30" (`.keyboardType(.numbersAndPunctuation)`), розпарсюється в
`CreateBlockViewModel` (`startTimeText`/`endTimeText` `didSet` → парсинг "HH:mm" →
оновлення `startTime`/`endTime`; невалідний/неповний ввід під час набору просто
ігнорується, не оновлюючи дату, поки рядок знову не стане валідним). Дефолтна тривалість
при відкритті попапу — **1 година** (`ScheduleMetrics.CreatePopup.defaultDurationMinutes
= 60`).

**Чекліст послуг**: `ServicesChecklist` — кожна послуга як повнорядковий `Button`
(не `Toggle`, щоб уникнути `Binding(get:set:)` у view-тілі), іконка
`checkmark.circle.fill`/`circle`, мінімум 44pt висоти рядка (accessibility). Читає
`services`, передані ззовні як прості дані — список автоматично росте/змінюється разом
із джерелом (Firestore або, зараз тимчасово, `FakeServiceRepository`).

**Картка попапу**: `RoundedRectangle` (`ScheduleMetrics.CreatePopup.cornerRadius`),
`Color.background` фон, кнопки "Скасувати"/"Створити" внизу картки, обидві з
`.frame(minHeight: 44)`.

## Обробка помилок і edge cases

- **`endTime <= startTime`**: кнопка "Створити" неактивна (disabled), без окремого
  повідомлення про помилку.
- **`addBlock` кидає помилку** (мережа/Firestore): попап лишається відкритим,
  показується інлайн-повідомлення про помилку під кнопками (той самий підхід, що в
  `AuthView`); текст помилки — сирий `error.localizedDescription`, без локалізації.
- **Жодної послуги не вибрано**: кнопка "Створити" неактивна, поки `selectedServiceIds`
  порожній (блок без жодної дозволеної послуги марний для клієнтки — нічого бронювати).
- **`services` порожній у момент відкриття попапу** (снепшот `observeServices()` ще не
  прийшов): чекліст порожній, "Створити" лишається неактивною без пояснювального
  повідомлення — відомий, прийнятий edge case.
- **Невалідний/неповний текст у "Початок"/"Кінець"** під час набору (напр. "17:"): просто
  не оновлює `startTime`/`endTime`, поки рядок знову не стане валідним "HH:mm" —
  без повідомлення про помилку.

## Тестування

Тест-таргету немає (CLAUDE.md) — перевірка через Xcode Previews з фейковими
`BlockRepository`/`ServiceRepository` (`Services/Fakes/`), покриваючи: порожній чекліст
послуг (disabled "Створити"), кілька обраних послуг, стан помилки після невдалого
`addBlock`.
