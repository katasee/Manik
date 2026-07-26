# Create Free-Time Slot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Status: executed and shipped, then substantially revised in follow-up tweaks after the
> final review.** This file is a historical record of the original 8-task execution (all
> tasks completed, reviewed clean, merged into `feature/pr-7-createFreeSlot`) — it is
> **not** kept in sync with the shipped code turn-by-turn. Several things changed after
> this plan finished: `CreateBlockPopup` → `AddNewSlotBlock`; `MinuteIntervalTimePicker`
> → plain `DatePicker` → manual `TextField` "HH:mm" entry (the UIKit wrapper below was
> deleted entirely); presentation moved from `.fullScreenCover` to a custom `ZStack`
> overlay owned by `MasterRootView`, with `.ultraThinMaterial` backdrop + `.brandShadow()`
> instead of a flat black scrim; default duration changed from 30 to 60 minutes; files
> reorganized into `Master/Schedule/CreateBlock/` + `Services/Fakes/`; tap-outside-to-dismiss
> was added (originally decided against). **For what's actually shipped, read
> `docs/superpowers/specs/2026-07-26-create-free-slot-design.md` instead** — that spec is
> kept current. Keep the code samples below as-is; they document what Task N originally
> asked for, not the current state.

**Goal:** Make the punctured "+ Додати вільний час" (`DashedSlot`) in the master's Schedule
timeline actually create a `Block` — tapping it opens a centered popup (date + start + end
+ services checklist) that writes a new `available` block to Firestore.

**Architecture:** MVVM. A new `CreateBlockViewModel` (`@MainActor @Observable`) owns the
form state (date/startTime/endTime/selectedServiceIds) and calls
`BlockRepository.addBlock(_:)`. It's presented from `CreateBlockPopup` — **not** a system
`.sheet`, but a custom centered `RoundedRectangle` card over a dimmed backdrop, shown via
`.fullScreenCover(item:)` with `.presentationBackground(.clear)`. `fullScreenCover` (not a
plain in-view `ZStack` overlay) is required here specifically because `MasterRootView`
stacks `ScheduleView`'s content and the floating `CustomTabBar` as *siblings* in one
`ZStack` (`CustomTabBar` declared after the content, so it paints on top) — an overlay
declared inside `ScheduleView` would render behind the tab bar and leave it tappable while
the popup is open. `fullScreenCover` presents via UIKit's modal layer, which is always
above the entire view hierarchy regardless of that local `ZStack` nesting, so this comes for
free instead of lifting state up into `MasterRootView`.

`ScheduleView` gains its own lightweight `services: [Service]` subscription (a bare
`@State` + `.task`, not a full `ScheduleViewModel` — none exists yet on this branch; the
one built for the next step, "render + manage blocks", is sitting in
`git stash list` (`stash@{0}`) and is intentionally **not** touched by this plan: it's an
unfinished snapshot (references a `ScheduleEmptySlot` type that was planned but never
created) bundling next-step concerns (block cards, detail sheet). Popping it now would
blur this step's scope and drag in a type that doesn't compile.

**Tech Stack:** SwiftUI, `@Observable`/`@MainActor`, Firebase Firestore
(`FirebaseFirestore`), existing `Block`/`Service` models, existing `BlockRepository`/
`ServiceRepository` protocols (no protocol changes needed — `addBlock`/`observeServices`
already exist).

## Global Constraints

- Build gate: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
  must succeed (`BUILD SUCCEEDED`). Per project convention, don't run this after every
  single task — it's called out explicitly at checkpoint tasks below (3, 4, 5, 6, 8). Tasks
  1, 2, and 7 skip it: 1 and 2 are data-only/unused-until-later changes, and 7 leaves the
  target non-compiling on its own (see the note at the end of Task 7).
- **No test target/linter/formatter.** Verification is (a) the build gate, (b) for tasks
  that add a `#Preview`, a manual-inspection description of exactly what should render in
  Xcode's canvas.
- `@Observable` macro (not `ObservableObject`); views hold view models via
  `@State private var viewModel = ...` (or `@State private var viewModel: T` +
  `init { _viewModel = State(initialValue: ...) }` when the initial value needs
  constructor args — see `ScheduleView.init(viewModel:)` precedent in the stashed plan).
- Any function/initializer call with 3+ arguments: one argument per line.
- User-facing strings go in `Manik/Manik/Localizable/Localizable.xcstrings` under a
  `feature.kind.name` key, both `en` and `uk` localizations, added in the same change that
  introduces the string.
- Text always via `Font.elmsSans(_:_:)`, never `.font(.system(...))`/`.title`/`.bold()`.
- `Block.date`/`startTime`/`endTime` are storage strings produced only via
  `DateFormat.date`/`DateFormat.time` (never an inline `DateFormatter`).
- Firestore's Codable convenience methods have no real `async` overload in this SDK
  version — always use `Firestore.Encoder().encode(_:)` + raw dictionary methods. Not
  directly relevant here since we call `BlockRepository.addBlock(_:)` (already implemented
  correctly in `FirestoreBlockRepository`), but don't add any new direct Firestore calls
  that bypass this.
- Full spec reference: `docs/superpowers/specs/2026-07-26-create-free-slot-design.md`.

## Prerequisite (not a code task)

The end-to-end check in Task 8 Step 4 needs real documents in the `services` collection to
show a non-empty checklist. If Firebase Console → Firestore → `services` is still empty,
add these 4 documents by hand first (fields: `name: string`, `durationMinutes: number`,
`price: number` — matches `Service`, Firestore assigns the document ID):

| name | durationMinutes | price |
|---|---|---|
| Манікюр гібридний (гель-лак) | 90 | 800 |
| Класичний манікюр | 60 | 500 |
| Корекція гелем | 90 | 900 |
| Френч | 30 | 200 |

(Prices/durations above are placeholders for testing — swap in the real price list.)

---

### Task 1: Add Localizable.xcstrings keys for the popup

**Files:**
- Modify: `Manik/Manik/Localizable/Localizable.xcstrings`

**Interfaces:**
- Consumes: nothing.
- Produces: string keys `schedule.createSlot.dateLabel`, `schedule.createSlot.startLabel`,
  `schedule.createSlot.endLabel`, `schedule.createSlot.servicesHeader`,
  `schedule.createSlot.cancel`, `schedule.createSlot.create` — consumed by
  `CreateBlockPopup` in Task 6.

- [ ] **Step 1: Insert the six new entries**

Open the file and find the `"schedule.slot.addFreeTime"` entry (it ends with a `},` line
right before `"tabBar.tab.account"`). Insert these six entries directly after it, keeping
the same two-space-per-level indentation as the surrounding entries:

```json
    "schedule.createSlot.cancel" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Cancel"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Скасувати"
          }
        }
      }
    },
    "schedule.createSlot.create" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Create"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Створити"
          }
        }
      }
    },
    "schedule.createSlot.dateLabel" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Date"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Дата"
          }
        }
      }
    },
    "schedule.createSlot.endLabel" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Ends"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Кінець"
          }
        }
      }
    },
    "schedule.createSlot.servicesHeader" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Services"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Послуги"
          }
        }
      }
    },
    "schedule.createSlot.startLabel" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Starts"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Початок"
          }
        }
      }
    },
```

Note the trailing comma stays on the `"schedule.slot.addFreeTime"` entry's closing `},` —
you're inserting these as additional siblings before `"tabBar.tab.account"`, so the last
one you add (`schedule.createSlot.startLabel`) also needs its own trailing comma preserved
exactly as shown (it's followed by `"tabBar.tab.account"`).

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; json.load(open('Manik/Manik/Localizable/Localizable.xcstrings'))" && echo OK`
Expected: `OK` (no `json.decoder.JSONDecodeError`)

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Localizable/Localizable.xcstrings
git commit -m "Add localization keys for create-slot popup"
```

---

### Task 2: Add ScheduleMetrics constants for the popup

**Files:**
- Modify: `Manik/Manik/Master/Schedule/ScheduleMetrics.swift`

**Interfaces:**
- Consumes: nothing.
- Produces: `ScheduleMetrics.CreatePopup.{cornerRadius,cardPadding,rowSpacing,dimOpacity}`,
  `ScheduleMetrics.CreatePopup.defaultDurationMinutes` — consumed by `CreateBlockPopup`
  (Task 6) and `CreateBlockViewModel` (Task 5).

- [ ] **Step 1: Add the nested enum**

Edit `Manik/Manik/Master/Schedule/ScheduleMetrics.swift` to add a new nested type
alongside the existing `Size`/`Spacing`:

```swift
import SwiftUI

enum ScheduleMetrics {
    static let workingHours = 8..<22

    enum Size {
        static let hourLabelWidth: CGFloat = 48
    }

    enum Spacing {
        static let rowSpacing: CGFloat = 16
        static let timelineHorizontalPadding: CGFloat = 16
    }

    enum CreatePopup {
        static let cornerRadius: CGFloat = 20
        static let cardPadding: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        static let dimOpacity: Double = 0.4
        static let defaultDurationMinutes = 30
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleMetrics.swift
git commit -m "Add ScheduleMetrics constants for create-slot popup"
```

(No build check yet — `CreatePopup` isn't referenced by anything until Task 6; the build
gate at Task 3 will already prove this file compiles since it's part of the same target.)

---

### Task 3: Add `MinuteIntervalTimePicker` to UICommons

**Files:**
- Create: `Manik/Manik/Assets/UICommons/MinuteIntervalTimePicker.swift`

**Interfaces:**
- Consumes: nothing (wraps `UIDatePicker` directly, no app types).
- Produces: `struct MinuteIntervalTimePicker: UIViewRepresentable` with
  `init(date: Binding<Date>, minuteInterval: Int)` — consumed by `CreateBlockPopup`
  (Task 6) for the "Початок"/"Кінець" rows.

This is a plain SwiftUI `DatePicker` doesn't support 15-minute step snapping
(`minuteInterval` is a `UIDatePicker`-only property) — this wraps `UIDatePicker` directly
to get it, while keeping the same compact "tap to expand a wheel" interaction the native
`DatePicker(.compact)` style gives for free. It lives in `UICommons` because it has zero
dependency on Schedule's types (same bar `DashedSlot`/`WeekDayStrip` already cleared).

- [ ] **Step 1: Create the file**

```swift
import SwiftUI
import UIKit

struct MinuteIntervalTimePicker: UIViewRepresentable {
    @Binding var date: Date
    let minuteInterval: Int

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.minuteInterval = minuteInterval
        picker.date = date
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }

    final class Coordinator: NSObject {
        let date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            date.wrappedValue = sender.date
        }
    }
}

#Preview {
    @Previewable @State var date = Date()

    MinuteIntervalTimePicker(date: $date, minuteInterval: 15)
        .padding()
        .background(Color.background)
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manual preview check**

Open the `#Preview` for `MinuteIntervalTimePicker.swift` in Xcode's canvas. Expected: a
compact time control showing the current time; tapping it pops up a wheel that only lands
on `:00`/`:15`/`:30`/`:45` minute values.

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Assets/UICommons/MinuteIntervalTimePicker.swift
git commit -m "Add MinuteIntervalTimePicker to UICommons"
```

---

### Task 4: Add fake repositories + sample services for previews

**Files:**
- Create: `Manik/Manik/Master/Schedule/FakeBlockRepository.swift`
- Create: `Manik/Manik/Master/Schedule/FakeServiceRepository.swift`
- Create: `Manik/Manik/Master/Schedule/SchedulePreviewData.swift`

**Interfaces:**
- Consumes: `BlockRepository`, `ServiceRepository` (existing protocols), `Block`/`Service`
  (existing models).
- Produces (all `#if DEBUG`-only): `FakeBlockRepository(blocks: [Block] = [])`,
  `FakeServiceRepository(services: [Service])`, `SchedulePreviewData.services: [Service]`
  — consumed by `CreateBlockViewModel`'s and `CreateBlockPopup`'s `#Preview`s (Tasks 5–6).

This intentionally does **not** include `FakeUserRepository`/`profiles`/sample `blocks`
from the stashed PR5 plan — those depend on `UserRepository`, which doesn't exist yet on
this branch and isn't needed until the next step (rendering blocks). Keeping this file
scoped to only what this PR uses. Split into three files (rather than one) so each type
gets its own file, per project convention.

- [ ] **Step 1: Create `FakeBlockRepository.swift`**

```swift
#if DEBUG
struct FakeBlockRepository: BlockRepository {
    var blocks: [Block] = []

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { continuation in
            continuation.yield(blocks)
        }
    }

    func addBlock(_ block: Block) async throws {}
    func confirm(blockId: String) async throws {}
    func decline(blockId: String) async throws {}
    func cancel(blockId: String) async throws {}

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {}
}
#endif
```

- [ ] **Step 2: Create `FakeServiceRepository.swift`**

```swift
#if DEBUG
struct FakeServiceRepository: ServiceRepository {
    let services: [Service]

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            continuation.yield(services)
        }
    }

    func add(_ service: Service) async throws {}
    func update(_ service: Service) async throws {}
    func delete(id: String) async throws {}
}
#endif
```

- [ ] **Step 3: Create `SchedulePreviewData.swift`**

```swift
#if DEBUG
enum SchedulePreviewData {
    static let services: [Service] = [
        Service(id: "svc-hybrid", name: "Манікюр гібридний (гель-лак)", durationMinutes: 90, price: 800),
        Service(id: "svc-classic", name: "Класичний манікюр", durationMinutes: 60, price: 500),
        Service(id: "svc-gel-correction", name: "Корекція гелем", durationMinutes: 90, price: 900),
        Service(id: "svc-french", name: "Френч", durationMinutes: 30, price: 200)
    ]
}
#endif
```

- [ ] **Step 4: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add Manik/Manik/Master/Schedule/FakeBlockRepository.swift
git add Manik/Manik/Master/Schedule/FakeServiceRepository.swift
git add Manik/Manik/Master/Schedule/SchedulePreviewData.swift
git commit -m "Add fake repositories and sample services for Schedule previews"
```

---

### Task 5: Add `CreateBlockViewModel`

**Files:**
- Create: `Manik/Manik/Master/Schedule/CreateBlockViewModel.swift`

**Interfaces:**
- Consumes: `BlockRepository.addBlock(_:) async throws` (existing), `Service`/`Block`
  (existing models), `DateFormat.date`/`DateFormat.time`/`DateFormat.salonTimeZone`
  (existing), `ScheduleMetrics.CreatePopup.defaultDurationMinutes` (Task 2).
- Produces: `@Observable final class CreateBlockViewModel` with
  `init(date: Date, startHour: Int, services: [Service], blockRepository: BlockRepository = FirestoreBlockRepository())`,
  properties `date: Date`, `startTime: Date`, `endTime: Date`,
  `selectedServiceIds: Set<String>`, `services: [Service]` (read-only, passed through from
  init), `errorMessage: String?`, `isSaving: Bool`, computed `canSubmit: Bool`,
  `func isSelected(_ service: Service) -> Bool`, `func toggleSelection(of service: Service)`,
  and `func submit() async -> Bool` — all consumed by `CreateBlockPopup` (Task 6). Selection
  logic lives here (not as a `Binding(get:set:)` built in the view body) so the view stays
  pure layout.

- [ ] **Step 1: Create the file**

```swift
import Foundation
import Observation

@MainActor
@Observable
final class CreateBlockViewModel {
    var date: Date
    var startTime: Date
    var endTime: Date
    var selectedServiceIds: Set<String> = []
    var errorMessage: String?
    var isSaving = false

    let services: [Service]

    private let blockRepository: BlockRepository

    init(
        date: Date,
        startHour: Int,
        services: [Service],
        blockRepository: BlockRepository = FirestoreBlockRepository()
    ) {
        self.date = date
        self.services = services
        self.blockRepository = blockRepository

        let start = Self.calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? date
        self.startTime = start
        self.endTime = Self.calendar.date(
            byAdding: .minute,
            value: ScheduleMetrics.CreatePopup.defaultDurationMinutes,
            to: start
        ) ?? start
    }

    var canSubmit: Bool {
        endTime > startTime && !selectedServiceIds.isEmpty
    }

    func isSelected(_ service: Service) -> Bool {
        guard let id = service.id else { return false }
        return selectedServiceIds.contains(id)
    }

    func toggleSelection(of service: Service) {
        guard let id = service.id else { return }
        if selectedServiceIds.contains(id) {
            selectedServiceIds.remove(id)
        } else {
            selectedServiceIds.insert(id)
        }
    }

    func submit() async -> Bool {
        guard canSubmit else { return false }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let block = Block(
            id: nil,
            date: DateFormat.date.string(from: date),
            startTime: DateFormat.time.string(from: startTime),
            endTime: DateFormat.time.string(from: endTime),
            offeredServiceIds: Array(selectedServiceIds),
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )

        do {
            try await blockRepository.addBlock(block)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DateFormat.salonTimeZone
        return calendar
    }
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Master/Schedule/CreateBlockViewModel.swift
git commit -m "Add CreateBlockViewModel"
```

---

### Task 6: Add `CreateBlockFieldRow`, `ServicesChecklist`, and `CreateBlockPopup`

**Files:**
- Create: `Manik/Manik/Master/Schedule/CreateBlockFieldRow.swift`
- Create: `Manik/Manik/Master/Schedule/ServicesChecklist.swift`
- Create: `Manik/Manik/Master/Schedule/CreateBlockPopup.swift`

**Interfaces:**
- Consumes: `CreateBlockViewModel` (Task 5), `MinuteIntervalTimePicker` (Task 3),
  `ScheduleMetrics.CreatePopup.*` (Task 2), `SchedulePreviewData`/`FakeBlockRepository`
  (Task 4), string keys from Task 1.
- Produces: `struct CreateBlockFieldRow<Control: View>: View` with
  `init(labelKey: LocalizedStringKey, control: () -> Control)`; `struct ServicesChecklist: View`
  with `init(services: [Service], isSelected: (Service) -> Bool, onToggle: (Service) -> Void)`;
  `struct CreateBlockPopup: View` with
  `init(date: Date, startHour: Int, services: [Service], blockRepository: BlockRepository = FirestoreBlockRepository(), onDismiss: @escaping () -> Void)`
  — the latter consumed by `ScheduleView` (Task 8).

`CreateBlockFieldRow` and `ServicesChecklist` are split into their own files/types instead
of being computed properties on `CreateBlockPopup`: the three date/time rows were
near-duplicates of each other (good DRY candidate for one reusable row), and
`ServicesChecklist` takes plain data + closures rather than the view model directly — the
same "presentational piece, not the view model" pattern already used for
`ScheduleBlockCard`/`ScheduleBlockDetailSheet`.

- [ ] **Step 1: Create `CreateBlockFieldRow.swift`**

```swift
import SwiftUI

struct CreateBlockFieldRow<Control: View>: View {
    let labelKey: LocalizedStringKey
    @ViewBuilder let control: Control

    var body: some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)
            Spacer()
            control
        }
    }
}

#Preview {
    CreateBlockFieldRow(labelKey: "schedule.createSlot.dateLabel") {
        DatePicker("", selection: .constant(Date.now), displayedComponents: .date)
            .labelsHidden()
    }
    .padding()
    .background(Color.background)
}
```

- [ ] **Step 2: Create `ServicesChecklist.swift`**

This renders each service as a full-row `Button` (not a `Toggle`) so selection state lives
in the view model rather than a `Binding(get:set:)` built in the view body, and so each row
gets an explicit 44pt minimum tap height. It also reads as a checkbox list (checkmark icon)
rather than an iOS switch, matching the checkbox look asked for — SwiftUI has no native
checkbox toggle style on iOS (that's macOS-only).

```swift
import SwiftUI

struct ServicesChecklist: View {
    let services: [Service]
    let isSelected: (Service) -> Bool
    let onToggle: (Service) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(services) { service in
                Button {
                    onToggle(service)
                } label: {
                    HStack {
                        Text(service.name)
                        Spacer()
                        Image(systemName: isSelected(service) ? "checkmark.square.fill" : "square")
                    }
                    .frame(minHeight: 44)
                }
            }
        }
        .font(.elmsSans(.regular, 15))
        .foregroundStyle(Color.ink)
        .buttonStyle(.plain)
    }
}

#Preview {
    ServicesChecklist(
        services: SchedulePreviewData.services,
        isSelected: { _ in false },
        onToggle: { _ in }
    )
    .padding()
    .background(Color.background)
}
```

- [ ] **Step 3: Create `CreateBlockPopup.swift`**

```swift
import SwiftUI

struct CreateBlockPopup: View {
    @State private var viewModel: CreateBlockViewModel
    let onDismiss: () -> Void

    init(
        date: Date,
        startHour: Int,
        services: [Service],
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CreateBlockViewModel(
            date: date,
            startHour: startHour,
            services: services,
            blockRepository: blockRepository
        ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            Color.black.opacity(ScheduleMetrics.CreatePopup.dimOpacity)
                .ignoresSafeArea()

            card
                .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.CreatePopup.rowSpacing) {
            CreateBlockFieldRow(labelKey: "schedule.createSlot.dateLabel") {
                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                    .labelsHidden()
            }

            CreateBlockFieldRow(labelKey: "schedule.createSlot.startLabel") {
                MinuteIntervalTimePicker(date: $viewModel.startTime, minuteInterval: 15)
            }

            CreateBlockFieldRow(labelKey: "schedule.createSlot.endLabel") {
                MinuteIntervalTimePicker(date: $viewModel.endTime, minuteInterval: 15)
            }

            Color.surface
                .frame(height: 1)

            servicesHeader

            ServicesChecklist(
                services: viewModel.services,
                isSelected: viewModel.isSelected,
                onToggle: viewModel.toggleSelection
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.elmsSans(.regular, 13))
                    .foregroundStyle(.red)
            }

            buttons
        }
        .padding(ScheduleMetrics.CreatePopup.cardPadding)
        .background(Color.background, in: .rect(cornerRadius: ScheduleMetrics.CreatePopup.cornerRadius))
    }

    private var servicesHeader: some View {
        Text("schedule.createSlot.servicesHeader")
            .font(.elmsSans(.bold, 16))
            .foregroundStyle(Color.ink)
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            Button("schedule.createSlot.cancel", action: onDismiss)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.textSecondary)
                .frame(minHeight: 44)

            Spacer()

            Button(action: handleCreate) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("schedule.createSlot.create")
                        .font(.elmsSans(.bold, 15))
                }
            }
            .foregroundStyle(.white)
            .frame(minHeight: 44)
            .padding(.horizontal, 20)
            .background(Color.ink, in: .capsule)
            .disabled(viewModel.isSaving || !viewModel.canSubmit)
            .opacity(viewModel.isSaving || !viewModel.canSubmit ? 0.4 : 1)
        }
        .buttonStyle(.plain)
    }

    private func handleCreate() {
        Task {
            if await viewModel.submit() {
                onDismiss()
            }
        }
    }
}

#Preview {
    Color.background
        .overlay {
            CreateBlockPopup(
                date: .now,
                startHour: 17,
                services: SchedulePreviewData.services,
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}
```

- [ ] **Step 4: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Manual preview check**

Open the `#Preview` for `CreateBlockPopup.swift`. Expected: a dimmed background behind a
centered rounded card showing "Дата" (today, tappable), "Початок" (17:00, tappable wheel
snapping to :00/:15/:30/:45), "Кінець" (17:30), a "Послуги" header with 4 checkbox-style
rows (all unchecked), and "Скасувати"/"Створити" — "Створити" should render disabled/dimmed
since no service is checked yet. Tap a service row — its icon should switch to a filled
checkmark square and "Створити" should become enabled. Also open the `#Preview`s for
`CreateBlockFieldRow.swift` and `ServicesChecklist.swift` individually — each should render
correctly on its own.

- [ ] **Step 6: Commit**

```bash
git add Manik/Manik/Master/Schedule/CreateBlockFieldRow.swift
git add Manik/Manik/Master/Schedule/ServicesChecklist.swift
git add Manik/Manik/Master/Schedule/CreateBlockPopup.swift
git commit -m "Add CreateBlockPopup"
```

---

### Task 7: Wire `HourlyTimelineView`'s dashed slot to report which hour was tapped

**Files:**
- Modify: `Manik/Manik/Master/Schedule/HourlyTimelineView.swift`

**Interfaces:**
- Consumes: existing `DashedSlot(title:action:)`.
- Produces: `HourlyTimelineView(onTapHour: (Int) -> Void)` — consumed by `ScheduleView`
  (Task 8).

- [ ] **Step 1: Add the callback parameter and wire it**

Replace the full contents of `Manik/Manik/Master/Schedule/HourlyTimelineView.swift`:

```swift
import SwiftUI

struct HourlyTimelineView: View {
    let onTapHour: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.rowSpacing) {
                ForEach(ScheduleMetrics.workingHours, id: \.self) { hour in
                    Text(String(format: "%02d:00", hour))
                        .font(.elmsSans(.bold, 16))
                        .foregroundStyle(Color.textSecondary)

                    DashedSlot(title: "schedule.slot.addFreeTime") {
                        onTapHour(hour)
                    }
                    .padding(.leading, ScheduleMetrics.Size.hourLabelWidth)
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
            .padding(.vertical, ScheduleMetrics.Spacing.rowSpacing)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    HourlyTimelineView(onTapHour: { _ in })
        .background(Color.background)
}
```

- [ ] **Step 2: Commit**

```bash
git add Manik/Manik/Master/Schedule/HourlyTimelineView.swift
git commit -m "Report tapped hour from HourlyTimelineView's dashed slot"
```

(No build check — `ScheduleView` still passes the old zero-arg init until Task 8, so the
target won't compile between these two tasks. Build gate is at Task 8.)

---

### Task 8: Add `CreateBlockContext` and wire `ScheduleView` to load services and present the popup

**Files:**
- Create: `Manik/Manik/Master/Schedule/CreateBlockContext.swift`
- Modify: `Manik/Manik/Master/Schedule/ScheduleView.swift`

**Interfaces:**
- Consumes: `ServiceRepository.observeServices() -> AsyncStream<[Service]>` (existing),
  `HourlyTimelineView(onTapHour:)` (Task 7), `CreateBlockPopup(date:startHour:services:onDismiss:)`
  (Task 6).
- Produces: `struct CreateBlockContext: Identifiable` (`date: Date`, `startHour: Int`).
  Nothing here is consumed by later tasks — this is the last task in this plan.

- [ ] **Step 1: Create `CreateBlockContext.swift`**

`CreateBlockContext` gets its own file rather than living alongside `ScheduleView` in the
same file, per the one-type-per-file convention.

```swift
import Foundation

struct CreateBlockContext: Identifiable {
    let id = UUID()
    let date: Date
    let startHour: Int
}
```

- [ ] **Step 2: Replace `ScheduleView.swift`'s contents**

```swift
import SwiftUI

struct ScheduleView: View {
    private let serviceRepository: ServiceRepository

    @State private var selectedDate = Date.now
    @State private var services: [Service] = []
    @State private var creatingBlockContext: CreateBlockContext?

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                title
                date
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)

            WeekDayStrip(selectedDate: $selectedDate)
                .padding(.vertical, 12)

            Color.surface
                .frame(height: 1)

            HourlyTimelineView { hour in
                creatingBlockContext = CreateBlockContext(date: selectedDate, startHour: hour)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            for await updatedServices in serviceRepository.observeServices() {
                services = updatedServices
            }
        }
        .fullScreenCover(item: $creatingBlockContext) { context in
            CreateBlockPopup(
                date: context.date,
                startHour: context.startHour,
                services: services,
                onDismiss: { creatingBlockContext = nil }
            )
            .presentationBackground(.clear)
        }
    }

    private var title: some View {
        Text("schedule.title")
            .font(.elmsSans(.bold, 28))
            .foregroundStyle(Color.ink)
    }

    private var date: some View {
        Text(DateFormat.monthYear.string(from: selectedDate).capitalized)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.textSecondary)
    }
}

#Preview {
    ScheduleView(serviceRepository: FakeServiceRepository(services: SchedulePreviewData.services))
}
```

- [ ] **Step 3: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Manual preview check**

Open the `#Preview` for `ScheduleView.swift`. Expected: the familiar week strip + hourly
timeline. Tap any hour's "+ Додати вільний час". Expected: `CreateBlockPopup` appears
centered, dimmed backdrop behind it, pre-filled with today's date and that hour as start
time, 4 services listed (from `SchedulePreviewData`). Tap "Скасувати" — popup closes, no
crash. Tap an hour again, check a service, tap "Створити" — popup closes (the fake
repository's `addBlock` is a no-op, so nothing else changes, which is expected — the real
`FirestoreBlockRepository` is only exercised by the shipped app, not the preview).

- [ ] **Step 5: Manual on-device/simulator check**

Run the app in the iOS Simulator (master account), open the "Розклад" tab, tap "+ Додати
вільний час" on some hour, select at least one service, tap "Створити". Open Firebase
Console → Firestore → `blocks` collection. Expected: a new document with `status:
"available"`, `date`/`startTime`/`endTime` matching what was picked, and
`offeredServiceIds` containing the selected service's document ID(s).

- [ ] **Step 6: Commit**

```bash
git add Manik/Manik/Master/Schedule/CreateBlockContext.swift
git add Manik/Manik/Master/Schedule/ScheduleView.swift
git commit -m "Wire ScheduleView to load services and present CreateBlockPopup"
```
