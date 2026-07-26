# Master — Schedule: Create Free-Time Slot — Design Spec

Date: 2026-07-26
Status: Approved
Branch: `feature/pr-7-createFreeSlot`

## Мета

Перший наступний крок після PR5 (view-only Schedule shell): зробити пунктирний
"+ Додати вільний час" (`DashedSlot`) в `HourlyTimelineView` активним — тап відкриває
форму, яка створює новий `Block` зі статусом `available` через
`BlockRepository.addBlock(_:)`. Це крок 1 з `docs/plan.md` → "Next steps".

## Скоуп цієї ітерації

**Тільки створення нового вільного слоту.** Не входить:

- Приховування "+" для годин, де вже є блок — вирішиться природно в наступному кроці
  (рендер `pending`/`confirmed` карток на таймлайні), коли з'явиться концепція "чи ця
  година вже зайнята блоком".
- Перевірка на накладання блоків одне на одне — за спеком (`2026-07-15-manik-mvp-design.md`)
  майстер сам відповідає за коректність своїх блоків, автоматичної валідації в MVP нема.
- CRUD-екран "Мої послуги" — це окремий майбутній крок (план, крок 3, вхід через
  "Статистика"). На цій ітерації 4 реальні послуги (Манікюр гібридний (гель-лак),
  Класичний манікюр, Корекція гелем, Френч) заносяться **вручну через Firebase Console**
  у колекцію `services` — той самий тимчасовий підхід, що вже використовується для
  призначення ролі майстра вручну. Чекліст послуг у попапі читає `services` наживо,
  тож коли CRUD з'явиться, коду міняти не треба.

## Архітектура і компоненти

Продовжуємо feature-папку `Manik/Manik/Master/Schedule/`. Перший крок роботи —
`git stash pop` вже готового стешу з PR5 (`ScheduleViewModel`, `UserRepository`,
`FirestoreUserRepository`, `ScheduleBlockCard`, `ScheduleBlockDetailSheet`,
`SchedulePreviewData`, оновлені `DateFormat`/`HourlyTimelineView`/`ScheduleView`) —
він уже підписаний на `observeServices()`/`observeBlocks()`, потрібні для чекліста
послуг у цій фічі.

Нові файли:

- **`CreateBlockPopup.swift`** — кастомне модальне вікно по центру екрана: затемнений
  фон (`Color.black.opacity(...)`) на весь екран + `RoundedRectangle`-картка з
  контентом. **Не** системний `.sheet` (той патерн лишається за
  `ScheduleBlockDetailSheet` — компактний перегляд знизу). Закривається лише кнопками
  "Скасувати"/"Створити" в картці — тап поза карткою на затемнений фон нічого не
  робить. Локальний для `Master/Schedule/`, не в `UICommons` (виносити туди, лише якщо
  знадобиться десь ще, напр. підтвердження скасування запису).
- **`CreateBlockViewModel.swift`** (`@MainActor @Observable`) — власна відповідальність,
  окремо від `ScheduleViewModel` (форма введення, а не спостереження за даними — та сама
  логіка поділу, що між `AuthViewModel`/`RootViewModel`). Стан:
  ```swift
  var date: Date
  var startTime: Date
  var endTime: Date
  var selectedServiceIds: Set<String>
  ```
  Валідація: `endTime > startTime`. Створення блоку: конвертує `date`/`startTime`/
  `endTime` через `DateFormat.date`/`DateFormat.time` (storage-формати, `en_US_POSIX`) у
  `Block(date:, startTime:, endTime:, offeredServiceIds: Array(selectedServiceIds),
  status: .available)`, викликає `blockRepository.addBlock(_:)`.

`CreateBlockPopup` отримує від `ScheduleView`/`ScheduleViewModel` як звичайні дані
(без прямого доступу до `ScheduleViewModel`, той самий підхід, що вже задокументований
для `ScheduleBlockCard`/`ScheduleBlockDetailSheet`):

- `services: [Service]` — вже завантажені батьківською `ScheduleViewModel`, без
  окремого Firestore-запиту в попапі.
- `initialDate: Date` — обраний день у `WeekDayStrip`.
- `initialStartHour: Int` — година тапнутого рядка.
- `onCreated: () -> Void` — закриває попап після успішного створення (новий блок
  прилітає в `ScheduleView` автоматично через уже активний `observeBlocks()`, без
  ручного рефрешу).

## Потік даних / взаємодія

1. Майстер тапає `DashedSlot` навпроти, скажімо, рядка "17:00" у `HourlyTimelineView`.
2. `HourlyTimelineView.swift:12` зараз викликає `DashedSlot(..., action: {})` — порожнє
   замикання. Замінюється на замикання, яке повідомляє `ScheduleView`, яку годину
   тапнули; `ScheduleView` встановлює стан презентації попапу (наприклад
   `@State private var creatingBlockHour: Int?`).
3. `ScheduleView` показує `CreateBlockPopup` як оверлей (`ZStack`/`.overlay`, не
   `.sheet`), з дефолтами: `initialDate` = поточний `selectedDate`, `initialStartHour`
   = тапнута година; `CreateBlockViewModel.endTime` дефолтить на `startTime + 30 хв`.
4. Майстер за бажанням міняє дату/час (тап на будь-який з 3 рядків розгортає нативний
   `DatePicker` — SwiftUI `.compact`-стиль робить це вбудовано, без додаткового коду) і
   відмічає чекбоксами потрібні послуги.
5. "Створити" → валідація → `addBlock(_:)` → `onCreated()` закриває попап. "Скасувати"
   → закриває попап без запису.

## Візуальна частина

**Рядки дати/часу**: 3 окремі рядки — "Дата", "Початок", "Кінець" — кожен нативний
SwiftUI `DatePicker` (`.compact` стиль): показує вже заповнене значення (напр.
"Субота, 25 липня" / "17:00"), тап розгортає стандартне wheel-колесо вибору. Крок
вибору часу — 15 хвилин (`.datePickerStyle(.compact)` + мінутний degree крок через
`minuteInterval` на UIKit-рівні; SwiftUI `DatePicker` не має прямого API для цього —
деталь реалізації для плану, не для цього спека).

**Чекліст послуг**: список назв `services` із чекбоксом навпроти кожної (звичайний
`Toggle` або кастомна checkbox-view), без опису/ціни — просто назва, як у мокапі.
Список автоматично росте/змінюється разом із колекцією `services` у Firestore.

**Картка попапу**: `RoundedRectangle` (кутовий радіус — взяти з існуючих
`ScheduleMetrics`/дизайн-токенів, не хардкодити нове значення), `Color.surface` фон,
кнопки "Скасувати"/"Створити" внизу картки.

## Обробка помилок і edge cases

- **`endTime <= startTime`**: кнопка "Створити" неактивна (disabled), без окремого
  повідомлення про помилку.
- **`addBlock` кидає помилку** (мережа/Firestore): попап лишається відкритим,
  показується інлайн-повідомлення про помилку під кнопками (той самий підхід, що в
  `AuthView`).
- **Жодної послуги не вибрано**: дозволити створення з порожнім `offeredServiceIds`
  (майстер може донабрати послуги пізніше) чи вимагати мінімум одну — **рішення:
  вимагати мінімум одну обрану послугу**, кнопка "Створити" неактивна, поки
  `selectedServiceIds` порожній (блок без жодної дозволеної послуги марний для
  клієнтки — нічого бронювати).

## Тестування

Тест-таргету немає (CLAUDE.md) — перевірка через Xcode Previews з фейковим
`BlockRepository` (той самий патерн, що в `AuthView`/`ScheduleBlockCard`), покриваючи:
порожній чекліст послуг (disabled "Створити"), кілька обраних послуг, стан помилки
після невдалого `addBlock`.
