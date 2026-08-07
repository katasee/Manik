# PR11 — Майстер: додавання послуги. План імплементації

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Мета:** зробити кнопку «+» на екрані «Мої послуги» робочою — попап із полями «Назва» і «Ціна»,
що пише в колекцію `services`, і одночасно прибрати тимчасові підпірки, які трималися, поки
послуги засівалися руками через Firebase Console.

**Архітектура:** MVVM + Repository, як і всюди в проєкті. Попап — окремий `AddServicePopup` +
`@Observable AddServiceViewModel` у теці `Master/Services/AddService/`, побудований на наявному
`PopupContainer`. Репозиторій у форму потрапляє з `MyServicesViewModel` через фабрику
`makeAddServiceViewModel()`, тому композиційний корінь лишається один і прев'ю з фейком працює
наскрізь. Дата-шар не змінюється взагалі.

**Стек:** SwiftUI (iOS 17.2+), Swift Observation (`@Observable`), FirebaseFirestore, String Catalog.

## Глобальні обмеження

- **Тестового таргета в проєкті немає.** Верифікація кожної задачі = успішний
  `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
  плюс ручна перевірка в Xcode Preview. Не вигадуй тестовий таргет і не додавай залежностей.
- **Збірку запускає користувач.** У кожній задачі крок збірки позначений як такий, що його ініціює
  користувач — не запускай `xcodebuild` без прямого прохання.
- **Коміти робить користувач.** Повідомлення коміту наведене в кроці як пропозиція; сам не комітити.
- **Без коментарів у Swift-коді** — ні інлайнових, ні докблоків.
- **Виклик із 3+ аргументами — один аргумент на рядок.** Менше трьох — в один рядок.
- **Жодних текстових літералів у View**: усе через `String(localized:)`/`LocalizedStringKey` і
  ключі `feature.kind.name` у `Manik/Manik/Localizable/Localizable.xcstrings` (sourceLanguage `uk`,
  обидві локалі `uk` + `en` в тому ж комміті).
- **Шрифт лише `Font.elmsSans(_:_:)`** — ніяких `.system`, `.title`, `.bold()`.
- **Валюта лишається `PLN`** — `ServiceFormat.currencyCode` не чіпати.
- **Кольори — токени з `Assets.xcassets`**: `Color.ink`, `.background`, `.surface`,
  `.fieldBackground`, `.textSecondary`, `.destructive`.

---

### Задача 1: Прибрати тривалість послуги з моделі й UI

**Файли:**
- Змінити: `Manik/Manik/Models/Service.swift`
- Змінити: `Manik/Manik/Utilities/ServiceFormat.swift:13-16`
- Змінити: `Manik/Manik/Master/Services/ServiceRow.swift:39-50`
- Змінити: `Manik/Manik/Master/Services/Preview/ServicesPreviewData.swift`
- Змінити: `Manik/Manik/Master/Schedule/Preview/SchedulePreviewData.swift:5-10`

**Інтерфейси:**
- Віддає далі: `Service(id: String?, name: String, price: Double)` — memberwise-ініціалізатор без
  `durationMinutes`; усі наступні задачі використовують саме цю форму.

- [ ] **Крок 1: Прибрати поле з моделі**

`Manik/Manik/Models/Service.swift` цілком:

```swift
import FirebaseFirestore

struct Service: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
}
```

- [ ] **Крок 2: Прибрати форматер тривалості**

`Manik/Manik/Utilities/ServiceFormat.swift` цілком (лишається тільки ціна):

```swift
import Foundation

enum ServiceFormat {
    static let currencyCode = "PLN"

    static func price(_ value: Double) -> String {
        value.formatted(
            .currency(code: currencyCode)
            .precision(.fractionLength(0...2))
        )
    }
}
```

- [ ] **Крок 3: Прибрати рядок тривалості з `ServiceRow`**

У `Manik/Manik/Master/Services/ServiceRow.swift` заміни властивість `details` — `VStack` більше не
потрібен, лишається сама назва:

```swift
    private var details: some View {
        Text(service.name)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.ink)
            .lineLimit(2)
    }
```

`ServicesMetrics.Spacing.rowTextSpacing` після цього стає невикористаним — видали цей рядок з
`Manik/Manik/Master/Services/ServicesMetrics.swift`.

- [ ] **Крок 4: Оновити обидві фікстури прев'ю**

`Manik/Manik/Master/Services/Preview/ServicesPreviewData.swift` цілком:

```swift
#if DEBUG
enum ServicesPreviewData {
    static let services: [Service] = [
        Service(id: "svc-hybrid", name: "Манікюр гібридний (гель-лак)", price: 800),
        Service(id: "svc-classic", name: "Класичний манікюр", price: 500),
        Service(id: "svc-gel-correction", name: "Корекція гелем", price: 900),
        Service(id: "svc-french", name: "Френч", price: 200)
    ]
}
#endif
```

У `Manik/Manik/Master/Schedule/Preview/SchedulePreviewData.swift` — той самий масив `services`
(рядки 5-10), прибери `durationMinutes:` з усіх чотирьох елементів, решту файлу (блоки) не чіпай.

- [ ] **Крок 5: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`. Якщо десь лишилось звернення до `durationMinutes` — компілятор
покаже точний файл і рядок; це єдиний надійний спосіб перевірити, бо SourceKit у цьому проєкті
регулярно віддає застарілі помилки.

- [ ] **Крок 6: Перевірити прев'ю `ServiceRow`**

Відкрий `ServiceRow.swift` в Xcode, Canvas. Очікування: чотири рядки з іконкою-зіркою, назвою і
ціною праворуч; підпису «45 хв» більше немає, рядок став нижчим і назва вирівняна по центру
відносно іконки.

- [ ] **Крок 7: Комміт (робить користувач)**

Запропоноване повідомлення: `Remove service duration from model and price list`

---

### Задача 2: Зробити `FakeServiceRepository` мутабельним

**Файли:**
- Змінити: `Manik/Manik/Services/Fakes/FakeServiceRepository.swift` (перезаписати цілком)

**Інтерфейси:**
- Споживає: `Service(id:name:price:)` із Задачі 1.
- Віддає далі: `FakeServiceRepository(services: [Service] = [])` — `final class`, стрім не
  завершується, мутації транслюються всім підписникам. Задачі 5 і 6 покладаються на те, що це
  **клас** (референс-семантика: та сама інстанція, що її бачить список, бачить і форма).

- [ ] **Крок 1: Переписати фейк**

`Manik/Manik/Services/Fakes/FakeServiceRepository.swift` цілком:

```swift
import Foundation

#if DEBUG
final class FakeServiceRepository: ServiceRepository {
    private var services: [Service]
    private var continuations: [UUID: AsyncStream<[Service]>.Continuation] = [:]

    init(services: [Service] = []) {
        self.services = services
    }

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(services)
        }
    }

    func add(_ service: Service) async throws {
        var stored = service
        stored.id = service.id ?? UUID().uuidString
        services.append(stored)
        broadcast()
    }

    func update(_ service: Service) async throws {
        guard
            let id = service.id,
            let index = services.firstIndex(where: { $0.id == id })
        else { return }

        services[index] = service
        broadcast()
    }

    func delete(id: String) async throws {
        services.removeAll { $0.id == id }
        broadcast()
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(services)
        }
    }
}
#endif
```

Три речі, які легко зробити «краще» і зламати:

1. **`continuation.finish()` більше не викликається.** Саме тому фейк тепер здатен показувати
   оновлення: стрім лишається живим, і `for await` у view model чекає далі. Стара версія віддавала
   значення один раз і завершувалась — з нею додавання в прев'ю не видно.
2. **`onTermination` навмисно не реалізовано.** Він виконується поза `MainActor` і мутував би
   `continuations` з фонового контексту. Це DEBUG-хелпер для прев'ю; максимальна ціна — мертвий
   запис у словнику до кінця роботи прев'ю.
3. **`add` сам присвоює `id`.** У проді це робить Firestore, і без цього нова послуга приїхала б у
   `ForEach` з `id == nil`, зламавши `Identifiable`-ідентичність рядків.

- [ ] **Крок 2: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`. Наявні виклики `FakeServiceRepository(services:)` у
`ScheduleView.swift`, `MyServicesView.swift` компілюються без змін — сигнатура ініціалізатора та сама.

- [ ] **Крок 3: Перевірити прев'ю «Порожній список»**

Відкрий `MyServicesView.swift`, прев'ю «Порожній список». Очікування: коротко видно `ProgressView`,
потім `ContentUnavailableView` «Поки що немає послуг». Спінер до цієї задачі не з'являвся ніколи,
бо стрім завершувався миттєво разом із першим значенням.

- [ ] **Крок 4: Комміт (робить користувач)**

Запропоноване повідомлення: `Make FakeServiceRepository a mutable in-memory class`

---

### Задача 3: Винести `withoutPresentationAnimation` у UICommons

**Файли:**
- Створити: `Manik/Manik/Assets/UICommons/PresentationAnimation.swift`
- Змінити: `Manik/Manik/Master/Schedule/ScheduleView.swift:127-132` (прибрати приватну копію)

**Інтерфейси:**
- Віддає далі: `withoutPresentationAnimation(_ changes: () -> Void)` — вільна функція на рівні
  модуля. Задача 5 викликає її для показу й приховування попапа.

- [ ] **Крок 1: Створити спільний хелпер**

`Manik/Manik/Assets/UICommons/PresentationAnimation.swift` цілком:

```swift
import SwiftUI

func withoutPresentationAnimation(_ changes: () -> Void) {
    var transaction = Transaction()
    transaction.disablesAnimations = true

    withTransaction(transaction, changes)
}
```

Це вільна функція, а не метод на `View`: вона нічого не рендерить, лише обгортає мутацію стану.
Ставити `.transaction { }` на сам модифікатор презентації — помилка, яку цей хелпер існує щоб не
робити: воно вимикає анімації для всього піддерева, а не лише для слайд-апу.

- [ ] **Крок 2: Видалити приватну копію в `ScheduleView`**

У `Manik/Manik/Master/Schedule/ScheduleView.swift` видали приватний метод (рядки 127-132):

```swift
    private func withoutPresentationAnimation(_ changes: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction, changes)
    }
```

Три його виклики в `requestSlotCreation`, `showBlockDetail`, `dismissPopup` не змінюються — вони
тепер резолвляться у вільну функцію.

- [ ] **Крок 3: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`.

- [ ] **Крок 4: Перевірити на симуляторі, що попапи розкладу не змінили поведінки**

Запусти застосунок, таб «Розклад», тапни «+ Додати вільний час». Очікування: попап проявляється
фейдом по центру, **без** системного слайду знизу — точно як до цієї задачі. Це регресійна
перевірка: якщо хелпер підхопився неправильно, слайд-ап повернеться і це видно одразу.

- [ ] **Крок 5: Комміт (робить користувач)**

Запропоноване повідомлення: `Extract withoutPresentationAnimation into UICommons`

---

### Задача 4: `AddServiceViewModel`

**Файли:**
- Створити: `Manik/Manik/Master/Services/AddService/AddServiceViewModel.swift`
- Змінити: `Manik/Manik/Master/Services/MyServicesViewModel.swift` (додати фабрику)

**Інтерфейси:**
- Споживає: `ServiceRepository.add(_ service: Service) async throws`, `Service(id:name:price:)`.
- Віддає далі:
  - `AddServiceViewModel(serviceRepository: ServiceRepository)` — ініціалізатор **без** значення за
    замовчуванням;
  - `var name: String`, `var priceText: String` — прив'язуються до `TextField` у Задачі 5;
  - `private(set) var errorMessage: String?`, `private(set) var isSaving: Bool`;
  - `var canSubmit: Bool`;
  - `func submit() async -> Bool` — `true` означає «збережено, можна закривати попап»;
  - `MyServicesViewModel.makeAddServiceViewModel() -> AddServiceViewModel`.

- [ ] **Крок 1: Створити view model**

`Manik/Manik/Master/Services/AddService/AddServiceViewModel.swift` цілком:

```swift
import Foundation
import Observation

@MainActor
@Observable
final class AddServiceViewModel {
    var name = ""
    var priceText = ""

    private(set) var errorMessage: String?
    private(set) var isSaving = false

    private let serviceRepository: ServiceRepository

    init(serviceRepository: ServiceRepository) {
        self.serviceRepository = serviceRepository
    }

    var canSubmit: Bool {
        trimmedName.isEmpty == false && (Self.parsePrice(priceText) ?? 0) > 0
    }

    func submit() async -> Bool {
        guard canSubmit, let price = Self.parsePrice(priceText) else { return false }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await serviceRepository.add(Service(id: nil, name: trimmedName, price: price))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parsePrice(_ text: String) -> Double? {
        try? Double(text, format: .number.locale(.current))
    }
}
```

Чому ініціалізатор без дефолту: `serviceRepository: ServiceRepository = FirestoreServiceRepository()`
означав би, що прев'ю, яке забуло інжектнути фейк, мовчки пише в живий Firestore. PR10 уже прийняв
це правило для `MyServicesView.init(viewModel:)` — тримаємось його.

`parsePrice` йде через `FormatStyle`, а не через `Double(text)`: `.decimalPad` видає десятковий
роздільник **поточної локалі**, тож на україномовному чи польському пристрої в полі буде «450,5», що
для `Double("450,5")` — `nil`. Ручна заміна коми на крапку теж не рішення: вона ламається на
роздільниках тисяч. Перевірено на `en_PL`: `"450,5"` → `450.5`, `""` → `nil`, `" 450 "` → `450`
(парсер лояльний до пробілів, тому окремий `trimmingCharacters` для ціни не потрібен).

- [ ] **Крок 2: Додати фабрику в `MyServicesViewModel`**

У `Manik/Manik/Master/Services/MyServicesViewModel.swift` додай метод одразу після
`observeServices()`:

```swift
    func makeAddServiceViewModel() -> AddServiceViewModel {
        AddServiceViewModel(serviceRepository: serviceRepository)
    }
```

`serviceRepository` лишається `private let` — саме тому це фабрика, а не публічна властивість:
екран лишається єдиною точкою, що знає про конкретний репозиторій, і прев'ю з фейком автоматично
віддає той самий фейк у форму.

- [ ] **Крок 3: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`. Попередження «No 'async' operations occur within 'await' expression»
бути не повинно — якщо з'явилось, значить виклик `add` резолвнувся в синхронну перевантаженість і
помилки збереження ніколи не спливуть.

- [ ] **Крок 4: Комміт (робить користувач)**

Запропоноване повідомлення: `Add AddServiceViewModel with name and price validation`

---

### Задача 5: Попап `AddServicePopup` і підключення кнопки «+»

**Файли:**
- Створити: `Manik/Manik/Master/Services/AddService/AddServicePopup.swift`
- Змінити: `Manik/Manik/Master/Services/MyServicesView.swift`
- Змінити: `Manik/Manik/Localizable/Localizable.xcstrings`

**Інтерфейси:**
- Споживає: `AddServiceViewModel` і `MyServicesViewModel.makeAddServiceViewModel()` із Задачі 4,
  `withoutPresentationAnimation(_:)` із Задачі 3, `FakeServiceRepository` із Задачі 2,
  `PopupContainer(dismissLabel:onDismiss:content:)`, `PopupPrimaryButton(titleKey:color:isLoading:isEnabled:action:)`,
  `PopupDismissButton(titleKey:action:)`.
- Віддає далі: `AddServicePopup(viewModel:onDismiss:)`.

- [ ] **Крок 1: Додати ключі локалізації**

У `Manik/Manik/Localizable/Localizable.xcstrings` встав запис `common.action.done` між наявними
`common.action.cancel` і `common.action.ok`:

```json
    "common.action.done" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Done" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Готово" } }
      }
    },
```

Далі — шість записів у тому ж словнику `strings`, в алфавітному порядку: одразу після
`services.action.open` і перед `services.empty.message`:

```json
    "services.add.nameLabel" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Name" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Назва" } }
      }
    },
    "services.add.namePlaceholder" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Classic manicure" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Класичний манікюр" } }
      }
    },
    "services.add.priceLabel" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Price" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Ціна" } }
      }
    },
    "services.add.pricePlaceholder" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "450" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "450" } }
      }
    },
    "services.add.submit" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Add" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Додати" } }
      }
    },
    "services.add.title" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "New service" } },
        "uk" : { "stringUnit" : { "state" : "translated", "value" : "Нова послуга" } }
      }
    },
```

Файл — звичайний JSON; після правки перевір валідність:
`python3 -m json.tool Manik/Manik/Localizable/Localizable.xcstrings > /dev/null && echo OK`.
Кнопку «Скасувати» не додавай — використовуємо наявний `common.action.cancel`.

- [ ] **Крок 2: Створити попап**

`Manik/Manik/Master/Services/AddService/AddServicePopup.swift` цілком:

```swift
import SwiftUI

struct AddServicePopup: View {
    private enum Field {
        case name
        case price
    }

    @State private var viewModel: AddServiceViewModel
    @FocusState private var focusedField: Field?

    let onDismiss: () -> Void

    init(viewModel: AddServiceViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "common.action.cancel",
            onDismiss: onDismiss
        ) { dismiss in
            title
            nameField
            priceField
            errorText
            actions(dismiss: dismiss)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.action.done", action: dismissKeyboard)
            }
        }
    }

    private var title: some View {
        Text("services.add.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
    }

    private var nameField: some View {
        fieldRow("services.add.nameLabel") {
            TextField("services.add.namePlaceholder", text: $viewModel.name)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .price }
        }
    }

    private var priceField: some View {
        fieldRow("services.add.priceLabel") {
            TextField("services.add.pricePlaceholder", text: $viewModel.priceText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .price)
        }
    }

    @ViewBuilder
    private var errorText: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            PopupPrimaryButton(
                titleKey: "services.add.submit",
                color: .ink,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSubmit,
                action: { save(then: dismiss) }
            )
        }
    }

    private func save(then dismiss: @escaping () -> Void) {
        focusedField = nil

        Task {
            if await viewModel.submit() {
                dismiss()
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func fieldRow(
        _ labelKey: LocalizedStringKey,
        @ViewBuilder control: () -> some View
    ) -> some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer()

            control()
        }
        .font(.elmsSans(.regular, 15))
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            AddServicePopup(
                viewModel: AddServiceViewModel(serviceRepository: FakeServiceRepository()),
                onDismiss: {}
            )
        }
}
#endif
```

`dismiss` приходить параметром контент-клоужера `PopupContainer` — це навмисно, а не через
`@Environment`: середовищний варіант уже пробували в PR9 і викинули, бо `@Environment` резолвиться
там, де оголошений, і мовчки давав no-op.

Тулбар клавіатури обов'язковий саме тут: у `.decimalPad`, на відміну від `.numbersAndPunctuation` в
`AddNewSlotBlock`, **немає return-клавіші**, тож без кнопки «Готово» клавіатуру нічим прибрати —
тап по затемненому фону закрив би весь попап разом із уже введеним. `ToolbarItemGroup(placement:
.keyboard)` не потребує `NavigationStack` і працює всередині `fullScreenCover`.

- [ ] **Крок 3: Підключити кнопку «+» у `MyServicesView`**

У `Manik/Manik/Master/Services/MyServicesView.swift`:

1. Додай стан поруч із наявним `@State private var viewModel`:

```swift
    @State private var isAddingService = false
```

2. Додай модифікатор одразу після `.task { await viewModel.observeServices() }`:

```swift
        .fullScreenCover(isPresented: $isAddingService) {
            AddServicePopup(
                viewModel: viewModel.makeAddServiceViewModel(),
                onDismiss: dismissAddService
            )
            .presentationBackground(.clear)
        }
```

3. Заміни порожню заглушку `addService()` і додай парний метод закриття:

```swift
    private func addService() {
        withoutPresentationAnimation {
            isAddingService = true
        }
    }

    private func dismissAddService() {
        withoutPresentationAnimation {
            isAddingService = false
        }
    }
```

- [ ] **Крок 4: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`.

- [ ] **Крок 5: Перевірити прев'ю «З послугами» наскрізь**

Відкрий `MyServicesView.swift`, прев'ю «З послугами», Live Preview (не статичний Canvas — потрібні
тапи). Сценарій:

1. Тап на чорну кнопку «+» → попап проявляється фейдом, без слайду знизу.
2. Кнопка «Додати» неактивна (напівпрозора), поки обидва поля порожні.
3. Введи лише назву → кнопка досі неактивна; додай ціну `450` → стає активною.
4. Введи ціну `0` → знову неактивна.
5. Тап «Додати» → попап закривається, у списку з'являється п'ятий рядок, а лічильник у заголовку
   «УСІ ПОСЛУГИ» стає `5`. Саме тут окупається клас-фейк із Задачі 2: список і форма ділять одну
   інстанцію репозиторію.
6. Тап по затемненому фону і кнопка «Скасувати» — обидві закривають попап без запису.
7. Фокус у полі «Ціна» → над клавіатурою є кнопка «Готово», і вона ховає клавіатуру, не закриваючи
   попап. У полі «Назва» клавіша return переводить фокус на «Ціну».
8. Введи ціну з комою — `450,5`. Очікування: кнопка активна, після збереження в списку `450,50 zł`.
   Якщо бачиш `450 zł` — парсер розібрав кому як роздільник тисяч, значить `.locale(.current)` десь
   загубився.

- [ ] **Крок 6: Комміт (робить користувач)**

Запропоноване повідомлення: `Add new service through a popup form`

---

### Задача 6: Прибрати тимчасові підпірки в `ScheduleView`

**Файли:**
- Змінити: `Manik/Manik/Master/Schedule/ScheduleView.swift:3-19`
- Змінити: `Manik/Manik/Master/MasterRootView.swift:14`

**Інтерфейси:**
- Віддає далі: `ScheduleView(viewModel: ScheduleViewModel)` — ініціалізатор стає обов'язковим.

Ця задача йде **останньою по коду** свідомо: доти чекліст послуг у попапі створення слота живився
фейком, і зняти його раніше означало б лишити екран непрацездатним.

- [ ] **Крок 1: Зробити ін'єкцію обов'язковою і прибрати `#if DEBUG`**

У `Manik/Manik/Master/Schedule/ScheduleView.swift` заміни рядки 3-19 на:

```swift
struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var popup: SchedulePopup?

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
```

Тобто статична властивість `serviceRepository` з `#if DEBUG`-підміною на `FakeServiceRepository`
видаляється цілком. Прев'ю в кінці файлу вже інжектить обидва фейки явно — його не чіпай.

- [ ] **Крок 2: Оновити місце виклику**

У `Manik/Manik/Master/MasterRootView.swift:14` заміни `ScheduleView()` на:

```swift
                    ScheduleView(viewModel: ScheduleViewModel())
```

- [ ] **Крок 3: Збірка (запускає користувач)**

Команда: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Очікування: `BUILD SUCCEEDED`. Якщо десь лишився виклик `ScheduleView()` без аргументу — компілятор
покаже це як «Missing argument for parameter 'viewModel'».

- [ ] **Крок 4: Наскрізна перевірка на симуляторі**

Запусти застосунок під майстер-акаунтом:

1. Таб «Статистика» → лінк «Мої послуги» → «+» → введи назву й ціну → «Додати».
2. Очікування: рядок з'являється в списку одразу, без ручного оновлення (пише живий Firestore,
   читає той самий листенер).
3. Перейди на таб «Розклад» → тапни «+ Додати вільний час» на будь-якій годині.
4. Очікування: у чеклісті «Послуги» видно щойно створену послугу — і **лише** реальні дані з
   Firestore, тестових «Френч»/«Корекція гелем» із `SchedulePreviewData` більше немає.
5. Якщо на кроці 1 з'явився текст помилки про permissions — це не код, а роль акаунта: `isMaster()`
   читає `users/{uid}.role == "master"` у Firebase Console.

- [ ] **Крок 5: Комміт (робить користувач)**

Запропоноване повідомлення: `Require explicit view model injection in ScheduleView`

---

### Задача 7: Синхронізація документації

Робиться **одним заходом наприкінці** — `CLAUDE.md` прямо забороняє правити доки після кожної
дрібної ітерації, поки фіча ще в роботі.

**Файли:**
- Змінити: `docs/plan.md`
- Змінити: `docs/superpowers/specs/2026-07-15-manik-mvp-design.md:34` і рядок про флоу майстра
- Видалити: `docs/superpowers/plans/2026-08-07-master-my-services-list.md`
- Видалити: `docs/superpowers/specs/2026-08-07-master-add-service-design.md`
- Видалити: `docs/superpowers/plans/2026-08-07-master-add-service.md` (цей файл)

- [ ] **Крок 1: Оновити MVP-спеку**

У `docs/superpowers/specs/2026-07-15-manik-mvp-design.md` прибери рядок `durationMinutes: number`
з опису документа `services` і в описі флоу майстра заміни
«кнопка "Мої послуги" веде на екран CRUD прайс-листа (назва, тривалість, ціна)» на
«кнопка "Мої послуги" веде на екран CRUD прайс-листа (назва, ціна)».

- [ ] **Крок 2: Оновити `docs/plan.md`**

1. У секції «Done» додай запис **PR11** за зразком попередніх: попап `AddService/` на
   `PopupContainer`, фабрика `makeAddServiceViewModel()` замість публічного репозиторію,
   `FakeServiceRepository` став мутабельним класом, `withoutPresentationAnimation` переїхав у
   UICommons, `ScheduleView` втратив `#if DEBUG` і опційний `init`, **тривалість послуги видалена
   з продукту** (це продуктове рішення, не рефакторинг — зафіксуй причину: тривалість візиту задає
   сам блок).
2. У кроці 1 познач `PR11 — add a service` як зроблений (`~~...~~ — **done**`).
3. Викресли пункт 8 «Confirm `firestore.rules` deployment» — опубліковані правила звірено з
   локальним файлом 2026-08-07, збігаються рядок у рядок.
4. З «Housekeeping» прибери відкрите питання про валюту — рішення: лишається `PLN`.
5. З «Housekeeping» прибери рядок про видалення
   `docs/superpowers/plans/2026-08-07-master-my-services-list.md` (крок 3 його видаляє).
6. У PR10-записі згадка «fix it in PR11» щодо `ScheduleView` більше не актуальна — прибери або
   переформулюй у минулий час.
7. Пункт 14 («Service names don't follow the device language») **уже додано** під час планування —
   не дублюй його, лише перевір, що він на місці.
8. У «Housekeeping» додай до списку відхилених знахідок: ревʼю swift-concurrency-pro знайшло гонку
   в `FakeServiceRepository` (синхронний `observeServices()` виконується на виклику́вачі, а
   nonisolated async мутації — на загальному екзекуторі) плюс невичищені continuations через
   відсутній `onTermination`. Фікс через `OSAllocatedUnfairLock` перевірено компіляцією під
   `-strict-concurrency=complete` і **свідомо відхилено**: це DEBUG-код лише для прев'ю. Не
   піднімати повторно; перегляд — разом із міграцією на Swift 6 (пункт 12).

- [ ] **Крок 3: Видалити відпрацьовані артефакти**

```bash
rm docs/superpowers/plans/2026-08-07-master-my-services-list.md
rm docs/superpowers/specs/2026-08-07-master-add-service-design.md
rm docs/superpowers/plans/2026-08-07-master-add-service.md
```

Постійними лишаються тільки `docs/superpowers/specs/2026-07-15-manik-mvp-design.md` і
`docs/plan.md`.

- [ ] **Крок 4: Комміт (робить користувач)**

Запропоноване повідомлення: `Sync docs after add-service feature`

---

## Критерій готовності всієї фічі

Майстер відкриває «Мої послуги» → «+» → вводить назву й ціну → «Додати»: попап закривається, рядок
з'являється в списку без ручного оновлення, і ця сама послуга видима чеклістом у попапі створення
вільного слота. Прев'ю `MyServicesView` відтворює той самий сценарій на фейку без мережі. Збірка
`xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build` проходить.
