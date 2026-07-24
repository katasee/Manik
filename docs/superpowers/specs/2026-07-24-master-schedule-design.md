# Master — Schedule (Розклад) — Design Spec

Date: 2026-07-24
Status: Approved
Branch: `feature/pr-5-scheduleView`

## Мета

Перший реальний екран кабінету майстра (таб "Розклад" з `docs/superpowers/specs/2026-07-15-manik-mvp-design.md`):
день-стрічка тижня зверху + погодинний таймлайн обраного дня знизу, з картками
`pending`/`confirmed` записів.

## Скоуп цієї ітерації

**Тільки перегляд.** Не входить:

- Тап на порожню годину / форма створення нового блоку (`offeredServiceIds` тощо) —
  окремий наступний спек.
- Редагування чи скасування існуючого блоку з цього екрана.

## Архітектура і компоненти

Нова feature-папка `Manik/Manik/Master/Schedule/`:

- **`ScheduleView.swift`** — кореневий екран: `WeekDayStrip` зверху + `HourlyTimelineView`
  знизу в `ScrollView`.
- **`ScheduleViewModel.swift`** (`@MainActor @Observable`) — тримає `blocks: [Block]`
  (з `observeBlocks()`), `services: [Service]` (з `observeServices()`),
  `selectedDate: Date`, кеш `profileCache: [String: UserProfile]`. Обчислює
  `blocksForSelectedDate` фільтрацією локально (підхід A, нижче).
- **`WeekDayStrip.swift`** — горизонтальна стрічка 7 днів обраного тижня, свайп для
  гортання тижнів вперед/назад, підсвітка обраного дня + окрема позначка "сьогодні".
- **`HourlyTimelineView.swift`** — вертикальна сітка годин `ScheduleMetrics.workingHours`,
  картки блоків позиціонуються/розтягуються пропорційно до `startTime`/`endTime`.
- **`ScheduleBlockCard.swift`** — картка запису (ім'я клієнтки, статус-пілюля, назва
  обраної послуги); тап відкриває `ScheduleBlockDetailSheet` (read-only).
- **`ScheduleBlockDetailSheet.swift`** — sheet із повною інформацією про блок.
- **`ScheduleMetrics.swift`** — робочі години, висота години в пунктах, паддінги/кольори
  картки (як `AuthMetrics`).

Новий репозиторій (окремий від `AuthRepository` — auth описує дії користувача над
собою, читання чужого профілю за uid — інша відповідальність):

- **`Services/Repositories/UserRepository.swift`**:
  ```swift
  protocol UserRepository {
      func fetchProfile(uid: String) async throws -> UserProfile
  }
  ```
- **`Services/Firestore/FirestoreUserRepository.swift`** — тонка обгортка над
  `db.collection("users").document(uid).getDocument(as:)`.

## Потік даних

1. `ScheduleView.task` запускає дві паралельні підписки: `for await` на
   `observeBlocks()` і на `observeServices()`, кожна оновлює відповідний
   `@Observable`-масив у `ScheduleViewModel`.
2. При зміні `selectedDate` ViewModel фільтрує `blocks` по
   `date == DateFormat.date(selectedDate)`.
3. Для кожного блоку зі `clientId != nil`, якщо профілю немає в `profileCache`,
   ViewModel асинхронно викликає `userRepository.fetchProfile(uid:)` і кладе результат
   у кеш — картка показує ім'я, як тільки прийде відповідь (до того — плейсхолдер).
4. `bookedServiceId` резолвиться в назву послуги пошуком у вже завантаженому `services`
   (без додаткового запиту).

**Підхід до завантаження блоків (A, обрано):** перевикористовуємо наявний
`observeBlocks()` як є (він і зараз тягне всю колекцію `blocks` реалтайм-листенером),
фільтрація по тижню/дню — локально в `ScheduleViewModel`. Без змін у
`BlockRepository`, без нових Firestore-запитів/індексів. Для одного майстра й
обсягів MVP цього достатньо; якщо колекція розростеться, можна пізніше перейти на
запит з діапазоном дат без зміни решти архітектури.

## Робочі години

Фіксований діапазон `08:00–22:00`, константа `ScheduleMetrics.workingHours = 8..<22`
(не залежить від того, чи є блоки в кожній годині; не налаштовується майстром у UI).

## Візуальна частина

**WeekDayStrip**: 7 однакових колонок (літера дня + число). Обраний день — темна
капсула (`Color.textPrimary` фон, білий текст, той самий стиль і
`matchedGeometryEffect`-слайд, що й активний сегмент у `ModeSwitcher`). "Сьогодні"
(якщо не обраний) — тонка обвідка `Color.surface` замість заливки. Свайп над
стрічкою зсуває `selectedWeekStart` на ±7 днів; заголовок над стрічкою показує
діапазон тижня.

**HourlyTimelineView**: ліва колонка — підписи годин (`08:00…21:00`) з фіксованою
висотою рядка (`ScheduleMetrics.hourHeight`), праворуч — `ZStack` з горизонтальними
розділювачами на кожну годину. Картки `pending`/`confirmed` блоків позиціонуються
офсетом `(startMinutes - workStart) / 60 * hourHeight` і мають висоту
`(endMinutes - startMinutes) / 60 * hourHeight` — пропорційні до тривалості, можуть
перекривати межу години. Блоки зі статусом `available` окремою карткою не малюються —
просто порожнє місце.

**ScheduleBlockCard**: фон `Color.surface`, статус-пілюля
(`Color.statusPending` #CC6E00 / `Color.statusConfirmed` #008C0E, локалізований текст
"Очікує"/"Підтверджено"), ім'я клієнтки (`.elmsSans(.semiBold)`), назва послуги
(`.elmsSans(.regular)`, `Color.textSecondary`). Поки ім'я/послуга не резолвнулись з
кешу — `Color.surface`-плейсхолдер (redacted-стиль).

**ScheduleBlockDetailSheet**: read-only — ім'я клієнтки, час, послуга, статус. Жодних
дій (без редагування/скасування).

## Обробка помилок і edge cases

- **Перший лоад**: поки жоден снепшот від `observeBlocks()`/`observeServices()` ще не
  прийшов — `ProgressView` на весь екран замість таймлайну.
- **Профіль клієнтки не резолвився**: картка показує фолбек "Клієнтка" замість
  вічного скелетона — не блокує рендер решти розкладу.
- **Порожній тиждень/день**: жодних карток у таймлайні — нічого додатково не
  малюємо (без "тут порожньо" плашки).

## Тестування

Тест-таргету немає (CLAUDE.md) — перевірка через Xcode Previews з фейковими
`BlockRepository`/`ServiceRepository`/`UserRepository` (той самий патерн, що в
`AuthView`/`RootView` превью), покриваючи: порожній день, день з кількома блоками
різної тривалості що перекриваються по висоті, pending+confirmed поруч.
