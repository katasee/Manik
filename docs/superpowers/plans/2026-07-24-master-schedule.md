# Master Schedule Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the master's "Розклад" (Schedule) screen — a swipeable week-day strip
over an 08:00–22:00 hourly timeline showing `pending`/`confirmed` blocks as
proportional-height cards, tappable into a read-only detail sheet.

**Slice scope (this PR = the Schedule *shell* only):** After building the full read-only
view we deliberately shrank this PR to just the static screen shown in the mockup: a
"Розклад" title, the horizontal week-day strip, and a vertical 08:00–21:00 timeline where
**every** hour is a label on its own row with a "+ Додати вільний час" (`DashedSlot`) in
the gap below it. **No block rendering, no cards, no detail sheet, no data loading** in this
PR. `DashedSlot` is a tappable button whose action is empty here — a **deliberate no-op**,
not a bug; wiring it to actually create a slot is the first follow-up slice.

The block-rendering work described in the tasks below (`ScheduleBlockCard`,
`ScheduleBlockDetailSheet`, `ScheduleViewModel`, `SchedulePreviewData`, `UserRepository`/
`FirestoreUserRepository`, and the block-integrated `HourlyTimelineView`/`ScheduleView`)
was built, then **git-stashed** for reuse in later slices rather than deleted:

```
git stash list   # "schedule block components for future slices: ..."
```

Pop it (`git stash pop`) when starting Slice 2/3 below. On reuse it needs a few shared-file
fixups that were reverted to keep this PR minimal: `Block.startMinutes`/`endMinutes`, the
`schedule.status.*`/`schedule.client.*`/`schedule.service.*` catalog keys, and
`ScheduleMetrics.Size.cardBorderWidth`. Rationale: prefer small vertical slices that each
work end-to-end over one large horizontally-layered PR where only viewing functions.

**What actually ships in this PR:**
- `Master/Schedule/` — `ScheduleView` (title + week strip + timeline, `@State selectedDate`,
  no view model), `HourlyTimelineView` (an hour label per row with a `DashedSlot` in the gap
  below it, no block logic), `ScheduleMetrics` (trimmed to `workingHours`, `hourLabelWidth`,
  `rowSpacing`, `timelineHorizontalPadding`).
- `Assets/UICommons/` (reusable, feature-agnostic, decoupled from `ScheduleMetrics` via their
  own private `Layout` constants) — `WeekDayStrip` (week-day date picker) and `DashedSlot`
  (tappable dashed-outline labeled slot; caller passes label + action, so the
  `schedule.slot.addFreeTime` string stays in `HourlyTimelineView`).
- `DateFormat` split into **storage** formatters (`date`/`time`, pinned `en_US_POSIX` so
  Firestore strings never vary by device) and **display** formatters
  (`dayNumber`/`weekdayLetter`/`monthYear`, `Locale.current` so on-screen dates follow the
  app's language — the app is multilingual via the String Catalog, not Ukrainian-hardcoded).
- Catalog keys: `schedule.title`, `schedule.slot.addFreeTime`, `tabBar.tab.schedule`.
- Tab-bar fix (`TabBar/`): scrollable content was hidden behind the floating bar. Fixed by
  reserving space with a `Color.clear` `.safeAreaInset(edge: .bottom)` of
  `TabBarMetrics.Size.reservedClearance` (`capsuleHeight + activeCircleOverhang + bottomInset`)
  in both cabinet roots, while the bar stays a `ZStack` overlay so its `matchedGeometryEffect`
  switch animation keeps a stable identity and stays smooth.

Reusable UI components live in `Assets/UICommons/`, not the feature folder.

**Architecture:** MVVM. A new `ScheduleViewModel` subscribes to the existing
`observeBlocks()`/`observeServices()` `AsyncStream`s and filters client-side by the
selected date (no repository changes). A new `UserRepository` protocol +
`FirestoreUserRepository` resolve a booked block's client name by uid, cached in the
view model. Presentational pieces (`WeekDayStrip`, `HourlyTimelineView`,
`ScheduleBlockCard`, `ScheduleBlockDetailSheet`) take plain data/closures, not the view
model, so each can be previewed standalone.

**Tech Stack:** SwiftUI, `@Observable`/`@MainActor`, Firebase Firestore
(`FirebaseFirestore`), existing `Block`/`Service`/`UserProfile` models.

## Global Constraints

- Full-spec reference: `docs/superpowers/specs/2026-07-24-master-schedule-design.md`
  (view-only scope — no block creation/edit/cancel in this plan).
- Build gate: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
  must succeed (`BUILD SUCCEEDED`) before any task counts as done.
- **No test target/linter/formatter exists in this project.** In place of automated
  test steps, each task's verification step is (a) the build gate above, and (b) for
  tasks that add a `#Preview`, a manual-inspection description of exactly what should
  render — open that preview in Xcode's canvas and compare.
- `@Observable` macro (not `ObservableObject`); views hold view models via
  `@State private var viewModel = ...`.
- Feature-based folders: this feature's files live in `Manik/Manik/Master/Schedule/`.
  Shared models stay in `Manik/Manik/Models/`.
- `Block.date`/`startTime`/`endTime` are plain `String`s produced only via
  `Manik/Manik/Utilities/DateFormat.swift` — never an inline `DateFormatter`.
- Repository protocols (`Services/Repositories/`) must not import Firebase; concrete
  Firestore implementations live in `Services/Firestore/`.
- Any function/initializer call with 3+ arguments: one argument per line.
- User-facing strings are never bare literals — add to
  `Manik/Manik/Localizable/Localizable.xcstrings` under a `feature.kind.name` key, in
  the same task that introduces the string.
- Text never uses the system font — always `.elmsSans(weight, size)`
  (`Manik/Manik/Assets/UICommons/Extension+ElmsSans.swift`).
- Current color assets available: `Color.background`, `Color.ink`, `Color.surface`,
  `Color.fieldBackground`, `Color.textSecondary`, `Color.badge`,
  `Color.statusPending` (#CC6E00), `Color.statusConfirmed` (#008C0E) — all already
  committed on this branch.

---

### Task 1: Extend `DateFormat` with weekday-letter and day-number formatters

**Files:**
- Modify: `Manik/Manik/Utilities/DateFormat.swift`

**Interfaces:**
- Produces: `DateFormat.weekdayLetter: DateFormatter` (e.g. "10.07.2026" → "П"),
  `DateFormat.dayNumber: DateFormatter` (e.g. "10.07.2026" → "10"). Both already pinned
  to `DateFormat.salonTimeZone`.

- [ ] **Step 1: Add the two formatters**

Replace the file's contents with:

```swift
import Foundation

enum DateFormat {
    static let date = formatter("yyyy-MM-dd")
    static let time = formatter("HH:mm")
    static let dayNumber = formatter("d")
    static let weekdayLetter: DateFormatter = {
        let dateFormatter = formatter("EEEEE")
        dateFormatter.locale = Locale(identifier: "uk_UA")
        return dateFormatter
    }()

    static let salonTimeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = salonTimeZone
        return formatter
    }
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Utilities/DateFormat.swift
git commit -m "Add weekday-letter and day-number formatters to DateFormat"
```

---

### Task 2: Add `UserRepository` protocol + `FirestoreUserRepository`

**Files:**
- Create: `Manik/Manik/Services/Repositories/UserRepository.swift`
- Create: `Manik/Manik/Services/Firestore/FirestoreUserRepository.swift`

**Interfaces:**
- Consumes: `UserProfile` (`Manik/Manik/Models/UserProfile.swift`, already has
  `uid`/`role`/`name`/`email` and is `Codable`).
- Produces: `protocol UserRepository { func fetchProfile(uid: String) async throws -> UserProfile }`
  and `final class FirestoreUserRepository: UserRepository`.

- [ ] **Step 1: Write the protocol**

`Manik/Manik/Services/Repositories/UserRepository.swift`:

```swift
protocol UserRepository {
    func fetchProfile(uid: String) async throws -> UserProfile
}
```

- [ ] **Step 2: Write the Firestore implementation**

`Manik/Manik/Services/Firestore/FirestoreUserRepository.swift`:

```swift
import FirebaseFirestore

final class FirestoreUserRepository: UserRepository {
    private let db = Firestore.firestore()

    func fetchProfile(uid: String) async throws -> UserProfile {
        try await db.collection("users").document(uid).getDocument(as: UserProfile.self)
    }
}
```

- [ ] **Step 3: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Services/Repositories/UserRepository.swift Manik/Manik/Services/Firestore/FirestoreUserRepository.swift
git commit -m "Add UserRepository for resolving a user's profile by uid"
```

---

### Task 3: Add Schedule localization keys

**Files:**
- Modify: `Manik/Manik/Localizable/Localizable.xcstrings`

**Interfaces:**
- Produces string-catalog keys consumed by later tasks:
  `schedule.status.pending`, `schedule.status.confirmed`,
  `schedule.client.loading`, `schedule.client.fallback`, `schedule.service.unknown`,
  `schedule.slot.addFreeTime`.

- [ ] **Step 1: Add the six keys**

Open `Manik/Manik/Localizable/Localizable.xcstrings` and add these entries to the
`"strings"` object (keep existing entries as-is, insert alphabetically alongside the
other keys — exact position in the JSON doesn't matter, String Catalog editor will
re-sort):

```json
    "schedule.client.fallback" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Client"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Клієнтка"
          }
        }
      }
    },
    "schedule.client.loading" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Loading…"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Завантаження…"
          }
        }
      }
    },
    "schedule.service.unknown" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Service"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Послуга"
          }
        }
      }
    },
    "schedule.status.confirmed" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Confirmed"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Підтверджено"
          }
        }
      }
    },
    "schedule.status.pending" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Pending"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Очікує"
          }
        }
      }
    },
    "schedule.slot.addFreeTime" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "+ Add free time"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "+ Додати вільний час"
          }
        }
      }
    },
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED` (a malformed `.xcstrings` JSON fails the build — this step
also catches JSON syntax errors from the manual edit)

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Localizable/Localizable.xcstrings
git commit -m "Add localization keys for Schedule screen"
```

---

### Task 4: Add `ScheduleMetrics` constants

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleMetrics.swift`

**Interfaces:**
- Produces: `ScheduleMetrics.workingHours: Range<Int>`,
  `ScheduleMetrics.Size.{hourHeight,hourLabelWidth,dayCellSize,dashedBorderWidth}`,
  `ScheduleMetrics.Spacing.{daySpacing,cardHorizontalPadding,cardVerticalPadding,timelineHorizontalPadding}`,
  `ScheduleMetrics.CornerRadius.card`, `ScheduleMetrics.AnimationStyle.daySelection`.
  Every later task in this plan reads these instead of hardcoding numbers. Corner radius
  (16) and the dashed border width (1.5) match the "Календар майстра" mockup screen
  (`.bookedcard`/`.addslot` in the mockup's CSS both use `border-radius: 16px`;
  `.addslot` uses `border: 1.5px dashed`).

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

enum ScheduleMetrics {
    static let workingHours = 8..<22

    enum Size {
        static let hourHeight: CGFloat = 64
        static let hourLabelWidth: CGFloat = 48
        static let dayCellSize: CGFloat = 44
        static let dashedBorderWidth: CGFloat = 1.5
    }

    enum Spacing {
        static let daySpacing: CGFloat = 8
        static let cardHorizontalPadding: CGFloat = 12
        static let cardVerticalPadding: CGFloat = 8
        static let timelineHorizontalPadding: CGFloat = 16
    }

    enum CornerRadius {
        static let card: CGFloat = 16
    }

    enum AnimationStyle {
        static let daySelection = Animation.spring(response: 0.35, dampingFraction: 0.75)
    }
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleMetrics.swift
git commit -m "Add ScheduleMetrics constants"
```

---

### Task 5: Add preview-only fake repositories and sample data

**Files:**
- Create: `Manik/Manik/Master/Schedule/SchedulePreviewData.swift`

**Interfaces:**
- Consumes: `BlockRepository`, `ServiceRepository`, `UserRepository` (protocols from
  Task 2 and existing code), `Block`/`Service`/`UserProfile` models.
- Produces (all `#if DEBUG`-only, used by later `#Preview`s):
  `FakeBlockRepository(blocks: [Block])`, `FakeServiceRepository(services: [Service])`,
  `FakeUserRepository(profiles: [String: UserProfile])`,
  `SchedulePreviewData.{services,profiles,blocks}`.

- [ ] **Step 1: Create the file**

```swift
#if DEBUG
import Foundation

struct FakeBlockRepository: BlockRepository {
    let blocks: [Block]

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

struct FakeUserRepository: UserRepository {
    let profiles: [String: UserProfile]

    func fetchProfile(uid: String) async throws -> UserProfile {
        guard let profile = profiles[uid] else {
            throw NSError(
                domain: "FakeUserRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No fake profile for \(uid)"]
            )
        }
        return profile
    }
}

enum SchedulePreviewData {
    static let today = DateFormat.date.string(from: Date())

    static let services: [Service] = [
        Service(id: "svc-manicure", name: "Манікюр", durationMinutes: 60, price: 500),
        Service(id: "svc-pedicure", name: "Педикюр", durationMinutes: 90, price: 700)
    ]

    static let profiles: [String: UserProfile] = [
        "client-1": UserProfile(
            uid: "client-1",
            role: .client,
            name: "Оксана Коваль",
            email: "oksana@example.com"
        ),
        "client-2": UserProfile(
            uid: "client-2",
            role: .client,
            name: "Марія Гриб",
            email: "maria@example.com"
        )
    ]

    static let blocks: [Block] = [
        Block(
            id: "block-1",
            date: today,
            startTime: "10:00",
            endTime: "11:30",
            offeredServiceIds: ["svc-manicure"],
            bookedServiceId: "svc-manicure",
            status: .confirmed,
            clientId: "client-1"
        ),
        Block(
            id: "block-2",
            date: today,
            startTime: "14:00",
            endTime: "15:30",
            offeredServiceIds: ["svc-pedicure"],
            bookedServiceId: "svc-pedicure",
            status: .pending,
            clientId: "client-2"
        ),
        Block(
            id: "block-3",
            date: today,
            startTime: "12:00",
            endTime: "13:00",
            offeredServiceIds: ["svc-manicure"],
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )
    ]
}
#endif
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Master/Schedule/SchedulePreviewData.swift
git commit -m "Add fake repositories and sample data for Schedule previews"
```

---

### Task 6: Build `WeekDayStrip`

**Files:**
- Create: `Manik/Manik/Master/Schedule/WeekDayStrip.swift`

**Interfaces:**
- Consumes: `ScheduleMetrics` (Task 4), `DateFormat.weekdayLetter`/`DateFormat.dayNumber`
  (Task 1), `Color.ink`/`Color.surface`/`Color.textSecondary` (existing assets).
- Produces: `struct WeekDayStrip: View { init(selectedDate: Binding<Date>) }` — consumed
  by `ScheduleView` in Task 12.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct WeekDayStrip: View {
    @Binding var selectedDate: Date
    @Namespace private var namespace

    private var weekDates: [Date] {
        Self.weekDates(containing: selectedDate)
    }

    var body: some View {
        HStack(spacing: ScheduleMetrics.Spacing.daySpacing) {
            ForEach(weekDates, id: \.self) { day in
                dayCell(day)
            }
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
        .gesture(weekSwipeGesture)
    }

    private var weekSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let dayShift = value.translation.width < 0 ? 7 : -7
                guard let newDate = Self.calendar.date(byAdding: .day, value: dayShift, to: selectedDate) else {
                    return
                }
                withAnimation(ScheduleMetrics.AnimationStyle.daySelection) {
                    selectedDate = newDate
                }
            }
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = Self.calendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = Self.calendar.isDateInToday(day)

        return Button {
            withAnimation(ScheduleMetrics.AnimationStyle.daySelection) {
                selectedDate = day
            }
        } label: {
            VStack(spacing: 2) {
                Text(DateFormat.weekdayLetter.string(from: day).uppercased())
                    .font(.elmsSans(.medium, 11))

                Text(DateFormat.dayNumber.string(from: day))
                    .font(.elmsSans(.bold, 15))
            }
            .foregroundStyle(isSelected ? .white : Color.textSecondary)
            .frame(width: ScheduleMetrics.Size.dayCellSize, height: ScheduleMetrics.Size.dayCellSize)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.ink)
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                } else if isToday {
                    Capsule()
                        .strokeBorder(Color.surface, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DateFormat.salonTimeZone
        calendar.firstWeekday = 2
        return calendar
    }()

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()

    WeekDayStrip(selectedDate: $selectedDate)
        .padding(.vertical, 24)
        .background(Color.background)
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `WeekDayStrip.swift` in Xcode's canvas. Expected: 7 day cells in
a row, today's cell has a thin outline, tapping a cell fills it with a dark capsule and
moves a smooth sliding highlight between cells, swiping the strip left/right jumps the
whole row to the next/previous week (day numbers change by 7).

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/WeekDayStrip.swift
git commit -m "Add WeekDayStrip component"
```

---

### Task 7: Build `ScheduleBlockCard`

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleBlockCard.swift`

**Interfaces:**
- Consumes: `Block` (existing model, needs `.status: BlockStatus`),
  `ScheduleMetrics`, `Color.statusPending`/`Color.statusConfirmed`/`Color.surface`/`Color.ink`/`Color.textSecondary`.
- Produces: `struct ScheduleBlockCard: View { init(block: Block, clientName: String, serviceName: String, action: @escaping () -> Void) }`
  — consumed by `HourlyTimelineView` in Task 10.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct ScheduleBlockCard: View {
    let block: Block
    let clientName: String
    let serviceName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ScheduleMetrics.Spacing.daySpacing) {
                statusPill

                VStack(alignment: .leading, spacing: 2) {
                    Text(clientName)
                        .font(.elmsSans(.semiBold, 14))
                        .foregroundStyle(Color.ink)

                    Text(serviceName)
                        .font(.elmsSans(.regular, 12))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.cardHorizontalPadding)
            .padding(.vertical, ScheduleMetrics.Spacing.cardVerticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface, in: .rect(cornerRadius: ScheduleMetrics.CornerRadius.card))
        }
        .buttonStyle(.plain)
    }

    private var statusPill: some View {
        Text(statusTextKey)
            .font(.elmsSans(.bold, 10))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor, in: .capsule)
    }

    private var statusColor: Color {
        block.status == .confirmed ? Color.statusConfirmed : Color.statusPending
    }

    private var statusTextKey: LocalizedStringKey {
        block.status == .confirmed ? "schedule.status.confirmed" : "schedule.status.pending"
    }
}

#Preview {
    VStack(spacing: 12) {
        ScheduleBlockCard(
            block: Block(
                id: "preview-confirmed",
                date: "2026-07-24",
                startTime: "10:00",
                endTime: "11:30",
                offeredServiceIds: ["svc-manicure"],
                bookedServiceId: "svc-manicure",
                status: .confirmed,
                clientId: "client-1"
            ),
            clientName: "Оксана Коваль",
            serviceName: "Манікюр",
            action: {}
        )

        ScheduleBlockCard(
            block: Block(
                id: "preview-pending",
                date: "2026-07-24",
                startTime: "14:00",
                endTime: "15:30",
                offeredServiceIds: ["svc-pedicure"],
                bookedServiceId: "svc-pedicure",
                status: .pending,
                clientId: "client-2"
            ),
            clientName: "Марія Гриб",
            serviceName: "Педикюр",
            action: {}
        )
    }
    .padding()
    .background(Color.background)
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `ScheduleBlockCard.swift`. Expected: two cards stacked, the
first with a bright orange... actually green "Підтверджено" pill (confirmed = green
`#008C0E`), the second with an orange "Очікує" pill (pending = `#CC6E00`), each showing
a client name and service name.

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleBlockCard.swift
git commit -m "Add ScheduleBlockCard component"
```

---

### Task 8: Build `ScheduleBlockDetailSheet`

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleBlockDetailSheet.swift`

**Interfaces:**
- Consumes: `Block`, `ScheduleMetrics`-adjacent colors (`Color.statusPending`/`Color.statusConfirmed`/`Color.ink`/`Color.textSecondary`).
- Produces: `struct ScheduleBlockDetailSheet: View { init(block: Block, clientName: String, serviceName: String) }`
  — consumed by `ScheduleView` in Task 12.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct ScheduleBlockDetailSheet: View {
    let block: Block
    let clientName: String
    let serviceName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(clientName)
                .font(.elmsSans(.bold, 22))
                .foregroundStyle(Color.ink)

            Label(timeRangeText, systemImage: "clock")
                .font(.elmsSans(.regular, 15))
                .foregroundStyle(Color.textSecondary)

            Label(serviceName, systemImage: "sparkles")
                .font(.elmsSans(.regular, 15))
                .foregroundStyle(Color.textSecondary)

            Text(statusTextKey)
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor, in: .capsule)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .presentationDetents([.fraction(0.35)])
    }

    private var timeRangeText: String {
        "\(block.startTime)–\(block.endTime)"
    }

    private var statusColor: Color {
        block.status == .confirmed ? Color.statusConfirmed : Color.statusPending
    }

    private var statusTextKey: LocalizedStringKey {
        block.status == .confirmed ? "schedule.status.confirmed" : "schedule.status.pending"
    }
}

#Preview {
    Color.background
        .sheet(isPresented: .constant(true)) {
            ScheduleBlockDetailSheet(
                block: Block(
                    id: "preview",
                    date: "2026-07-24",
                    startTime: "10:00",
                    endTime: "11:30",
                    offeredServiceIds: ["svc-manicure"],
                    bookedServiceId: "svc-manicure",
                    status: .confirmed,
                    clientId: "client-1"
                ),
                clientName: "Оксана Коваль",
                serviceName: "Манікюр"
            )
        }
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `ScheduleBlockDetailSheet.swift`. Expected: a sheet slides up
from the bottom showing the client name, a clock icon with "10:00–11:30", a sparkles
icon with "Манікюр", and a green "Підтверджено" pill.

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleBlockDetailSheet.swift
git commit -m "Add ScheduleBlockDetailSheet component"
```

---

### Task 9: Build `ScheduleEmptySlot`

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleEmptySlot.swift`

**Interfaces:**
- Consumes: `ScheduleMetrics` (Task 4), `Color.textSecondary`/`Color.surface`
  (existing assets), the `schedule.slot.addFreeTime` key (Task 3).
- Produces: `struct ScheduleEmptySlot: View` (no parameters) — consumed by
  `HourlyTimelineView` in Task 10. Purely decorative per the "Календар майстра" mockup's
  `.addslot` element — matches the design spec's view-only scope, so it carries no tap
  action.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct ScheduleEmptySlot: View {
    var body: some View {
        Text("schedule.slot.addFreeTime")
            .font(.elmsSans(.semiBold, 12.5))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(ScheduleMetrics.Spacing.cardVerticalPadding + 1)
            .overlay(
                RoundedRectangle(cornerRadius: ScheduleMetrics.CornerRadius.card)
                    .strokeBorder(
                        Color.surface,
                        style: StrokeStyle(lineWidth: ScheduleMetrics.Size.dashedBorderWidth, dash: [5, 4])
                    )
            )
    }
}

#Preview {
    ScheduleEmptySlot()
        .padding()
        .background(Color.background)
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `ScheduleEmptySlot.swift`. Expected: a pill-shaped dashed
outline with centered text "+ Додати вільний час" in muted gray, no fill.

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleEmptySlot.swift
git commit -m "Add ScheduleEmptySlot component"
```

---

### Task 10: Build `HourlyTimelineView`

**Files:**
- Create: `Manik/Manik/Master/Schedule/HourlyTimelineView.swift`

**Interfaces:**
- Consumes: `Block`, `ScheduleMetrics`, `ScheduleBlockCard` (Task 7),
  `ScheduleEmptySlot` (Task 9).
- Produces:
  ```swift
  struct HourlyTimelineView: View {
      init(
          blocks: [Block],
          clientName: @escaping (Block) -> String,
          serviceName: @escaping (Block) -> String,
          onSelect: @escaping (Block) -> Void
      )
  }
  ```
  consumed by `ScheduleView` in Task 12.

**Empty-slot rule (per user decision):** for each full working hour, if no
`pending`/`confirmed` block overlaps that hour's `[hourStart, hourStart+60)` minute
range at all, render a `ScheduleEmptySlot` for that whole hour. If a block overlaps the
hour even partially, skip the placeholder for that hour entirely — the block's own
proportional card already covers it, and any leftover fragment of the hour not covered
by the block (e.g. the last 30 minutes after an 08:00–09:30 block, before the next full
free hour at 10:00–11:00) is left blank, with no placeholder and no card.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct HourlyTimelineView: View {
    let blocks: [Block]
    let clientName: (Block) -> String
    let serviceName: (Block) -> String
    let onSelect: (Block) -> Void

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                hourGrid

                ForEach(Array(ScheduleMetrics.workingHours), id: \.self) { hour in
                    if isHourFree(hour) {
                        ScheduleEmptySlot()
                            .padding(.leading, cardLeadingPadding)
                            .padding(.trailing, ScheduleMetrics.Spacing.timelineHorizontalPadding)
                            .frame(height: ScheduleMetrics.Size.hourHeight, alignment: .top)
                            .offset(y: hourOffset(hour))
                    }
                }

                ForEach(visibleBlocks) { block in
                    ScheduleBlockCard(
                        block: block,
                        clientName: clientName(block),
                        serviceName: serviceName(block),
                        action: { onSelect(block) }
                    )
                    .padding(.leading, cardLeadingPadding)
                    .padding(.trailing, ScheduleMetrics.Spacing.timelineHorizontalPadding)
                    .frame(height: height(for: block), alignment: .top)
                    .offset(y: offset(for: block))
                }
            }
        }
    }

    private var visibleBlocks: [Block] {
        blocks.filter { $0.status != .available }
    }

    private var cardLeadingPadding: CGFloat {
        ScheduleMetrics.Spacing.timelineHorizontalPadding
            + ScheduleMetrics.Size.hourLabelWidth
            + ScheduleMetrics.Spacing.daySpacing
    }

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(Array(ScheduleMetrics.workingHours), id: \.self) { hour in
                HStack(alignment: .top, spacing: ScheduleMetrics.Spacing.daySpacing) {
                    Text(String(format: "%02d:00", hour))
                        .font(.elmsSans(.regular, 12))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: ScheduleMetrics.Size.hourLabelWidth, alignment: .leading)

                    Rectangle()
                        .fill(Color.surface)
                        .frame(height: 1)
                }
                .frame(height: ScheduleMetrics.Size.hourHeight, alignment: .top)
            }
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
    }

    private func minutes(from timeString: String) -> Int {
        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }

    private func isHourFree(_ hour: Int) -> Bool {
        let hourStart = hour * 60
        let hourEnd = hourStart + 60
        return !visibleBlocks.contains { block in
            let blockStart = minutes(from: block.startTime)
            let blockEnd = minutes(from: block.endTime)
            return blockStart < hourEnd && blockEnd > hourStart
        }
    }

    private func hourOffset(_ hour: Int) -> CGFloat {
        CGFloat(hour - ScheduleMetrics.workingHours.lowerBound) * ScheduleMetrics.Size.hourHeight
    }

    private func offset(for block: Block) -> CGFloat {
        let workStartMinutes = ScheduleMetrics.workingHours.lowerBound * 60
        let startMinutes = minutes(from: block.startTime)
        return CGFloat(startMinutes - workStartMinutes) / 60 * ScheduleMetrics.Size.hourHeight
    }

    private func height(for block: Block) -> CGFloat {
        let startMinutes = minutes(from: block.startTime)
        let endMinutes = minutes(from: block.endTime)
        return CGFloat(endMinutes - startMinutes) / 60 * ScheduleMetrics.Size.hourHeight
    }
}

#if DEBUG
#Preview {
    HourlyTimelineView(
        blocks: SchedulePreviewData.blocks,
        clientName: { block in
            SchedulePreviewData.profiles[block.clientId ?? ""]?.name ?? "—"
        },
        serviceName: { block in
            SchedulePreviewData.services.first { $0.id == block.bookedServiceId }?.name ?? "—"
        },
        onSelect: { _ in }
    )
    .background(Color.background)
}
#endif
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `HourlyTimelineView.swift`. Expected: hour labels `08:00`
through `21:00` down the left side with a divider line per hour; a dashed
"+ Додати вільний час" placeholder filling every hour row that the sample blocks don't
touch (08:00–10:00, 11:00–12:00, 13:00–14:00, 16:00–21:00); a green "confirmed" card
spanning roughly 1.5 hour-rows starting at the 10:00 line with no placeholder drawn for
10:00 or 11:00; an orange "pending" card spanning roughly 1.5 hour-rows starting at the
14:00 line with no placeholder for 14:00 or 15:00; the `available` sample block
(12:00–13:00) renders neither a card nor suppresses the 12:00 placeholder (it's not in
`visibleBlocks`, so 12:00 still shows the dashed placeholder).

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/HourlyTimelineView.swift
git commit -m "Add HourlyTimelineView component with empty-slot placeholders"
```

---

### Task 11: Build `ScheduleViewModel`

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleViewModel.swift`

**Interfaces:**
- Consumes: `BlockRepository`/`FirestoreBlockRepository`,
  `ServiceRepository`/`FirestoreServiceRepository`, `UserRepository`/`FirestoreUserRepository`
  (Task 2), `DateFormat.date` (Task 1).
- Produces:
  ```swift
  @MainActor @Observable final class ScheduleViewModel {
      var selectedDate: Date
      var blocks: [Block]
      var services: [Service]
      var selectedBlock: Block?
      var hasLoadedBlocks: Bool
      var hasLoadedServices: Bool
      var isLoading: Bool { get }
      init(
          blockRepository: BlockRepository = FirestoreBlockRepository(),
          serviceRepository: ServiceRepository = FirestoreServiceRepository(),
          userRepository: UserRepository = FirestoreUserRepository()
      )
      var blocksForSelectedDate: [Block] { get }
      func observeBlocks() async
      func observeServices() async
      func clientName(for block: Block) -> String
      func serviceName(for block: Block) -> String
  }
  ```
  consumed by `ScheduleView` in Task 12. `isLoading` is `true` until both the first
  blocks snapshot and the first services snapshot have arrived — `ScheduleView` shows a
  full-screen spinner while it's `true`, per the design spec's "Перший лоад" requirement.

- [ ] **Step 1: Create the file**

```swift
import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    var selectedDate = Date()
    var blocks: [Block] = []
    var services: [Service] = []
    var selectedBlock: Block?
    var hasLoadedBlocks = false
    var hasLoadedServices = false

    var isLoading: Bool {
        !hasLoadedBlocks || !hasLoadedServices
    }

    private var profileCache: [String: UserProfile] = [:]
    private var requestedProfileUIDs: Set<String> = []

    private let blockRepository: BlockRepository
    private let serviceRepository: ServiceRepository
    private let userRepository: UserRepository

    init(
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository(),
        userRepository: UserRepository = FirestoreUserRepository()
    ) {
        self.blockRepository = blockRepository
        self.serviceRepository = serviceRepository
        self.userRepository = userRepository
    }

    var blocksForSelectedDate: [Block] {
        let dateString = DateFormat.date.string(from: selectedDate)
        return blocks.filter { $0.date == dateString }
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
            hasLoadedBlocks = true
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices
            hasLoadedServices = true
        }
    }

    func clientName(for block: Block) -> String {
        guard let clientId = block.clientId else { return "" }

        if let profile = profileCache[clientId] {
            return profile.name
        }

        if !requestedProfileUIDs.contains(clientId) {
            requestedProfileUIDs.insert(clientId)
            loadProfile(uid: clientId)
        }

        return String(localized: "schedule.client.loading")
    }

    func serviceName(for block: Block) -> String {
        guard let bookedServiceId = block.bookedServiceId else { return "" }
        return services.first { $0.id == bookedServiceId }?.name
            ?? String(localized: "schedule.service.unknown")
    }

    private func loadProfile(uid: String) {
        Task {
            do {
                profileCache[uid] = try await userRepository.fetchProfile(uid: uid)
            } catch {
                profileCache[uid] = UserProfile(
                    uid: uid,
                    role: .client,
                    name: String(localized: "schedule.client.fallback"),
                    email: ""
                )
            }
        }
    }
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleViewModel.swift
git commit -m "Add ScheduleViewModel"
```

---

### Task 12: Build `ScheduleView` (composition root)

**Files:**
- Create: `Manik/Manik/Master/Schedule/ScheduleView.swift`

**Interfaces:**
- Consumes: `ScheduleViewModel` (Task 11), `WeekDayStrip` (Task 6),
  `HourlyTimelineView` (Task 10), `ScheduleBlockDetailSheet` (Task 8),
  `FakeBlockRepository`/`FakeServiceRepository`/`FakeUserRepository`/`SchedulePreviewData`
  (Task 5, `#Preview` only).
- Produces: `struct ScheduleView: View { init(viewModel: ScheduleViewModel = ScheduleViewModel()) }`
  — consumed by `MasterRootView` in Task 13.

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel

    init(viewModel: ScheduleViewModel = ScheduleViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack(spacing: 0) {
                    WeekDayStrip(selectedDate: $viewModel.selectedDate)
                        .padding(.vertical, 12)

                    HourlyTimelineView(
                        blocks: viewModel.blocksForSelectedDate,
                        clientName: viewModel.clientName(for:),
                        serviceName: viewModel.serviceName(for:),
                        onSelect: { viewModel.selectedBlock = $0 }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .sheet(item: $viewModel.selectedBlock) { block in
            ScheduleBlockDetailSheet(
                block: block,
                clientName: viewModel.clientName(for: block),
                serviceName: viewModel.serviceName(for: block)
            )
        }
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.observeServices()
        }
    }
}

#if DEBUG
#Preview {
    ScheduleView(
        viewModel: ScheduleViewModel(
            blockRepository: FakeBlockRepository(blocks: SchedulePreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: SchedulePreviewData.services),
            userRepository: FakeUserRepository(profiles: SchedulePreviewData.profiles)
        )
    )
}
#endif
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Manually verify the preview**

Open the `#Preview` for `ScheduleView.swift`. Expected: a brief spinner, then the day
strip on top (today selected), timeline below with the two sample cards positioned
under 10:00 and 14:00;
tapping a card slides up its detail sheet with matching name/time/service/status;
swiping the day strip to a different day empties the timeline (sample data only has
blocks for "today").

- [ ] **Step 4: Commit**

```bash
git add Manik/Manik/Master/Schedule/ScheduleView.swift
git commit -m "Add ScheduleView composition root"
```

---

### Task 13: Wire `ScheduleView` into `MasterRootView`

**Files:**
- Modify: `Manik/Manik/Master/MasterRootView.swift:9-34`

**Interfaces:**
- Consumes: `ScheduleView` (Task 12), `MasterTab` (existing enum with
  `.schedule`/`.requests`/`.stats` cases), `CustomTabBar`/`CabinetKind.master` (existing).

- [ ] **Step 1: Replace the body to route `.schedule` to `ScheduleView`**

Mirror the existing `switch selectedTab` pattern already used in `ClientRootView.swift`.
Replace `MasterRootView.swift`'s full contents with:

```swift
import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: MasterTab = .schedule

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .schedule:
                    ScheduleView()
                case .requests, .stats:
                    placeholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)

            CustomTabBar(kind: .master(selection: $selectedTab, badge: { _ in nil }))
        }
    }

    private var placeholder: some View {
        VStack(spacing: 16) {
            Text("master.placeholder.title")
                .font(.elmsSans(.bold, 24))
                .foregroundStyle(Color.ink)

            Text(selectedTab.titleKey)
                .font(.elmsSans(.medium, 16))
                .foregroundStyle(Color.textSecondary)

            Text(profile.name)
                .font(.elmsSans(.regular, 16))
                .foregroundStyle(Color.textSecondary)

            Button(action: onSignOut) {
                Text("common.action.signOut")
                    .font(.elmsSans(.bold, 14.5))
            }
        }
    }
}

#Preview {
    MasterRootView(
        profile: UserProfile(uid: "preview", role: .master, name: "Марина", email: "master@example.com"),
        onSignOut: {}
    )
}
```

- [ ] **Step 2: Build**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add Manik/Manik/Master/MasterRootView.swift
git commit -m "Wire ScheduleView into the master's Schedule tab"
```

---

### Task 14: Full-app verification and plan/docs cleanup

**Files:**
- Modify: `docs/plan.md` (check off the completed "Master — Розклад" step)

**Interfaces:** none (documentation/verification only).

- [ ] **Step 1: Run the full build gate one more time**

Run: `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`
Expected: `BUILD SUCCEEDED`

- [ ] **Step 2: Manually smoke-test in the Simulator**

Run the app in the iOS Simulator, sign in as the master account, confirm the "Розклад"
tab shows the day strip + timeline (this will hit real Firestore data — verify against
whatever blocks currently exist for the master account, or create one manually via the
Firebase Console to confirm a card renders end-to-end with a real client name).

- [ ] **Step 3: Update `docs/plan.md`**

In the "Next steps (in order)" list, check off the "Master — Розклад (Schedule)" item
(replace `2. **Master — "Розклад" (Schedule)** screen ...` with the same text prefixed
by `[x]` under a "Done" bullet, matching the existing style already used for PR1/PR2/PR3
entries in that file's "## Done" section) and move the "Master — Заявки" item to be
next up.

- [ ] **Step 4: Commit**

```bash
git add docs/plan.md
git commit -m "Mark Master Schedule screen done in docs/plan.md"
```

---

## In the stash (built, set aside for reuse — NOT in this PR)

The tasks below (roughly Tasks 2, 5, 7, 8, 10, 11, 12 as they touch blocks) were fully
built, then stashed via `git stash` for Slices 2–3 rather than shipped. When popping the
stash, mind these decisions that were baked into that code:

- **`Block.startMinutes`/`Block.endMinutes`** — `"HH:mm"` → minutes parsing lives on the
  `Block` model as two computed properties (removed 4× duplication vs a private
  `minutes(from:)` in the view). Reverted out of this PR; re-add on reuse. Geometry math
  (offset/height in points) stays in the view — it depends on `ScheduleMetrics`.
- **`ScheduleView.init` (stashed block version) has no default `viewModel` value** —
  a default value that constructs a `@MainActor`-isolated `ScheduleViewModel` from the
  non-isolated `init` fails to compile; call sites pass `ScheduleViewModel()` explicitly
  from their `@MainActor` context. (This PR's shipped `ScheduleView` has no view model at
  all — it uses `@State private var selectedDate`.)
- **`ScheduleBlockCard` (stashed)** — fills its allotted timeline height
  (`.frame(maxHeight: .infinity, alignment: .topLeading)`), solid status-colored border
  (`ScheduleMetrics.Size.cardBorderWidth`, reverted out of this PR), and shows
  `"<service> · <start>–<end>"`.
- **Cleanup TODO on reuse:** `Text("\(serviceName) · \(timeRange)")` made Xcode
  auto-extract a `"%@ · %@"` key into `Localizable.xcstrings`. Rework to an `HStack` of two
  `Text`s or a proper `schedule.card.serviceTime` format key so the catalog isn't polluted
  by an auto-extracted positional key.
- **`ScheduleMetrics` was trimmed after stashing** — the shipped `ScheduleMetrics` no longer
  has `Size.hourHeight`/`dayCellSize`/`cardBorderWidth`/`dashedBorderWidth`,
  `Spacing.daySpacing`/`cardHorizontalPadding`/`cardVerticalPadding`, `CornerRadius`, or
  `AnimationStyle`. The stashed block-integrated `HourlyTimelineView` (proportional cards via
  `offset`/`height` on `hourHeight`) references several of these, so restore the constants it
  needs when popping the stash. Also re-add the `schedule.status.*`/`schedule.client.*`/
  `schedule.service.*` catalog keys the stashed card/detail/VM use.

---

## Follow-up slices (each a separate small, functional PR)

Per "small vertical slices over horizontal layers": do **not** fold these back into this
PR. Each gets its own short plan when started, and each must ship a working write path
(repository call + error handling + live refresh via the existing `observe*` streams),
not another inert UI shell.

- **Slice 2 — Create free-time slot.** Give the `DashedSlot` "+ Додати вільний час" a real
  action (it already takes an `action` closure, currently empty): pick start/end + offered
  services → `addBlock(...)` → new `available` slot appears via `observeBlocks()`. Needs a
  small slot-composer UI and `DateFormat`-formatted `date`/`startTime`/`endTime`.
- **Slice 3 — Manage a request.** From a `pending` block's detail sheet, add
  "Підтвердити"/"Відхилити" → `confirm(blockId:)`/`decline(blockId:)` → status updates
  live. Extends `ScheduleBlockDetailSheet` (currently read-only) with actions.
- **Slice 4 (optional) — Cancel a confirmed block.** `cancel(blockId:)` from the detail
  sheet, returning the slot to `available`.

Each slice above is intentionally sized to one working capability the master can actually
perform end-to-end.
