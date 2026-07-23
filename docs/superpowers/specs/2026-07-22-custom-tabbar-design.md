# Custom Tab Bar — Design Spec

Date: 2026-07-22
Status: Approved

## Мета

Кастомний floating таббар — плаваюча темна капсула з іконками, де активна іконка сидить у білому
колі, яке виступає над верхнім краєм капсули. Спільний компонент для обох кабінетів: 3 таби в
майстра (Розклад / Заявки / Статистика), 2 таби в клієнтки (Запис / Мої записи). Референс —
скріншот мокапу, наданий користувачем (темна капсула, іконка-дзвоник з червоним бейджем "2",
активна іконка статистики у білому колі, що частково виступає над капсулою).

## Скоуп

- Побудувати переиспользуваний `CustomTabBar` компонент.
- Підключити його в `MasterRootView` (3 таби) та `ClientRootView` (2 таби).
- Контент під табами лишається текстовою заглушкою (як зараз) — реальні екрани (Розклад, Заявки,
  Статистика, Запис, Мої записи) це наступні окремі пункти `docs/plan.md`, не частина цієї задачі.
- Бейдж-лічильник на "Заявки" — тільки візуальна підтримка (параметр `Int?`), завжди `nil` зараз.
  Живе підключення до кількості `pending`-блоків з `BlockRepository` — окрема майбутня задача в
  кінці плану, не тут.

## Архітектура

Без generic-протоколу — два конкретні `enum`, кожен у власному файлі, плюс один не-generic
таббар, що перемикається по ролі кабінету. Простіше, ніж generic `TabBarTab`, і не вводить
абстракцію заради двох конкретних типів (YAGNI).

- **`Master/MasterTab.swift`** — власний файл:
  ```swift
  enum MasterTab: CaseIterable, Identifiable {
      case schedule, requests, stats
      var id: Self { self }
      var systemImage: String { ... }        // calendar / bell / slider.horizontal.3
      var titleKey: LocalizedStringKey { ... }  // ключ локалізації
  }
  ```
- **`Client/ClientTab.swift`** — власний файл, аналогічно:
  ```swift
  enum ClientTab: CaseIterable, Identifiable {
      case booking, myBookings
      var id: Self { self }
      var systemImage: String { ... }        // calendar / list.bullet.clipboard
      var titleKey: LocalizedStringKey { ... }
  }
  ```
- **`TabBar/CabinetKind.swift`** — власний файл, зв'язує таббар з конкретним кабінетом:
  ```swift
  enum CabinetKind {
      case master(selection: Binding<MasterTab>, badge: (MasterTab) -> Int?)
      case client(selection: Binding<ClientTab>)
  }
  ```
- **`TabBar/CustomTabBar.swift`** — не-generic view: `CustomTabBar(kind: CabinetKind)`.
  `body` перемикається по `kind` (`switch`), для кожного випадку ітерує `allCases` відповідного
  enum-а і рендерить `TabBarButton` на кожен таб. `@Namespace` тут же — передається в кожен
  `TabBarButton` для анімованого переміщення білого кола (`matchedGeometryEffect`).
- **`TabBar/TabBarButton.swift`** — власний файл, одна кнопка-таб, не-generic:
  ```swift
  struct TabBarButton: View {
      let systemImage: String
      let titleKey: LocalizedStringKey
      let isActive: Bool
      let badge: Int?
      let namespace: Namespace.ID
      let action: () -> Void
  }
  ```
  Іконка без видимого текстового підпису (як на референсі), але через
  `Button(titleKey, systemImage: systemImage, action: action).labelStyle(.iconOnly)`
  — текстовий лейбл лишається доступним для VoiceOver, лише візуально прихований, а не
  `.accessibilityLabel()` на голому `Image`.

Це узгоджується з `docs/plan.md`: компонент не feature-specific, тому не в
`Assets/UICommons/` (там зараз лежать суто дрібні extensions/modifiers), а в власній папці
`TabBar/` поруч з `Master/`, `Client/`, `Auth/` — за конвенцією "організація по фічі".

## Візуальна специфікація

- **Капсула:** `Capsule()`, суцільна заливка кольором `TabBarBackground` (новий асет, темний,
  майже чорний — на зразок референсу). Висота піла ~52pt. Горизонтальний padding від країв екрана
  ~24pt. Розміщення floating над контентом, з відступом ~12–16pt від нижньої safe area.
- **Активний таб:** біле коло (`TabBarActiveBackground`, новий асет, майже чистий білий) з
  діаметром більшим за висоту капсули (~56pt), центр кола лежить на верхньому краю капсули — тому
  верхня частина кола візуально "випирає" над пілом. Іконка всередині кола — темна
  (`Color.textPrimary`).
- **Неактивні таби:** іконка напряму на темному фоні капсули, світлого/напівпрозорого відтінку
  (`TabBarActiveBackground.opacity(0.6)` або подібне — уточнити при імплементації, орієнтуючись на
  референс).
- **Бейдж:** маленьке коло кольором `Badge` (вже існує в Assets, коралово-червоний) з білою
  цифрою, `.offset` зверху-справа від іконки. З'являється лише коли `badge(tab) != nil`.
- Два нові кольори в `Assets.xcassets`:
  - `TabBarBackground` — темна капсула.
  - `TabBarActiveBackground` — біле коло активного таба.

  (Проєктна конвенція: усі кольори йдуть через семантичні asset-кольори, ніде немає літералів
  `Color.white`/`Color.black`/`Color(red:...)` — тому нові UI-токени, а не перевикористання
  існуючих `TextPrimary`/`FieldBackground`, які семантично про інше.)
- **Tap-area:** кожен `TabBarButton` має `.frame(minWidth: 44, minHeight: 44)` на весь
  тапабельний хітбокс, навіть якщо сама іконка/коло візуально менші — мінімум Apple HIG.
- **Reduce Motion:** `CustomTabBar` читає `@Environment(\.accessibilityReduceMotion)`. Коли
  `true`, переміщення білого кола між табами не ковзає через `matchedGeometryEffect` зі
  spring-анімацією, а робиться opacity-кросфейдом на місці кожного таба (без переміщення).

## Інтеграція

- `MasterRootView`: `@State private var selectedTab: MasterTab = .schedule`, layout —
  `ZStack(alignment: .bottom) { <заглушковий контент, що змінюється по selectedTab>; CustomTabBar(kind: .master(selection: $selectedTab, badge: { _ in nil })) }`.
  Заглушка — той самий текст, що є зараз (назва кабінету + ім'я + вихід), можливо з додаванням
  назви поточного таба для видимості перемикання під час рев'ю.
- `ClientRootView`: аналогічно, `@State private var selectedTab: ClientTab = .booking`,
  `CustomTabBar(kind: .client(selection: $selectedTab))`.
- Бейдж-параметр підключений через `CabinetKind.master`'s `badge` closure, завжди повертає `nil`
  на цьому етапі (`.master(selection: $selectedTab, badge: { _ in nil })`), без
  залежності від `BlockRepository`.

## Тестування / верифікація

Тест-таргету в проєкті немає (per `CLAUDE.md`). Верифікація:
1. `xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build` — має пройти
   без помилок.
2. SwiftUI Preview для `CustomTabBar` (обидва варіанти — 3-таб і 2-таб) та для
   `MasterRootView`/`ClientRootView` — перевірити анімацію перемикання, вигляд бейджа, capsule
   overflow вручну в canvas/simulator.

## Явно поза скоупом цієї задачі

- Реальні екрани Розклад/Заявки/Статистика/Запис/Мої записи — окремі наступні пункти плану.
- Живий лічильник pending-заявок для бейджа — окрема майбутня задача (додається в кінець
  `docs/plan.md`).
