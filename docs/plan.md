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

## Next steps (in order)

1. **Master — "Розклад" (Schedule)** screen (mockup screen 02): day-of-week strip up top, tap
   selects a day; hourly agenda below — empty hour shows "+ Додати вільний час", booked hour shows
   a card (client name, status pill, chosen service). Backed by `Block`/`BlockRepository`
   (already built in PR1).
2. **Master — "Заявки" (Requests)**: list of `pending` blocks, confirm/decline actions.
3. **Master — "Статистика" (Stats)**: month summary (revenue/visits/cancellations) + entry point to
   "Мої послуги" (services CRUD).
4. **Client — "Запис" (Booking)** (mockup screen 03): month calendar → time chips → service picker
   → footer bar with "Продовжити".
5. **Client — "Мої записи" (My bookings)**: list of own pending/confirmed blocks, cancel action.
6. **Client — "Акаунт" (Account)**: currently an `EmptyView()` placeholder behind the 3rd client
   tab (`ClientTab.account`) — needs real content (profile info, sign out moved here from the
   temporary root placeholder, etc.).
7. **"Забули пароль?"**: decide tappable-stub vs. real `sendPasswordReset` flow, then implement.
   (Was tracked as a task in a now-disconnected MCP tool — re-track here instead.)
8. **Confirm `firestore.rules` deployment**: verify the latest rules (format validation +
   privilege-escalation + booking field-pinning) are actually published in Firebase Console — this
   has been mentioned multiple times but never confirmed done.
9. **Live badge counter on "Заявки"**: `CustomTabBar`'s badge parameter currently always returns
   `nil` (`Master/MasterRootView.swift`, `CabinetKind.master`'s `badge` closure). Once the
   "Заявки" screen (step 2 above) exists, wire this to a live count of `pending`-status blocks
   from `BlockRepository`, likely via an `AsyncStream` observation similar to `observeBlocks()`.

## Housekeeping

- Commit + push `feature/pr3/root-routing`, open PR, once the tab bar + first cabinet screen make
  it a coherent reviewable chunk (or sooner, at your discretion).
