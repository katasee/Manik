# PR10 — Master "Мої послуги" (read-only list) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The master can open a "Мої послуги" screen from the Статистика tab and read their price list — service name, duration and price — sourced live from Firestore.

**Architecture:** A new `Master/Services/` feature folder holding `MyServicesView` + `MyServicesViewModel` (MVVM, `@Observable`, repository injected through the initializer), a `ServiceRow` subview, and a feature-local `ServicesMetrics`. Display formatting for price and duration goes into `Utilities/ServiceFormat.swift` alongside the existing `DateFormat`, because both are cross-cutting display concerns rather than layout. The screen is reached through the app's **first** `NavigationStack`, introduced locally inside the `.stats` branch of `MasterRootView` so the Розклад tab is unaffected.

**Tech Stack:** SwiftUI (iOS 17.2 deployment target), Swift Observation (`@Observable`), Firebase Firestore via the existing `ServiceRepository` protocol, String Catalog (`Localizable.xcstrings`) for all user-facing text.

## Status: implemented — where the shipped code differs from this plan

All three tasks are done on `feature/pr-10-myServices`. A design pass and a `swiftui-pro` review
after the first cut moved several things; the code is the source of truth, this list exists so a
reader of the plan isn't misled. **Delete this whole file once PR10 is merged**, per `CLAUDE.md`.

- **Entry point.** Task 3's `statsPlaceholder` inside `MasterRootView` was rejected — it put feature
  UI back into the router. The `.stats` branch now renders a real `Master/Stats/StatsView.swift`,
  which owns the `NavigationStack` and the temporary link.
- **Screen title.** The `ToolbarItem(.principal)` approach was dropped for a custom header drawn
  under `.toolbar(.hidden, for: .navigationBar)`: a `chevron.left` `Button` over a `ZStack`-centered
  title. Reason: the system back chevron was unwanted, and once the bar is hidden the title has to
  come with it.
- **Empty state.** The hand-rolled `VStack` became `ContentUnavailableView`, and a `ProgressView`
  was added for `hasLoaded == false`. `ServicesMetrics.Spacing.emptyStateSpacing` is gone.
- **Row + chrome redesign** (not in this plan at all): circled star icon, subtitle line, uppercase
  section header with a count, black circular "+" button, `rowCornerRadius` 18 → 24. The star is
  decorative — `Service` has no field to drive filled-vs-outline. The "+" button's action is an
  empty stub until PR11, and the mockup's per-row "Змінити" link was left out entirely (PR12).
- **Localization.** Seven `services.*` keys, not four — `services.subtitle`,
  `services.section.all`, `services.action.add` were added by the redesign, plus
  `common.action.back` for the header button.
- **Initializer.** `MyServicesView(viewModel:)` is required. The `viewModel: X? = nil` pattern this
  plan copied from `ScheduleView` silently binds the View to `FirestoreServiceRepository()`.
- **Review outcome.** One `swiftui-pro` finding applied (`.contentShape(.circle)` on the "+"
  button — `.frame`/`.background` outside a `Button` don't extend its hit area). Accessibility
  grouping and extracting the header/intro into `View` structs were both declined.

## Global Constraints

Every task's requirements implicitly include this section.

- **Branch:** `feature/pr-10-myServices`.
- **The data layer is already complete — do not touch it.** `Models/Service.swift`, `ServiceRepository` (all four methods), `FirestoreServiceRepository` (all four implemented), and `firestore.rules:52-55` (`allow write: if isMaster()`) already exist and are correct. This PR is pure UI. No repository, model, or rules changes.
- **Scope boundary:** read-only. No add, no edit, no delete, no swipe actions, no `+` button. Those are PR11 and PR12. Do not remove the `#if DEBUG` fake-services override in `ScheduleView.swift:14` — that belongs to PR11, which is the first slice that can seed real data.
- **No test target exists** in this project (no linter or formatter either). Do not add XCTest, do not add a test target — that is a separate decision, not part of this PR. Verification for every task is: (a) the SwiftUI `#Preview` renders correctly in the Xcode canvas, and (b) a clean build. Each task states exactly what to look at.
- **Build command:** `cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build`. **Ask the user before running it** — this project's standing instruction is that builds are never run unprompted.
- **Commits are the user's** — make the edits and leave them uncommitted. Do not `git commit` or `git push`.
- **No code comments.** No inline comments, no doc comments. The code must read as self-documenting.
- **Fonts:** only `Font.elmsSans(_:_:)` with a weight from `ElmsSansWeight` (`regular`/`medium`/`semiBold`/`bold`). Never `.font(.system(...))`, `.font(.title)`, `.bold()`, or `.fontWeight()`.
- **Colors:** only asset-catalog tokens already present — `Color.background`, `.ink`, `.textSecondary`, `.surface`, `.fieldBackground`, `.destructive`. Do not add a new colorset.
- **Strings:** no bare user-facing literals in a View. Every string goes into `Manik/Manik/Localizable/Localizable.xcstrings` under a `feature.kind.name` key, added in the same task that introduces it, with **both** `en` and `uk` values. Source language is `uk`. Keys are stored alphabetically; the new `services.*` keys sort after `schedule.title` (the last `schedule.*` key) and before `tabBar.tab.account` (the first `tabBar.*` key).
- **Formatting:** any call or declaration with 3+ arguments gets one argument per line. Under 3, keep it on one line.
- **Currency is `PLN`.** Inferred from `DateFormat.salonTimeZone == "Europe/Warsaw"`. If the salon actually charges UAH, this is a one-word change in `ServiceFormat.currencyCode` — flag it to the user rather than guessing a second time.

---

## File Structure

**Create:**

| File | Responsibility |
|---|---|
| `Manik/Manik/Utilities/ServiceFormat.swift` | Display formatting for `Service.price` and `Service.durationMinutes`. Sits next to `DateFormat.swift` because it is the same kind of cross-cutting display concern. |
| `Manik/Manik/Master/Services/ServicesMetrics.swift` | Layout numbers for the feature only. No domain values. |
| `Manik/Manik/Master/Services/ServiceRow.swift` | One row: name + duration on the left, price on the right, on a `fieldBackground` card. |
| `Manik/Manik/Master/Services/MyServicesViewModel.swift` | Observes `ServiceRepository`, exposes a sorted `services` array and a `hasLoaded` flag. |
| `Manik/Manik/Master/Services/MyServicesView.swift` | The screen: scrolling list, empty state, navigation title. |
| `Manik/Manik/Master/Services/Preview/ServicesPreviewData.swift` | `#if DEBUG` fixtures for this feature's previews. |

**Modify:**

| File | Change |
|---|---|
| `Manik/Manik/Master/Stats/StatsView.swift` | **Create.** Owns the `.stats` tab, the app's first `NavigationStack`, and the temporary `NavigationLink` to `MyServicesView`. |
| `Manik/Manik/Master/MasterRootView.swift:16` | Point the `.stats` branch at `StatsView()`. Nothing else — the router stays free of feature UI. |
| `Manik/Manik/Localizable/Localizable.xcstrings` | New `services.*` keys plus `common.action.back` (en + uk). |

**Note on `ServicesPreviewData`:** this duplicates the four `Service` literals already in `Master/Schedule/Preview/SchedulePreviewData.swift`. That is deliberate — a feature folder must not import another feature's types, and the Schedule fixtures exist to be referenced by `Block.offeredServiceIds`, which this feature does not care about. The alternative (hoisting shared `Service` fixtures into `Services/Fakes/`) would drag a Schedule-file edit into this PR for four literals; not worth it.

**Note on the fake repository:** `FakeServiceRepository` is currently a `struct` whose `observeServices()` yields once and finishes, and whose `add`/`update`/`delete` are no-ops. That is **sufficient for this PR**, which only reads. Rewriting it as a mutable in-memory class belongs to PR11, where a preview must reflect a newly added service. Do not rewrite it here.

---

## Task 1: Row rendering + display formatting

Deliverable: a service row renders in the Xcode canvas showing "Класичний манікюр / 1 год / 500,00 zł".

**Files:**
- Create: `Manik/Manik/Utilities/ServiceFormat.swift`
- Create: `Manik/Manik/Master/Services/ServicesMetrics.swift`
- Create: `Manik/Manik/Master/Services/Preview/ServicesPreviewData.swift`
- Create: `Manik/Manik/Master/Services/ServiceRow.swift`

**Interfaces:**
- Consumes: `Service` (`Manik/Manik/Models/Service.swift` — `id: String?`, `name: String`, `durationMinutes: Int`, `price: Double`).
- Produces:
  - `ServiceFormat.price(_ value: Double) -> String`
  - `ServiceFormat.duration(minutes: Int) -> String`
  - `ServicesMetrics.Size.rowCornerRadius`, `ServicesMetrics.Spacing.*` (see code below for the full list)
  - `ServicesPreviewData.services: [Service]`
  - `ServiceRow(service: Service)`

- [ ] **Step 1: Create `Manik/Manik/Utilities/ServiceFormat.swift`**

`Duration.UnitsFormatStyle` is iOS 16+, so it is available on the 17.2 target. It localizes the unit names itself, which is why we are not hand-rolling "год"/"хв" strings into the catalog.

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

    static func duration(minutes: Int) -> String {
        Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
```

- [ ] **Step 2: Create `Manik/Manik/Master/Services/ServicesMetrics.swift`**

Layout numbers only — this file must never gain a domain value (durations, prices, working hours). Those belong in `Models/`.

```swift
import CoreGraphics

enum ServicesMetrics {
    enum Size {
        static let rowCornerRadius: CGFloat = 18
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let listTopPadding: CGFloat = 12
        static let rowSpacing: CGFloat = 12
        static let rowTextSpacing: CGFloat = 4
        static let rowContentSpacing: CGFloat = 12
        static let rowHorizontalPadding: CGFloat = 16
        static let rowVerticalPadding: CGFloat = 14
        static let emptyStateSpacing: CGFloat = 8
    }
}
```

- [ ] **Step 3: Create `Manik/Manik/Master/Services/Preview/ServicesPreviewData.swift`**

```swift
#if DEBUG
enum ServicesPreviewData {
    static let services: [Service] = [
        Service(id: "svc-hybrid", name: "Манікюр гібридний (гель-лак)", durationMinutes: 90, price: 800),
        Service(id: "svc-classic", name: "Класичний манікюр", durationMinutes: 60, price: 500),
        Service(id: "svc-gel-correction", name: "Корекція гелем", durationMinutes: 90, price: 900),
        Service(id: "svc-french", name: "Френч", durationMinutes: 30, price: 200)
    ]
}
#endif
```

- [ ] **Step 4: Create `Manik/Manik/Master/Services/ServiceRow.swift`**

`.firstTextBaseline` alignment keeps the price glyphs sitting on the same line as the service name even when the name wraps to two lines.

```swift
import SwiftUI

struct ServiceRow: View {
    let service: Service

    var body: some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: ServicesMetrics.Spacing.rowContentSpacing
        ) {
            VStack(alignment: .leading, spacing: ServicesMetrics.Spacing.rowTextSpacing) {
                Text(service.name)
                    .font(.elmsSans(.semiBold, 16))
                    .foregroundStyle(Color.ink)
                    .lineLimit(2)

                Text(ServiceFormat.duration(minutes: service.durationMinutes))
                    .font(.elmsSans(.regular, 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Text(ServiceFormat.price(service.price))
                .font(.elmsSans(.bold, 16))
                .foregroundStyle(Color.ink)
                .layoutPriority(1)
        }
        .padding(.horizontal, ServicesMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ServicesMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.fieldBackground,
            in: .rect(cornerRadius: ServicesMetrics.Size.rowCornerRadius)
        )
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
        ForEach(ServicesPreviewData.services) { service in
            ServiceRow(service: service)
        }
    }
    .padding()
    .background(Color.background)
}
#endif
```

- [ ] **Step 5: Verify in the Xcode canvas**

Open `ServiceRow.swift` and resume the preview. Expected, top to bottom:
- Four rows on rounded `fieldBackground` cards against a `background`-colored page.
- Row 1 name wraps to two lines; its price stays on the first line, right-aligned, and is **not** truncated.
- Durations read `1 год 30 хв`, `1 год`, `1 год 30 хв`, `30 хв` on a Ukrainian device; `1 hr 30 min`, `1 hr`, `1 hr 30 min`, `30 min` on an English one.
- Prices read `800,00 zł` style (Polish złoty), not `$800.00` and not a bare `800`.

If durations come out as `5400 s` or similar, the `allowed:` set was dropped from the `.units` call.

---

## Task 2: The screen — list, empty state, view model

Deliverable: the full `MyServicesView` renders in the canvas, in both the populated and the empty state, driven by an injected fake repository.

**Files:**
- Create: `Manik/Manik/Master/Services/MyServicesViewModel.swift`
- Create: `Manik/Manik/Master/Services/MyServicesView.swift`
- Modify: `Manik/Manik/Localizable/Localizable.xcstrings`

**Interfaces:**
- Consumes: `ServiceRow(service:)`, `ServicesMetrics.*`, `ServicesPreviewData.services` (Task 1); `ServiceRepository.observeServices() -> AsyncStream<[Service]>`; `FirestoreServiceRepository()`; `FakeServiceRepository(services: [Service])`.
- Produces:
  - `MyServicesViewModel(serviceRepository:)` with `services: [Service]`, `hasLoaded: Bool`, `func observeServices() async`
  - `MyServicesView(viewModel:)` — the `viewModel` parameter is optional and defaults to `nil`, matching the `ScheduleView` pattern so previews can inject a fake.

- [ ] **Step 1: Add the four localization keys**

Open `Manik/Manik/Localizable/Localizable.xcstrings` and insert these four entries inside the top-level `"strings"` object, alphabetically — after the `"schedule.title"` entry and before `"tabBar.tab.account"`.

```json
    "services.action.open" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "My Services"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Мої послуги"
          }
        }
      }
    },
    "services.empty.message" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Your price list will appear here once you add it."
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Ваш прайс з'явиться тут, щойно ви його додасте."
          }
        }
      }
    },
    "services.empty.title" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "No services yet"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Поки що немає послуг"
          }
        }
      }
    },
    "services.title" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "My Services"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Мої послуги"
          }
        }
      }
    },
```

`services.title` and `services.action.open` deliberately carry identical copy — one is a screen title, the other a button label, and PR11/PR12 may well change one without the other. Do not collapse them into a single key.

Validate the file is still valid JSON before moving on:

```bash
python3 -m json.tool Manik/Manik/Localizable/Localizable.xcstrings > /dev/null && echo "valid"
```

Expected: `valid`.

- [ ] **Step 2: Create `Manik/Manik/Master/Services/MyServicesViewModel.swift`**

`hasLoaded` exists so the empty state is not flashed during the moment before the first Firestore snapshot arrives — without it, opening the screen on a slow network shows "Поки що немає послуг" and then the list, which reads as a bug. Sorting uses `localizedStandardCompare` so Cyrillic names order correctly and digits sort naturally.

```swift
import Foundation
import Observation

@MainActor
@Observable
final class MyServicesViewModel {
    private(set) var services: [Service] = []
    private(set) var hasLoaded = false

    private let serviceRepository: ServiceRepository

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices.sorted(by: Self.byName)
            hasLoaded = true
        }
    }

    private static func byName(_ lhs: Service, _ rhs: Service) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
```

- [ ] **Step 3: Create `Manik/Manik/Master/Services/MyServicesView.swift`**

The title goes through a `.principal` toolbar item rather than `.navigationTitle` because `navigationTitle` renders in the system font, which this project forbids. `.navigationBarTitleDisplayMode(.inline)` keeps it a compact bar so the custom font sits where a system inline title would.

```swift
import SwiftUI

struct MyServicesView: View {
    @State private var viewModel: MyServicesViewModel

    init(viewModel: MyServicesViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? MyServicesViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
                ForEach(viewModel.services) { service in
                    ServiceRow(service: service)
                }
            }
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.listTopPadding)
        }
        .overlay { emptyState }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("services.title")
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)
            }
        }
        .task {
            await viewModel.observeServices()
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.hasLoaded, viewModel.services.isEmpty {
            VStack(spacing: ServicesMetrics.Spacing.emptyStateSpacing) {
                Text("services.empty.title")
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)

                Text("services.empty.message")
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
        }
    }
}

#if DEBUG
#Preview("З послугами") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(
                serviceRepository: FakeServiceRepository(services: ServicesPreviewData.services)
            )
        )
    }
}

#Preview("Порожній список") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(serviceRepository: FakeServiceRepository(services: []))
        )
    }
}
#endif
```

- [ ] **Step 4: Verify both previews in the Xcode canvas**

Open `MyServicesView.swift` and check each preview by name:
- **"З послугами"** — four rows, sorted alphabetically by Ukrainian name (`Класичний манікюр`, `Корекція гелем`, `Манікюр гібридний (гель-лак)`, `Френч`), a compact top bar reading "Мої послуги" in ElmsSans Bold, no empty-state text anywhere.
- **"Порожній список"** — no rows, centered "Поки що немає послуг" with the grey message underneath, same top bar.

If both previews show the empty state, `hasLoaded` is being set but `services` is not — check that `FakeServiceRepository` yields before it finishes. If neither shows it, `hasLoaded` never became `true`, meaning the `for await` loop never ran; confirm `.task` is attached to the `ScrollView` chain and not inside the `overlay`.

---

## Task 3: Navigation and the temporary entry point

Deliverable: launch the app as the master, tap the Статистика tab, tap "Мої послуги", land on the screen, and swipe/tap back.

**Files:**
- Modify: `Manik/Manik/Master/MasterRootView.swift`

**Interfaces:**
- Consumes: `MyServicesView()` (Task 2, no-argument initializer — uses the real `FirestoreServiceRepository`), `services.action.open` (Task 2).
- Produces: nothing consumed by later tasks in this PR. PR "Статистика" (plan step 5) will delete `myServicesLink` and `statsPlaceholder` and put the same `NavigationLink` on the real stats screen.

- [ ] **Step 1: Split the `.stats` branch out of the shared placeholder**

In `Manik/Manik/Master/MasterRootView.swift`, replace the combined case:

```swift
                case .requests, .stats:
                    placeholder
```

with:

```swift
                case .requests:
                    placeholder

                case .stats:
                    StatsView()
```

`MasterRootView` must stay a one-line-per-tab router — no feature UI, no navigation state. That is
why the screen goes into its own file rather than a `statsPlaceholder` property here.

- [ ] **Step 2: Create `Manik/Manik/Master/Stats/StatsView.swift`**

The `NavigationStack` is scoped to this one tab on purpose — wrapping the whole `Group` in
`MasterRootView` would push a navigation bar onto the Розклад tab, which draws its own header.
`.toolbar(.hidden, for: .navigationBar)` keeps this placeholder looking exactly as it does today;
`MyServicesView` hides the bar for itself too and draws a custom header instead.

The link is deliberately a bare `Text` with no capsule, background or explicit tint — it is a
throwaway entry point on a mock placeholder, and the real one arrives with the Статистика PR
(plan step 5).

```swift
import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("master.placeholder.title")
                    .font(.elmsSans(.bold, 24))
                    .foregroundStyle(Color.ink)

                myServicesLink
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var myServicesLink: some View {
        NavigationLink {
            MyServicesView(viewModel: MyServicesViewModel())
        } label: {
            Text("services.action.open")
                .font(.elmsSans(.bold, 14.5))
        }
    }
}

#Preview {
    StatsView()
}
```

- [ ] **Step 3: Ask the user to run a build, then run it**

```bash
cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build
```

Expected: `** BUILD SUCCEEDED **`.

Note that Xcode's live SourceKit diagnostics routinely report `Cannot find type ... in scope` for freshly created files until indexing catches up. Those are stale noise — only this command's output counts. A genuine warning to watch for is `No 'async' operations occur within 'await' expression`; it does not apply to anything in this PR, but if it appears, treat it as a real bug rather than noise.

- [ ] **Step 4: Verify on the simulator**

Run the app and sign in as the master account.
- Tap the **Статистика** tab → the placeholder shows as before, now with a "Мої послуги" capsule button under it and **no** navigation bar.
- Tap the button → `MyServicesView` pushes in with a back chevron and the "Мої послуги" title.
- The floating `CustomTabBar` stays visible over the pushed screen, and the list's last row is not hidden behind it.
- Swipe from the left edge → returns to the placeholder, and the navigation bar disappears again cleanly.
- Because Firestore's `services` collection is still empty (nothing seeds it until PR11), the screen is expected to show **"Поки що немає послуг"**. That is a pass, not a failure. To confirm the list path works against real data, add one service document by hand in the Firebase Console and check that it appears without relaunching the app — the `AsyncStream` listener should push it in live.

---

## Out of scope — do not build these here

Recorded so a reviewer does not flag them as missing:

- Add / edit / delete a service — PR11 and PR12. The design pass did add a `+` button to the
  screen, but its action is an empty stub; the per-row "Змінити" link was left out entirely.
- Rewriting `FakeServiceRepository` as a mutable in-memory class — PR11.
- Removing the `#if DEBUG` fake-services override in `ScheduleView.swift:14` — PR11.
- Moving the entry point from the placeholder onto a real stats screen — the "Статистика" PR (plan step 5).
- Blocking deletion of a service referenced by existing blocks — already decided against; the dangling id is covered by the existing `schedule.service.unknown` fallback.
- Dynamic Type support (`Font.custom(_:size:relativeTo:)`) — app-wide accessibility debt tracked as plan step 10, not this PR's job.
