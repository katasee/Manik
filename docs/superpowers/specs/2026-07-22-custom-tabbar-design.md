# Custom Tab Bar — Design Spec

Date: 2026-07-22
Status: Approved

## Мета

Кастомний floating таббар — плаваюча темна капсула з іконками, де активна іконка сидить у білому
колі, яке виступає над верхнім краєм капсули. Спільний компонент для обох кабінетів: 3 таби в
майстра (Розклад / Заявки / Статистика), 3 таби в клієнтки (Запис / Мої записи / Акаунт). Референс —
скріншот мокапу, наданий користувачем (темна капсула, іконка-дзвоник з червоним бейджем "2",
активна іконка статистики у білому колі, що частково виступає над капсулою).

## Скоуп

- Побудувати переиспользуваний `CustomTabBar` компонент.
- Підключити його в `MasterRootView` (3 таби) та `ClientRootView` (3 таби — третій, "Акаунт", поки
  що порожній екран-заглушка, `EmptyView()`).
- Контент під табами лишається текстовою заглушкою (як зараз) — реальні екрани (Розклад, Заявки,
  Статистика, Запис, Мої записи, Акаунт) це наступні окремі пункти `docs/plan.md`, не частина цієї
  задачі.
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
      case booking, myBookings, account
      var id: Self { self }
      var systemImage: String { ... }        // calendar / list.bullet.clipboard / person.crop.circle
      var titleKey: LocalizedStringKey { ... }
  }
  ```
  `account` рендериться в `ClientRootView` як порожній `EmptyView()` — реальний контент екрана
  Акаунт це окремий майбутній пункт плану.
- **`TabBar/CustomTabBar.swift`** — `CabinetKind` живе в цьому ж файлі (не окремим файлом —
  трохи завеликий формалізм для 6-рядкового enum з єдиним споживачем):
  ```swift
  enum CabinetKind {
      case master(selection: Binding<MasterTab>, badge: (MasterTab) -> Int?)
      case client(selection: Binding<ClientTab>)
  }
  ```
  Не-generic view: `CustomTabBar(kind: CabinetKind)`. `body` перемикається по `kind` (`switch`),
  для кожного випадку ітерує `allCases` відповідного enum-а і рендерить `TabBarButton` на кожен
  таб. `@Namespace` тут же — передається в кожен `TabBarButton` для анімованого переміщення
  білого кола (`matchedGeometryEffect`).
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
  На відміну від початкового задуму (icon-only, підпис лише для VoiceOver), підпис (`titleKey`)
  рендериться візуально під іконкою — `Image` + `Text(titleKey)` у `VStack`, а не
  `Button(titleKey, systemImage:, action:).labelStyle(.iconOnly)`. `Image` позначена
  `.accessibilityHidden(true)`, бо її сенс дублює видимий підпис — інакше VoiceOver озвучив би
  кнопку двічі.
- **`TabBar/TabBarActiveIndicator.swift`** — окремий `View`, винесений із `TabBarButton` (замість
  computed `some View` property): світле коло позаду іконки активного таба,
  `matchedGeometryEffect(id: "activeTabCircle", in: namespace)` для анімованого переміщення між
  табами. Рендериться лише коли `isActive == true`.
- **`TabBar/TabBarMetrics.swift`** — власний файл, один `enum` із вкладеними `Size`/`Spacing`/
  `Offset`/`Opacity`/`AnimationStyle` — усі фіксовані розміри/відступи/анімації таббару в одному
  місці (`Double`, не `CGFloat` — Swift бриджить їх автоматично поза optional/`inout`
  контекстами).

Це узгоджується з `docs/plan.md`: компонент не feature-specific, тому не в
`Assets/UICommons/` (там зараз лежать суто дрібні extensions/modifiers), а в власній папці
`TabBar/` поруч з `Master/`, `Client/`, `Auth/` — за конвенцією "організація по фічі".

## Візуальна специфікація

- **Капсула:** `Capsule()`, суцільна заливка кольором `Color.ink` (перейменований з `TextPrimary`
  — тепер загальний темний UI-токен, а не лише колір тексту; той самий майже чорний тон, що й
  раніше). Висота фіксована — `capsuleHeight = 70`pt (`TabBarMetrics.Size`), навмисно не
  self-sizing: `CustomTabBar` явно задає `.frame(height: capsuleHeight)`. Горизонтальний padding
  від країв екрана — `capsuleHorizontalPadding = 20`pt. Розміщення floating над контентом, з
  відступом `bottomInset = 8`pt від нижньої safe area.
- **Активний таб:** коло кольором `Color.background` (перевикористаний існуючий світлий фоновий
  колір застосунку, а не окремий "чистий білий" асет), діаметр `activeCircleDiameter = 70`pt —
  дорівнює `capsuleHeight`, а не більший за неї, як планувалось спочатку: щоб влізти в фіксовану
  70pt капсулу разом з видимим підписом, іконка/коло довелось зменшити (`iconSize = 24`pt,
  замість початкового задуму з великим колом на всю капсулу). Візуальне "випирання" над пілом
  реалізоване не розміром кола, а окремим `liftOffset` — весь `TabBarButton` (іконка + підпис)
  зсувається вгору на `activeCircleLift = 25`pt, коли активний. Іконка всередині кола — темна
  (`Color.ink`).
- **Неактивні таби:** іконка напряму на темному фоні капсули, світлого/напівпрозорого відтінку
  (`Color.background.opacity(0.55)`, `Opacity.inactiveIcon`).
- **Підпис (caption):** видимий текст під іконкою для всіх табів (не лише VoiceOver), `Font.elmsSans(.medium, captionFontSize)`, `captionFontSize = 9`pt — суттєво менше стандартного
  `.caption`, свідомий компроміс під фіксовану 70pt висоту капсули; без Dynamic Type scaling.
- **Бейдж:** маленьке коло кольором `Badge` (вже існує в Assets, коралово-червоний) з білою
  цифрою, діаметр `badgeDiameter = 14`pt, `.offset(x: badgeX = 9, y: badgeY = -7)` від кута
  іконки. З'являється лише коли `badge(tab) != nil`.
- Кольорів для таббару окремо не додавали — свідомо перевикористали два вже наявних асети
  (`Ink`, перейменований з `TextPrimary`; `Background`) замість окремих `TabBarBackground`/
  `TabBarActiveBackground`, щоб не плодити майже дублюючі один одного кольори в палітрі.
- **Tap-area:** кожен `TabBarButton` — `.frame(maxWidth: .infinity, maxHeight: .infinity)`, тобто
  розтягується на всю ширину/висоту свого слоту в капсулі (70pt висотою), а не лише на
  content-hugging розмір іконки+підпису — так тап-зона надійно перевищує мінімум Apple HIG 44×44,
  навіть для неактивних табів з дрібнішим візуальним вмістом.
- **Reduce Motion:** свідомо не підтримується — `@Environment(\.accessibilityReduceMotion)` та
  opacity-кросфейд для `TabBarActiveIndicator` були в першій ітерації, але видалені за прямим
  запитом: `matchedGeometryEffect`-переміщення кола програється для всіх користувачів однаково.

## Інтеграція

- `MasterRootView`: `@State private var selectedTab: MasterTab = .schedule`, layout —
  `ZStack(alignment: .bottom) { <заглушковий контент, що змінюється по selectedTab>; CustomTabBar(kind: .master(selection: $selectedTab, badge: { _ in nil })) }`.
  Заглушка — той самий текст, що є зараз (назва кабінету + ім'я + вихід), можливо з додаванням
  назви поточного таба для видимості перемикання під час рев'ю.
- `ClientRootView`: аналогічно, `@State private var selectedTab: ClientTab = .booking`,
  `CustomTabBar(kind: .client(selection: $selectedTab))`. Контент — `switch selectedTab`: для
  `.booking`/`.myBookings` той самий текстовий placeholder, для `.account` — `EmptyView()`.
- Бейдж-параметр підключений через `CabinetKind.master`'s `badge` closure, завжди повертає `nil`
  на цьому етапі (`.master(selection: $selectedTab, badge: { _ in nil })`), без
  залежності від `BlockRepository`.

## Тестування / верифікація

Тест-таргету в проєкті немає (per `CLAUDE.md`). Верифікація:
1. `xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build` — має пройти
   без помилок.
2. SwiftUI Preview для `CustomTabBar` (обидва варіанти — master 3-таб і client 3-таб) та для
   `MasterRootView`/`ClientRootView` — перевірити анімацію перемикання, вигляд бейджа, capsule
   overflow вручну в canvas/simulator.

## Явно поза скоупом цієї задачі

- Реальні екрани Розклад/Заявки/Статистика/Запис/Мої записи — окремі наступні пункти плану.
- Живий лічильник pending-заявок для бейджа — окрема майбутня задача (додається в кінець
  `docs/plan.md`).
