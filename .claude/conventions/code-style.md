# Code style

Any function/initializer call with 3 or more arguments gets one argument per line, not packed onto
one line:

```swift
throw NSError(
    domain: "Auth",
    code: 401,
    userInfo: [NSLocalizedDescriptionKey: "Not signed in"]
)
```

Same for declaring a function with 3+ parameters. Under 3 arguments, keep it on one line.

**A trailing closure does not count toward that total — only the arguments inside the parentheses
do.** So `VStack(alignment: .leading, spacing: 8) { ... }` is a two-argument call and stays on one
line, even though `VStack.init` genuinely takes three parameters and the closure is the third
(`content:`). Counting it would split every stack, `Button(action:)` and `ForEach` in the app,
which is not what the rest of the code does — the whole of `Auth/`, `Master/Schedule/` and
`Assets/UICommons/` writes these on one line, and the handful of split ones that had accumulated in
`Client/Booking/` (removed in M-30) were normalized back to match.

One agreed exception: **literal fixture arrays inside `#if DEBUG` preview data may stay packed**
(`ServicesPreviewData.swift`, `SchedulePreviewData.swift`). A column of `Service(...)` / `block(...)`
calls reads as a table, which is the point of the file, and none of it ships. The exception is for
fixture *literals* only — production code and preview *views* follow the normal rule.

**`#if DEBUG` around a `#Preview` is a feature-folder convention, not an app-wide one.** Feature
views wrap their previews because those previews reference `*PreviewData` fixtures, which are
themselves `#if DEBUG` — without the wrapper the file wouldn't compile for release. A component in
`Assets/UICommons/` builds its preview from literals and fakes nothing, so it needs no wrapper, and
none of the components there has one. Match the folder you're writing in.

**Surfaces are modifiers, not fills.** The page (`Background`) and a card (`Card`) are both white
in the light theme, so a bare `.background(Color.card, …)` is invisible. Use one of two
modifiers from `Assets/UICommons/`: `.cardSurface(padding:cornerRadius:)` for cards and boxes —
popup summaries included (contour + two soft shadows; pass `padding: 0` when the card pads itself
asymmetrically) — and `.raisedSurface(shape)` for small raised controls (unselected chips, round
buttons, fields; filled with `Raised`). In dark the shadows (tinted with `Shadow`, black there)
vanish on the near-black page, so depth comes from tone (`Card` `#1F1A1F` and `Raised` `#2C252C`
on `Background` `#0B080B`) plus a top rim and a soft top-down sheen tinted with `Highlight` —
clear in light, white in dark, so the light theme is untouched. Both modifiers draw it; don't add
`colorScheme` branches to get depth. **Nothing a user reads as an object is flat**: a flat outlined box
(`.insetSurface`) existed in M-27 and was removed after a device pass, because a summary plate that
does not lift reads as a hole in the popup. The deliberately flat exceptions are markers, not
objects: the dashed free slot, the "today" outline in `WeekDayStrip`, the "Вільно" pill outline.
A raised control that can be *selected* swaps its surface for a `PrimaryFill` fill with
`.brandShadow()` (the selected day in `WeekDayStrip`); write that as an explicit `if`/`else` in
`.background`, not as a fill stacked over a raised one. `Hairline` is for dividers and outlines
only — never a fill (the client avatar, removed in M-30, shaded with a `Raised` → `Shadow` gradient instead) — and
`Stroke` is for the dashed free slot (the unchecked `ServicesChecklist` circle is `Ink`, kept from
before the dark theme so light stays unchanged). Shadows sit on the surface's background shape,
never on the whole content — `.shadow` on a view with children shadows each child. A horizontal `ScrollView` of raised chips
clips their shadows; the client booking chip row (removed in M-30) used `.scrollClipDisabled()` (scrolled chips may then paint into
the screen gutters — accepted).

User-facing strings never sit as bare literals in a View — they go in
`Manik/Manik/Localizable.xcstrings` (String Catalog) under a `feature.kind.name` key
(e.g. `auth.field.email`, `auth.action.signUp`) and get pulled in via `String(localized: "key")`.
Exception: the "Manik" wordmark/brand name — it's not translated, leave it as a literal. Add the
key to the catalog in the same change that introduces the string; don't leave it dangling for a
later pass.

Text never uses the system font — always go through `Font.elmsSans(_:_:)`
(`Manik/Assets/Font/Extension+ElmsSans.swift`), e.g. `.font(.elmsSans(.bold, 32))`, never
`.font(.system(...))`, `.font(.title)`, `.bold()`, or similar. Pick the closest weight from
`ElmsSans` (`regular`/`medium`/`semiBold`/`bold`, in `Manik/Assets/Font/ElmsSansWeight.swift`;
the mockup's weight 600 is `.semiBold`, 700 is `.bold`)
instead of layering SwiftUI's own `.fontWeight()` on top. The four `.ttf` files sit next to these
two Swift files in `Manik/Assets/Font/` and are registered by hand in `Info.plist` under
`UIAppFonts` — adding a new weight means dropping the `.ttf` in that folder *and* adding its
filename to `UIAppFonts`, or `Font.custom` silently falls back to the system font with no warning
or crash.

The one exception is **tab bar labels**: they are drawn by the system `TabView`, which renders them in
the system font; don't try to force ElmsSans onto them through `UITabBarAppearance`.

**Colour scheme and roles.** The app has a light and a dark theme ("Темне вино", the canvas page
"Темний + темне вино"); every colorset carries both appearances. The user picks System / Light /
Dark in a popup (`Appearance/`); the choice is `AppAppearance` in `@AppStorage("appearance")`,
applied once with `.preferredColorScheme` on `RootView`. There is no light lock any more — don't
reintroduce `INFOPLIST_KEY_UIUserInterfaceStyle`, and don't branch on `colorScheme` in views: a
colour that differs between themes is a colorset, not an `if`.

Each token has **one role**, because one colour cannot serve two roles in both themes (that is
what broke when `Ink` was text *and* fill *and* shadow):

| Token | Role | Light / dark |
|---|---|---|
| `Ink` | text and glyphs only | `#0A0A0B` / `#FFFFFF` |
| `PrimaryFill` / `OnPrimary` | primary button and every selected fill / text on it | `#0A0A0B` / `#6B3442`; white |
| `Raised` | `.raisedSurface` fill | `#FFFFFF` / `#2C252C` |
| `Destructive` / `DestructiveFill` | destructive text / destructive fill | `#C42F2F`; `#FF6961` / `#D93A3A` |
| `Shadow` | every shadow | `#0A0A0B` / `#000000` |
| `Backdrop` | popup backdrop | ink 22% / black 55% |
| `Highlight` | surface rim and sheen | clear / white |
| `HeaderFill` | `BookingHeader` block — unused since M-30 removed it | `#0A0A0B` / `#1F1A1F` (card tone) |

Never name a colorset after an existing SwiftUI `Color` member — the generated symbol collides
(`Primary` would be `Color.primary`, hence `PrimaryFill`).

**Accent and tab bar.** `AccentColor` is `#0A0A0B` / `#D7ADB5`; it drives carets, alert buttons,
pickers and the `RoundIconButton` glyph. The selected **tab** is deliberately *not* the accent:
the `TabView` is `.tint(Color.ink)` (black / white, user decision after a device pass — wine
`#6B3442` on the dark glass bar was ~1.7:1), and each tab's content is re-tinted
`.tint(Color.accentColor)` so the tab tint does not leak into carets and pickers. That pair of
`.tint`s is the one sanctioned exception to "no global tint in code"; a local `.tint` on a spinner
or a button (`ListStatusOverlay`, `CapsuleButton`) is fine as before.

**The wine marks are a separate token, not the accent.** `Wine` (`#7D2E3E` / `#D7ADB5`) and
`WineSoft` (`#F6E9EC` / `#2C252C`, the tile under it) are applied *by name* in small doses: the auth
swap link, `IconBadge` (wine glyph on a flat `WineSoft` tile), the expected-revenue amount,
today's number in `WeekDayStrip`. In dark the wine *fill* `#6B3442` is `PrimaryFill`, not `Wine`.
Wine marks; it never replaces ink.
