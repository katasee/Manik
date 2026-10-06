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
`Client/Booking/` were normalized back to match.

One agreed exception: **literal fixture arrays inside `#if DEBUG` preview data may stay packed**
(`BookingPreviewData.swift`, `ServicesPreviewData.swift`). A column of `Service(...)` / `block(...)`
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
buttons, fields). **Nothing a user reads as an object is flat**: a flat outlined box
(`.insetSurface`) existed in M-27 and was removed after a device pass, because a summary plate that
does not lift reads as a hole in the popup. The deliberately flat exceptions are markers, not
objects: the dashed free slot, the "today" outline in `WeekDayStrip`, the "Вільно" pill outline.
A raised control that can be *selected* swaps its surface for an ink fill with `.brandShadow()`
(`SlotChip`, the selected day); write that as an explicit `if`/`else` in `.background`, not as an
ink layer stacked over a raised one. `Hairline` is for dividers and outlines only — never a fill
(the avatar's shading is `Ink` at low opacity instead) — and `Stroke` is for the dashed free slot
and unchecked checks. Shadows sit on the surface's background shape, never on the whole content —
`.shadow` on a view with children shadows each child. A horizontal `ScrollView` of raised chips
clips their shadows; the chip row uses `.scrollClipDisabled()` (scrolled chips may then paint into
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

**Colour scheme and accent.** The app is locked to light (`INFOPLIST_KEY_UIUserInterfaceStyle =
Light`) because no colorset has a dark variant yet. The accent — selected tab, alert buttons,
text-field carets — comes only from the `AccentColor` asset (`#0A0A0B`, the light redesign's ink);
don't set the accent or the tab selection colour with `.tint` in code (a local `.tint` on a
spinner or a button, as `ListStatusOverlay` and `CapsuleButton` do, is fine). The dark theme ("Темне вино") will remove the lock and give
`AccentColor` a dark appearance (`#D7ADB5`) in the same change — never ship that dark value while
the app is light-only, it is ~1.5:1 on the light background.

**The wine accent is a separate token, not the accent colour.** `Wine` (`#7D2E3E`, 9:1 on white)
and `WineSoft` (`#F6E9EC`, the tile under it; wine on it is 7.7:1) are the light half of "Темне
вино", applied *by name* in small doses: the auth swap link, `IconBadge` (wine glyph on a flat
`WineSoft` tile), the expected-revenue amount, today's number in `WeekDayStrip`. `AccentColor`
stays ink on purpose — it drives the selected tab, and the tab bar and its badge are explicitly
kept out of the wine (user decision), so routing wine through `AccentColor` would recolour the tab
bar. Primary buttons, the selected day, status colours and destructive red don't change either.
Wine marks; it never replaces ink.
