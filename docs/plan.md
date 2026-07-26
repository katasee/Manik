# Manik — Implementation Plan

Living checklist of implementation progress and next steps. Update this file whenever a step is
finished or the plan changes — this is what lets work continue from any machine/terminal. Full
product scope/design decisions live in `docs/superpowers/specs/2026-07-15-manik-mvp-design.md`;
this file is just "what's done, what's next," not a design doc.

## Done

- **PR1 — data layer**: `Models/` (`UserProfile`, `Service`, `Block`), `Services/Repositories/`
  (protocols) + `Services/Firestore/` (implementations), `firestore.rules` (format validation,
  privilege-escalation protection, client-booking field pinning). Firebase SDK as remote SPM
  dependency.
- **PR2 — Auth**: `Auth/AuthView.swift` + `AuthViewModel.swift`, email/password sign in/sign up.
  Design system: custom `ElmsSans` font (`Assets/Font/` + `Assets/UICommons/Extension+ElmsSans.swift`),
  color palette in `Assets.xcassets` (`Background`, `Ink`, `TextSecondary`, `Surface`,
  `FieldBackground`, `Badge`), shared `View+BrandShadow`. `AuthView` split into
  `AuthFieldView`/`ModeSwitcher`/`AuthFocusField`/`AuthMetrics`.
- **PR3 — root routing (in progress, branch `feature/pr3/root-routing`)**: `Root/RootView.swift` +
  `RootViewModel.swift` — checks auth state + role (`fetchProfile()`), routes to
  `Master/MasterRootView.swift` / `Client/ClientRootView.swift` (currently placeholder screens:
  cabinet title + name + sign out). `ManikApp` now starts from `RootView()`.
- **PR4 — custom tab bar (branch `feature/pr-4-custom-tabbar`)**: `TabBar/` (`CustomTabBar` +
  `CabinetKind`, `TabBarButton`, `TabBarActiveIndicator`, `TabBarBadge`, `TabBarMetrics`),
  `Master/MasterTab.swift`, `Client/ClientTab.swift`. Floating dark-capsule tab bar (fixed 70pt
  height, visible captions under each icon) wired into `MasterRootView` (3 tabs) and
  `ClientRootView` (3 tabs — added "Акаунт"/`.account`, currently an `EmptyView()` placeholder).
  Colors consolidated: `TextPrimary` renamed to `Ink` (general dark UI token, not just text), the
  two dedicated `TabBarBackground`/`TabBarActiveBackground` colors were dropped in favor of
  reusing `Ink`/`Background`. Badge parameter exists but is stubbed to `nil` until the Requests
  screen ships (tracked as a Next step above).
- **PR5 — Master Schedule shell (branch `feature/pr-5-scheduleView`)**: view-only Schedule screen —
  `Master/Schedule/` (`ScheduleView` with title + week strip + hourly timeline, `@State selectedDate`,
  no view model; `HourlyTimelineView` = hour label per row with a `DashedSlot` in the gap;
  `ScheduleMetrics`). Reusable components pulled into `Assets/UICommons/`: `WeekDayStrip` (week-day
  date picker) and `DashedSlot` (tappable dashed-outline labeled slot), both decoupled from feature
  metrics. `DateFormat` split into storage formatters (`date`/`time`, pinned `en_US_POSIX` for
  Firestore) and display formatters (`dayNumber`/`weekdayLetter`/`monthYear`, `Locale.current` so the
  UI is multilingual). Tab bar scroll-clearance fixed: content reserves space via a `Color.clear`
  `safeAreaInset` (`TabBarMetrics.reservedClearance`) while the bar stays a `ZStack` overlay so its
  switch animation stays smooth. Block-rendering work (`ScheduleBlockCard`, `ScheduleBlockDetailSheet`,
  `ScheduleViewModel`, `UserRepository`/`FirestoreUserRepository`, `SchedulePreviewData`) was built
  then **git-stashed** for the follow-up slices below (still sitting in `git stash list`, untouched
  by PR7 — see PR7 note on why).
- **PR7 — Master Schedule: create free-time slot (branch `feature/pr-7-createFreeSlot`)**: tapping
  `DashedSlot`'s "+ Додати вільний час" on any hour row opens `Master/Schedule/CreateBlock/
  AddNewSlotBlock.swift` — a custom centered popup (not a system `.sheet`/`.fullScreenCover`;
  presented as a `ZStack` overlay owned by `MasterRootView`, the only place with a shared `ZStack`
  spanning both the schedule content and the floating `CustomTabBar`, so the overlay still sits
  above the tab bar). Backdrop is `.ultraThinMaterial` at `.opacity(0.9)`, tapping it dismisses the
  popup (an accessible `Button`, not `onTapGesture`); the card itself fades+scales in/out
  (`.transition(.opacity.combined(with: .scale(scale: 0.92)))`) and carries `.brandShadow()` (needs
  `.compositingGroup()` first, otherwise SwiftUI shadows every child individually instead of the
  card's outline). Fields: "Дата" is a native `DatePicker(.date)`; "Початок"/"Кінець" are plain
  `TextField`s for manual `HH:mm` entry (parsed/validated in `CreateBlockViewModel`'s
  `startTimeText`/`endTimeText`, `didSet`-driven) — not a wheel picker, since a UIKit-wrapped
  `UIDatePicker` (tried first, for `minuteInterval` snapping) and a plain `DatePicker` wheel were
  both dropped in favor of typing the time directly. Default duration when opening the popup is 1
  hour (`ScheduleMetrics.CreatePopup.defaultDurationMinutes = 60`). Services render as a checklist
  (`ServicesChecklist`, checkmark-circle icons) reading whatever's in the `services` Firestore
  collection — no CRUD screen yet (still step 3 below), so services are hand-seeded via Firebase
  Console for now. **`MasterRootView` currently has a `#if DEBUG` override feeding `ScheduleView`
  a `FakeServiceRepository`/`SchedulePreviewData` instead of live Firestore** — kept in place
  deliberately (not yet reverted) so the checklist has something to show before real services are
  seeded; remove this once Firestore `services` has real data or step 3's CRUD screen exists.
  New files live under `Master/Schedule/CreateBlock/` (`AddNewSlotBlock`, `CreateBlockContext`,
  `CreateBlockViewModel`, `ServicesChecklist`) and `Services/Fakes/` (`FakeBlockRepository`,
  `FakeServiceRepository`) — split out from a flatter `Master/Schedule/` once it hit 11 files.
  Does **not** touch the PR5 stash (still separate, still for step 2 below) and does not render
  `pending`/`confirmed` blocks or hide the "+" for already-occupied hours — both deferred to step 2.

## Next steps (in order)

1. **Master — Schedule: render + manage blocks** — show `pending`/`confirmed` blocks as cards on the
   timeline (pop stashed `ScheduleBlockCard`/`ScheduleViewModel`/`UserRepository`), tap → detail
   sheet; also the natural point to hide "+ Додати вільний час" for hours already covered by a
   block (PR7 left every hour showing it, regardless of existing blocks). Overlaps with
   **"Заявки" (Requests)**: list of `pending` blocks, confirm/decline actions.
2. **Master — "Статистика" (Stats)**: month summary (revenue/visits/cancellations) + entry point to
   "Мої послуги" (services CRUD). Once this exists, remove PR7's `#if DEBUG` fake-services override
   in `MasterRootView` and seed real services through the CRUD screen instead of Firebase Console.
3. **Client — "Запис" (Booking)** (mockup screen 03): month calendar → time chips → service picker
   → footer bar with "Продовжити".
4. **Client — "Мої записи" (My bookings)**: list of own pending/confirmed blocks, cancel action.
5. **Client — "Акаунт" (Account)**: currently an `EmptyView()` placeholder behind the 3rd client
   tab (`ClientTab.account`) — needs real content (profile info, sign out moved here from the
   temporary root placeholder, etc.).
6. **"Забули пароль?"**: decide tappable-stub vs. real `sendPasswordReset` flow, then implement.
   (Was tracked as a task in a now-disconnected MCP tool — re-track here instead.)
7. **Confirm `firestore.rules` deployment**: verify the latest rules (format validation +
   privilege-escalation + booking field-pinning) are actually published in Firebase Console — this
   has been mentioned multiple times but never confirmed done.
8. **Live badge counter on "Заявки"**: `CustomTabBar`'s badge parameter currently always returns
   `nil` (`Master/MasterRootView.swift`, `CabinetKind.master`'s `badge` closure). Once the
   "Заявки" screen (step 1 above) exists, wire this to a live count of `pending`-status blocks
   from `BlockRepository`, likely via an `AsyncStream` observation similar to `observeBlocks()`.

## Housekeeping

- Commit + push `feature/pr3/root-routing`, open PR, once the tab bar + first cabinet screen make
  it a coherent reviewable chunk (or sooner, at your discretion).
