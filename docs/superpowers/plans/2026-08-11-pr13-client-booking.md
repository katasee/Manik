# PR13 — Клієнт: список доступних послуг + перехід на екран дат

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** клієнт відкриває таб «Запис» і бачить послуги, для яких у майстра є майбутні вільні
блоки, з найближчою датою для кожної; тап по картці веде на екран вибору дати, поки що порожній.

**Architecture:** MVVM + Repository, як у решті застосунку. Одна `@Observable` view-модель
підписується на наявні `observeBlocks()` / `observeServices()` і перебудовує похідний стан у
`didSet`. Уся недетермінована логіка («які послуги доступні», «коли найближчий термін», «що вже
в минулому») винесена в чисте `BookingAvailability`, яке приймає `now: Date` параметром.
Firestore, репозиторії й `firestore.rules` **не змінюються взагалі** — PR тільки читає.

**Tech Stack:** SwiftUI (iOS 17.2+), Swift Observation (`@Observable`), Firebase Firestore
(через наявні протоколи репозиторіїв), String Catalog.

**Чого в цьому PR свідомо немає:** чипів часу на картці, попапа підтвердження, будь-якого запису
в Firestore, екрана «Мої записи». Запис не працює — флоу обривається на порожньому екрані дат.
Це усвідомлений розріз на вимогу власника продукту; чипи не додаємо саме тому, що без попапа
підтвердження вони нікуди не ведуть.

## Global Constraints

- **Немає тест-таргета.** Перевірка кожної задачі — `#Preview` в Xcode Canvas; фінальна перевірка
  всього PR — `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`.
  Білд запускає **користувач** — не робити цього без прямої вказівки.
- **Коміти робить користувач.** У плані немає кроків `git commit`; після кожної задачі — стоп на рев'ю.
- Шрифт **тільки** `Font.elmsSans(_:_:)` — ніяких `.font(.system)`, `.bold()`, `.fontWeight()`.
- Усі користувацькі рядки — в `Manik/Manik/Localizable/Localizable.xcstrings`, `en` + `uk`,
  у тій самій задачі, що вводить рядок. Ключі — `booking.*`.
- Виклик із 3+ аргументами — по одному аргументу на рядок.
- **Жодних коментарів у Swift-коді.**
- Дати/часи — тільки через `DateFormat`, ніколи інлайновим `DateFormatter`.
- Гроші — `Int`, рендер через `ServiceFormat.price(_:)`.
- View-моделі створюються в `ClientRootView.body` (він `@MainActor`); `init(viewModel:)` у View
  **обов'язковий**, без дефолту — дефолтний репозиторій живе тільки в `init` самої view-моделі.

## Файлова структура

Створюємо:

| Файл | Відповідальність |
|---|---|
| `Manik/Manik/Models/Block+StartDate.swift` | `Block.startsAt: Date?` — склеює `date` + `startTime` |
| `Manik/Manik/Client/Booking/BookingSlot.swift` | вільний слот: `id` блоку, дата, час + лейбли |
| `Manik/Manik/Client/Booking/ServiceOffer.swift` | послуга + її майбутні слоти |
| `Manik/Manik/Client/Booking/BookingAvailability.swift` | чисті обчислення доступності |
| `Manik/Manik/Client/Booking/BookingViewModel.swift` | стан екрана «Запис» |
| `Manik/Manik/Client/Booking/BookingView.swift` | екран «Запис» |
| `Manik/Manik/Client/Booking/BookingMetrics.swift` | лейаут-константи фічі |
| `Manik/Manik/Client/Booking/Components/BookingHeader.swift` | чорна шапка з привітанням і пілюлею |
| `Manik/Manik/Client/Booking/Components/ServiceOfferCard.swift` | картка послуги |
| `Manik/Manik/Client/Booking/Dates/BookingDatesView.swift` | порожній екран вибору дати (наповнить PR14) |
| `Manik/Manik/Client/Booking/Preview/BookingPreviewData.swift` | блоки + послуги для прев'ю |
| `Manik/Manik/Assets.xcassets/FreeSlot.colorset/` | зелений маркер вільного часу |

Змінюємо:

| Файл | Що саме |
|---|---|
| `Manik/Manik/Utilities/DateFormat.swift` | + `dateTime`, `dayMonth`, `dayMonthShort` |
| `Manik/Manik/Client/ClientRootView.swift` | роутинг на реальний екран «Запис», вихід переїжджає в «Акаунт» |
| `Manik/Manik/Localizable/Localizable.xcstrings` | 8 нових ключів |

Не чіпаємо: `Services/**` (жодного рядка), `firestore.rules`, `FakeBlockRepository`
(read-only прев'ю вистачає наявного `struct`).

## Ключі локалізації (повний список)

Формат запису в `.xcstrings` — як у наявних ключів:
`{"localizations": {"en": {"stringUnit": {"state": "translated", "value": "..."}}, "uk": {...}}}`.
`sourceLanguage` файлу — `uk`.

| Ключ | uk | en |
|---|---|---|
| `booking.greeting` | `Вітаємо, %@` | `Welcome, %@` |
| `booking.title` | `На що записуємось?` | `What are we booking?` |
| `booking.nearestWindow` | `Найближче вікно · %@` | `Next opening · %@` |
| `booking.section.services` | `Послуги` | `Services` |
| `booking.card.nearest` | `Найближче` | `Soonest` |
| `booking.empty.title` | `Немає вільних термінів` | `No free slots` |
| `booking.empty.message` | `Майстер ще не відкрив вільний час. Зазирніть пізніше.` | `The master hasn't opened any slots yet. Check back later.` |
| `booking.dates.title` | `Оберіть дату` | `Pick a date` |

---

### Task 1: Доменний шар доступності

**Files:**
- Modify: `Manik/Manik/Utilities/DateFormat.swift:4-8`
- Create: `Manik/Manik/Models/Block+StartDate.swift`
- Create: `Manik/Manik/Client/Booking/BookingSlot.swift`
- Create: `Manik/Manik/Client/Booking/ServiceOffer.swift`
- Create: `Manik/Manik/Client/Booking/BookingAvailability.swift`

**Interfaces:**
- Consumes: `Block`, `Service`, `DateFormat` (наявні).
- Produces: `Block.startsAt: Date?`; `BookingSlot(id:date:startTime:)` з `dayLabel`/`shortDayLabel`/`timeLabel`;
  `ServiceOffer(service:slots:)` з `nearestSlot: BookingSlot?`;
  `BookingAvailability.offers(blocks:services:now:) -> [ServiceOffer]`;
  `BookingAvailability.nearestSlot(blocks:now:) -> BookingSlot?`.

- [ ] **Крок 1: додати три форматери в `DateFormat`**

У `Manik/Manik/Utilities/DateFormat.swift` після рядка `static let monthYear = displayFormatter("LLLL y")` додати:

```swift
    static let dateTime = storageFormatter("yyyy-MM-dd HH:mm")
    static let dayMonth = displayFormatter("d MMMM")
    static let dayMonthShort = displayFormatter("d MMM")
```

`dateTime` — storage (пінить `en_US_POSIX`), бо парсить те, що лежить у Firestore.
`dayMonth`/`dayMonthShort` — display (`Locale.current`), бо йдуть на екран.

- [ ] **Крок 2: `Block.startsAt`**

Створити `Manik/Manik/Models/Block+StartDate.swift`:

```swift
import Foundation

extension Block {
    var startsAt: Date? {
        DateFormat.dateTime.date(from: "\(date) \(startTime)")
    }
}
```

- [ ] **Крок 3: `BookingSlot`**

Створити `Manik/Manik/Client/Booking/BookingSlot.swift`:

```swift
import Foundation

struct BookingSlot: Identifiable, Hashable {
    let id: String
    let date: String
    let startTime: String

    var timeLabel: String {
        DateFormat.displayTime(startTime)
    }

    var dayLabel: String {
        label(with: DateFormat.dayMonth)
    }

    var shortDayLabel: String {
        label(with: DateFormat.dayMonthShort)
    }

    private func label(with formatter: DateFormatter) -> String {
        guard let day = DateFormat.date.date(from: date) else { return date }

        return formatter.string(from: day)
    }
}
```

- [ ] **Крок 4: `ServiceOffer`**

Створити `Manik/Manik/Client/Booking/ServiceOffer.swift`:

```swift
struct ServiceOffer: Identifiable, Hashable {
    let service: Service
    let slots: [BookingSlot]

    var id: String { service.id ?? service.name }

    var nearestSlot: BookingSlot? { slots.first }

    static func == (lhs: ServiceOffer, rhs: ServiceOffer) -> Bool {
        lhs.id == rhs.id && lhs.slots == rhs.slots
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
```

`Hashable` потрібен для `navigationDestination` у задачі 4; `Service` сам по собі не
`Hashable`, тому рівність зводимо до `id` + слотів вручну.

**Слоти тут — усі майбутні слоти послуги, не лише з найближчої дати.** У PR13 картка
показує тільки `nearestSlot` (для підпису «НАЙБЛИЖЧЕ · дата»), але екран дат у PR14
працюватиме з повним списком, і різати його зараз означало б переписувати обчислення потім.

- [ ] **Крок 5: `BookingAvailability`**

Створити `Manik/Manik/Client/Booking/BookingAvailability.swift`:

```swift
import Foundation

enum BookingAvailability {
    static func offers(
        blocks: [Block],
        services: [Service],
        now: Date
    ) -> [ServiceOffer] {
        let upcoming = upcoming(in: blocks, now: now)

        return services
            .compactMap { service in offer(for: service, among: upcoming) }
            .sorted(by: soonestFirst)
    }

    static func nearestSlot(blocks: [Block], now: Date) -> BookingSlot? {
        upcoming(in: blocks, now: now).first.flatMap(slot)
    }

    private static func offer(for service: Service, among upcoming: [Block]) -> ServiceOffer? {
        guard let serviceId = service.id else { return nil }

        let slots = upcoming
            .filter { $0.offeredServiceIds.contains(serviceId) }
            .compactMap(slot)

        guard slots.isEmpty == false else { return nil }

        return ServiceOffer(service: service, slots: slots)
    }

    private static func upcoming(in blocks: [Block], now: Date) -> [Block] {
        blocks
            .filter { $0.status == .available }
            .filter { $0.offeredServiceIds.isEmpty == false }
            .filter { block in (block.startsAt.map { $0 > now }) ?? false }
            .sorted { lhs, rhs in
                lhs.date == rhs.date
                    ? lhs.startMinutes < rhs.startMinutes
                    : lhs.date < rhs.date
            }
    }

    private static func slot(_ block: Block) -> BookingSlot? {
        guard let id = block.id else { return nil }

        return BookingSlot(
            id: id,
            date: block.date,
            startTime: block.startTime
        )
    }

    private static func soonestFirst(_ lhs: ServiceOffer, _ rhs: ServiceOffer) -> Bool {
        guard
            let left = lhs.nearestSlot,
            let right = rhs.nearestSlot
        else { return false }

        if left.date != right.date { return left.date < right.date }
        if left.startTime != right.startTime { return left.startTime < right.startTime }

        return lhs.service.name.localizedStandardCompare(rhs.service.name) == .orderedAscending
    }
}
```

Сортування дат порівнянням рядків коректне саме тому, що storage-формат `yyyy-MM-dd` /
`HH:mm` лексикографічно збігається з хронологічним порядком.

Фільтра «тільки `isOffered`» тут навмисно немає: доступність визначають блоки, а
дезактивована послуга, що лишилась в `offeredServiceIds` уже створеного блоку, має
показуватись — рішення PR12.

- [ ] **Крок 6: перевірка**

Окремого прев'ю немає — немає даних. Логіка перевіряється кроком 2 задачі 2.

---

### Task 2: Прев'ю-дані

**Files:**
- Create: `Manik/Manik/Client/Booking/Preview/BookingPreviewData.swift`

**Interfaces:**
- Consumes: `BookingAvailability`, `BookingSlot`, `ServiceOffer` (задача 1).
- Produces: `BookingPreviewData.services`, `.blocks`, `.reference`, `.clientId`.

- [ ] **Крок 1: прев'ю-дані**

Створити `Manik/Manik/Client/Booking/Preview/BookingPreviewData.swift`. Дати рахуємо від
однієї опорної точки, щоб прев'ю не «протухало»:

```swift
import Foundation

#if DEBUG
enum BookingPreviewData {
    static let reference = Date.now

    static let clientId = "preview-client"

    static let services: [Service] = [
        Service(id: "svc-classic", name: "Класичний манікюр", price: 450, isActive: true),
        Service(id: "svc-gel", name: "Манікюр + гель-лак", price: 750, isActive: true),
        Service(id: "svc-pedicure", name: "Педикюр класичний", price: 600, isActive: true),
        Service(id: "svc-extension", name: "Нарощення", price: 1500, isActive: true)
    ]

    static let blocks: [Block] = [
        block(id: "b1", dayOffset: 1, start: "10:00", end: "11:00", services: ["svc-classic", "svc-gel"]),
        block(id: "b2", dayOffset: 1, start: "11:00", end: "12:00", services: ["svc-classic", "svc-gel"]),
        block(id: "b3", dayOffset: 1, start: "15:00", end: "16:00", services: ["svc-classic", "svc-gel", "svc-pedicure"]),
        block(id: "b4", dayOffset: 4, start: "09:00", end: "10:00", services: ["svc-pedicure"]),
        block(id: "b5", dayOffset: -2, start: "10:00", end: "11:00", services: ["svc-extension"])
    ]

    private static func block(
        id: String,
        dayOffset: Int,
        start: String,
        end: String,
        services: [String]
    ) -> Block {
        Block(
            id: id,
            date: date(dayOffset),
            startTime: start,
            endTime: end,
            offeredServiceIds: services,
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )
    }

    private static func date(_ dayOffset: Int) -> String {
        let day = Calendar.current.date(
            byAdding: .day,
            value: dayOffset,
            to: reference
        ) ?? reference

        return DateFormat.date.string(from: day)
    }
}
#endif
```

`b5` — навмисно в минулому і єдиний для «Нарощення», тож ця послуга **не має** з'явитись
у списку. Це перевірка відсікання минулого.

- [ ] **Крок 2: тимчасове прев'ю для перевірки задачі 1**

Тимчасово додати в кінець `BookingAvailability.swift`, подивитись у Canvas,
**після перевірки видалити**:

```swift
#if DEBUG
import SwiftUI

#Preview("Availability") {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return VStack(alignment: .leading, spacing: 8) {
        ForEach(offers) { offer in
            Text(verbatim: "\(offer.service.name) — \(offer.slots.count) слот(ів), найближчий \(offer.nearestSlot?.startTime ?? "—")")
                .font(.elmsSans(.regular, 13))
        }
    }
    .padding()
}
#endif
```

Очікуваний вивід (порядок важливий — найближчі першими):

```
Класичний манікюр — 3 слот(ів), найближчий 10:00
Манікюр + гель-лак — 3 слот(ів), найближчий 10:00
Педикюр класичний — 2 слот(ів), найближчий 15:00
```

«Нарощення» відсутнє — його єдиний блок у минулому.

---

### Task 3: Зелений колорсет, метрики, шапка і картка

**Files:**
- Create: `Manik/Manik/Assets.xcassets/FreeSlot.colorset/Contents.json`
- Create: `Manik/Manik/Client/Booking/BookingMetrics.swift`
- Create: `Manik/Manik/Client/Booking/Components/BookingHeader.swift`
- Create: `Manik/Manik/Client/Booking/Components/ServiceOfferCard.swift`
- Modify: `Manik/Manik/Localizable/Localizable.xcstrings` (+ `booking.greeting`,
  `booking.title`, `booking.nearestWindow`, `booking.card.nearest`)

**Interfaces:**
- Consumes: `ServiceOffer`, `BookingSlot`, `ServiceFormat`, `BookingPreviewData`.
- Produces: `Color.freeSlot`; `BookingMetrics`; `BookingHeader(clientName:nearestSlot:)`;
  `ServiceOfferCard(offer:)`.

- [ ] **Крок 1: колорсет**

Створити `Manik/Manik/Assets.xcassets/FreeSlot.colorset/Contents.json` (структура — копія
наявного `StatusConfirmed.colorset/Contents.json`, змінюються лише компоненти):

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0x3E",
          "green" : "0x9B",
          "red" : "0x3A"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

Xcode згенерує символ `Color.freeSlot` автоматично. Окремий токен, а не `StatusConfirmed`,
свідомо: той означає «блок підтверджено», цей — «є вільне».

- [ ] **Крок 2: метрики**

Створити `Manik/Manik/Client/Booking/BookingMetrics.swift`:

```swift
import CoreGraphics

enum BookingMetrics {
    enum Size {
        static let cardCornerRadius: CGFloat = 24
        static let headerCornerRadius: CGFloat = 28
        static let pillDot: CGFloat = 8
        static let headerBubble: CGFloat = 180
        static let chevron: CGFloat = 15
        static let chevronButton: CGFloat = 44
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let headerPadding: CGFloat = 20
        static let headerContentSpacing: CGFloat = 10
        static let cardPadding: CGFloat = 16
        static let cardContentSpacing: CGFloat = 12
        static let listSpacing: CGFloat = 14
        static let listTopPadding: CGFloat = 12
        static let sectionTopPadding: CGFloat = 20
        static let pillPadding: CGFloat = 12
        static let pillSpacing: CGFloat = 8
    }

    enum Tracking {
        static let sectionLabel: CGFloat = 1.2
    }

    enum Opacity {
        static let headerBubble: Double = 0.06
        static let headerPill: Double = 0.12
        static let headerGreeting: Double = 0.7
    }
}
```

- [ ] **Крок 3: ключі локалізації**

Додати чотири ключі: `booking.greeting`, `booking.title`, `booking.nearestWindow`,
`booking.card.nearest` — значення з таблиці в шапці плану. Перші два з `%@`.

- [ ] **Крок 4: шапка**

Створити `Manik/Manik/Client/Booking/Components/BookingHeader.swift`:

```swift
import SwiftUI

struct BookingHeader: View {
    let clientName: String
    let nearestSlot: BookingSlot?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BookingMetrics.Spacing.headerContentSpacing
        ) {
            greeting
            title
            nearestPill
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BookingMetrics.Spacing.headerPadding)
        .background { headerBackground }
    }

    private var greeting: some View {
        Text(String(format: String(localized: "booking.greeting"), clientName))
            .font(.elmsSans(.regular, 15))
            .foregroundStyle(Color.background.opacity(BookingMetrics.Opacity.headerGreeting))
    }

    private var title: some View {
        Text("booking.title")
            .font(.elmsSans(.bold, 30))
            .foregroundStyle(Color.background)
    }

    @ViewBuilder
    private var nearestPill: some View {
        if let nearestSlot {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Circle()
                    .fill(Color.freeSlot)
                    .frame(
                        width: BookingMetrics.Size.pillDot,
                        height: BookingMetrics.Size.pillDot
                    )

                Text(
                    String(
                        format: String(localized: "booking.nearestWindow"),
                        "\(nearestSlot.shortDayLabel), \(nearestSlot.timeLabel)"
                    )
                )
                .font(.elmsSans(.bold, 14))
                .foregroundStyle(Color.background)
            }
            .padding(.horizontal, BookingMetrics.Spacing.pillPadding)
            .padding(.vertical, BookingMetrics.Spacing.pillSpacing)
            .background(
                Color.background.opacity(BookingMetrics.Opacity.headerPill),
                in: .capsule
            )
        }
    }

    private var headerBackground: some View {
        Color.ink
            .overlay(alignment: .topTrailing) { bubble }
            .clipShape(.rect(cornerRadius: BookingMetrics.Size.headerCornerRadius))
    }

    private var bubble: some View {
        Circle()
            .fill(Color.background.opacity(BookingMetrics.Opacity.headerBubble))
            .frame(
                width: BookingMetrics.Size.headerBubble,
                height: BookingMetrics.Size.headerBubble
            )
            .offset(
                x: BookingMetrics.Size.headerBubble / 3,
                y: -BookingMetrics.Size.headerBubble / 3
            )
    }
}

#if DEBUG
#Preview("З найближчим вікном") {
    BookingHeader(
        clientName: "Олена",
        nearestSlot: BookingSlot(
            id: "b1",
            date: DateFormat.date.string(from: BookingPreviewData.reference),
            startTime: "10:00"
        )
    )
    .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
    .background(Color.background)
}

#Preview("Без вікон") {
    BookingHeader(clientName: "Олена", nearestSlot: nil)
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
        .background(Color.background)
}
#endif
```

- [ ] **Крок 5: картка**

Створити `Manik/Manik/Client/Booking/Components/ServiceOfferCard.swift`. Картка —
**не** `Button` і не має власного `onTapGesture`: тапабельність дає `NavigationLink`, у
який її загорне `BookingView` (задача 4).

```swift
import SwiftUI

struct ServiceOfferCard: View {
    let offer: ServiceOffer

    var body: some View {
        HStack(spacing: BookingMetrics.Spacing.cardContentSpacing) {
            VStack(
                alignment: .leading,
                spacing: BookingMetrics.Spacing.cardContentSpacing
            ) {
                titleRow
                nearestLabel
            }

            chevron
        }
        .padding(BookingMetrics.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.surface,
            in: .rect(cornerRadius: BookingMetrics.Size.cardCornerRadius)
        )
    }

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(offer.service.name)
                .font(.elmsSans(.medium, 18))
                .foregroundStyle(Color.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: BookingMetrics.Spacing.cardContentSpacing)

            Text(ServiceFormat.price(offer.service.price))
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .layoutPriority(1)
        }
    }

    @ViewBuilder
    private var nearestLabel: some View {
        if let nearest = offer.nearestSlot {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Text("booking.card.nearest")
                Text(verbatim: "·")
                Text(verbatim: "\(nearest.dayLabel), \(nearest.timeLabel)")
            }
            .font(.elmsSans(.medium, 12))
            .textCase(.uppercase)
            .tracking(BookingMetrics.Tracking.sectionLabel)
            .foregroundStyle(Color.textSecondary)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.elmsSans(.bold, BookingMetrics.Size.chevron))
            .foregroundStyle(Color.background)
            .frame(
                width: BookingMetrics.Size.chevronButton,
                height: BookingMetrics.Size.chevronButton
            )
            .background(Color.ink, in: .circle)
    }
}

#if DEBUG
#Preview {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return VStack(spacing: BookingMetrics.Spacing.listSpacing) {
        ForEach(offers) { offer in
            ServiceOfferCard(offer: offer)
        }
    }
    .padding()
    .background(Color.background)
}
#endif
```

Шеврон тут — **індикатор**, а не кнопка: у макеті це чорне коло зі стрілкою, і воно
підказує, що картка веде далі. Кнопкою його робити не можна — тап уже обробляє
`NavigationLink` навколо всієї картки, і вкладена кнопка перехоплювала б жест.

- [ ] **Крок 6: перевірка**

Canvas: три картки (без «Нарощення»), ціни у форматі `450 zł`, підпис «НАЙБЛИЖЧЕ · 12 серпня,
10:00». Шапка в обох станах — із пілюлею і без.

---

### Task 4: Екран «Запис» і перехід на екран дат

**Files:**
- Create: `Manik/Manik/Client/Booking/BookingViewModel.swift`
- Create: `Manik/Manik/Client/Booking/Dates/BookingDatesView.swift`
- Create: `Manik/Manik/Client/Booking/BookingView.swift`
- Modify: `Manik/Manik/Localizable/Localizable.xcstrings` (+ `booking.section.services`,
  `booking.empty.title`, `booking.empty.message`, `booking.dates.title`)

**Interfaces:**
- Consumes: `BookingAvailability` (задача 1), `BookingHeader` / `ServiceOfferCard` (задача 3).
- Produces: `BookingViewModel(clientId:blockRepository:serviceRepository:)` з
  `offers`, `nearestSlot`, `hasLoaded`, `observeBlocks()`, `observeServices()`,
  `refreshAvailability()`; `BookingView(viewModel:clientName:)`; `BookingDatesView(offer:)`.

- [ ] **Крок 1: ключі локалізації**

Чотири ключі з таблиці: `booking.section.services`, `booking.empty.title`,
`booking.empty.message`, `booking.dates.title`.

- [ ] **Крок 2: view-модель**

Створити `Manik/Manik/Client/Booking/BookingViewModel.swift`:

```swift
import Foundation
import Observation

@MainActor
@Observable
final class BookingViewModel {
    private static let refreshInterval = 60

    private(set) var offers: [ServiceOffer] = []
    private(set) var nearestSlot: BookingSlot?
    private(set) var hasLoaded = false

    private let blockRepository: BlockRepository
    private let serviceRepository: ServiceRepository

    private var hasBlocks = false
    private var hasServices = false

    private var blocks: [Block] = [] {
        didSet { rebuild() }
    }

    private var services: [Service] = [] {
        didSet { rebuild() }
    }

    init(
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository()
    ) {
        self.blockRepository = blockRepository
        self.serviceRepository = serviceRepository
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
            hasBlocks = true
            updateLoaded()
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices
            hasServices = true
            updateLoaded()
        }
    }

    func refreshAvailability() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    private func rebuild() {
        let now = Date.now

        offers = BookingAvailability.offers(
            blocks: blocks,
            services: services,
            now: now
        )

        nearestSlot = BookingAvailability.nearestSlot(blocks: blocks, now: now)
    }

    private func updateLoaded() {
        hasLoaded = hasBlocks && hasServices
    }
}
```

`clientId` у цій view-моделі **не потрібен** — PR нічого не пише. Він з'явиться разом із
записом.

`refreshAvailability()` не косметика: `rebuild()` бере `Date.now`, тож без періодичного
перерахунку послуга, чий єдиний найближчий слот щойно минув, лишається в списку з датою в
минулому. Цикл живе в `.task`, тож скасовується разом зі зникненням екрана.

- [ ] **Крок 3: порожній екран дат**

Створити `Manik/Manik/Client/Booking/Dates/BookingDatesView.swift`. Це шел, який наповнить
PR14: власна шапка з кнопкою «назад» (як у `MyServicesView` — системний nav bar схований,
бо `navigationTitle` рендериться системним шрифтом) і порожнє тіло.

```swift
import SwiftUI

struct BookingDatesView: View {
    @Environment(\.dismiss) private var dismiss

    let offer: ServiceOffer

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            Text("booking.dates.title")
                .font(.elmsSans(.bold, 22))
                .foregroundStyle(Color.ink)

            HStack {
                backButton

                Spacer()
            }
        }
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
    }

    private var backButton: some View {
        Button("common.action.back", systemImage: "chevron.left", action: goBack)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.regular, BookingMetrics.Size.backIcon))
            .foregroundStyle(Color.ink)
            .frame(
                minWidth: BookingMetrics.Size.backTapTarget,
                minHeight: BookingMetrics.Size.backTapTarget,
                alignment: .leading
            )
            .contentShape(.rect)
    }

    private func goBack() {
        dismiss()
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        BookingDatesView(
            offer: ServiceOffer(
                service: BookingPreviewData.services[0],
                slots: []
            )
        )
    }
}
#endif
```

Додати в `BookingMetrics.Size` дві константи, яких там ще немає:

```swift
        static let backIcon: CGFloat = 26
        static let backTapTarget: CGFloat = 44
```

`offer` передається вже зараз, хоч екран його й не показує: саме він буде вхідним
параметром календаря, і фіксація цього контракту тут економить переписування навігації в PR14.

- [ ] **Крок 4: екран «Запис»**

Створити `Manik/Manik/Client/Booking/BookingView.swift`:

```swift
import SwiftUI

struct BookingView: View {
    @State private var viewModel: BookingViewModel

    let clientName: String

    init(viewModel: BookingViewModel, clientName: String) {
        _viewModel = State(initialValue: viewModel)
        self.clientName = clientName
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BookingHeader(
                    clientName: clientName,
                    nearestSlot: viewModel.nearestSlot
                )
                .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)

                sectionHeader
                list
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ServiceOffer.self) { offer in
                BookingDatesView(offer: offer)
            }
        }
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.observeServices()
        }
        .task {
            await viewModel.refreshAvailability()
        }
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.offers.isEmpty == false {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Text("booking.section.services")
                    .font(.elmsSans(.bold, 20))
                    .foregroundStyle(Color.ink)

                Spacer(minLength: 0)

                Text(viewModel.offers.count.formatted())
                    .font(.elmsSans(.medium, 14))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
            .padding(.top, BookingMetrics.Spacing.sectionTopPadding)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: BookingMetrics.Spacing.listSpacing) {
                ForEach(viewModel.offers) { offer in
                    NavigationLink(value: offer) {
                        ServiceOfferCard(offer: offer)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
            .padding(.top, BookingMetrics.Spacing.listTopPadding)
        }
        .overlay { statusOverlay }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        if viewModel.hasLoaded == false {
            ProgressView()
                .tint(Color.ink)
        } else if viewModel.offers.isEmpty {
            ContentUnavailableView {
                Text("booking.empty.title")
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)
            } description: {
                Text("booking.empty.message")
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

#if DEBUG
#Preview("З пропозиціями") {
    BookingView(
        viewModel: BookingViewModel(
            blockRepository: FakeBlockRepository(blocks: BookingPreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена"
    )
}

#Preview("Порожньо") {
    BookingView(
        viewModel: BookingViewModel(
            blockRepository: FakeBlockRepository(blocks: []),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена"
    )
}
#endif
```

`NavigationLink(value:)` + `navigationDestination(for:)` замість `onTapGesture` — картка
стає доступною для VoiceOver і Full Keyboard Access безкоштовно. `.buttonStyle(.plain)`
обов'язковий, інакше вся картка фарбується в акцентний колір.

Три `.task` навішані **на `NavigationStack`, а не всередині нього**: інакше пуш на екран
дат не зупиняє підписки, але й перемальовування стека їх переривало б.

- [ ] **Крок 5: перевірка**

Canvas «З пропозиціями»: шапка, лічильник «3», три картки, тап по картці пушить порожній
екран «Оберіть дату» з робочою кнопкою «назад». Canvas «Порожньо»: `ContentUnavailableView`
і шапка без пілюлі.

---

### Task 5: Роутер клієнтського кабінету

**Files:**
- Modify: `Manik/Manik/Client/ClientRootView.swift` (переписати повністю)

**Interfaces:**
- Consumes: `BookingView` (задача 4).
- Produces: робочий таб «Запис» у клієнтському кабінеті.

- [ ] **Крок 1: переписати роутер**

Плейсхолдер таба «Запис» зникає, але **кнопка виходу з нього має вціліти** — інакше з
акаунта не буде як вийти. Переносимо її в таб «Акаунт» (повноцінний екран — крок 6 черги
в `docs/plan.md`). Таб «Мої записи» лишається плейсхолдером до наступного PR.

```swift
import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: ClientTab = .booking

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .booking:
                    BookingView(
                        viewModel: BookingViewModel(),
                        clientName: profile.name
                    )
                case .myBookings:
                    placeholder
                case .account:
                    account
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: TabBarMetrics.Size.reservedClearance)
            }

            CustomTabBar(kind: .client(selection: $selectedTab))
        }
    }

    private var placeholder: some View {
        Text("client.placeholder.title")
            .font(.elmsSans(.bold, 24))
            .foregroundStyle(Color.ink)
    }

    private var account: some View {
        VStack(spacing: 16) {
            Text(profile.name)
                .font(.elmsSans(.bold, 24))
                .foregroundStyle(Color.ink)

            Text(profile.email)
                .font(.elmsSans(.regular, 16))
                .foregroundStyle(Color.textSecondary)

            Button(action: onSignOut) {
                Text("common.action.signOut")
                    .font(.elmsSans(.bold, 14.5))
                    .foregroundStyle(Color.ink)
            }
        }
    }
}

#if DEBUG
#Preview {
    ClientRootView(
        profile: UserProfile(
            uid: "preview",
            role: .client,
            name: "Олена",
            email: "client@example.com"
        ),
        onSignOut: {}
    )
}
#endif
```

Прев'ю роутера ходить у справжній Firestore (дефолтні репозиторії у view-моделі) — це
свідомо, як і в `MasterRootView`; для роботи з даними користуйтесь прев'ю окремих екранів.

- [ ] **Крок 2: перевірка**

Перевіряється збіркою і запуском на симуляторі — **на запит користувача**: вхід клієнтом →
таб «Запис» показує послуги, для яких майстер створив майбутні вільні блоки → тап по картці
відкриває порожній екран «Оберіть дату» → «назад» повертає до списку. Таб «Акаунт» дає вийти.

---

## Фінальна перевірка PR

- [ ] Білд (**запускає користувач**):
      `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
- [ ] Тимчасове прев'ю `Availability` (задача 2, крок 2) видалено.
- [ ] У новому коді немає коментарів, немає `.font(.system`, немає інлайнових `DateFormatter`.
- [ ] Усі 8 ключів мають `en` **і** `uk` зі станом `translated`.
- [ ] `docs/plan.md` — оновити один раз, після завершення зрізу (правило `CLAUDE.md` про
      батчинг доків).
- [ ] `docs/superpowers/specs/2026-08-08-client-booking-design.md` — **не видаляти**: у ньому
      живуть наступні зрізи. Видалити, коли клієнтський запис буде закінчений повністю.
