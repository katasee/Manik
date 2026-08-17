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

User-facing strings never sit as bare literals in a View — they go in
`Manik/Manik/Localizable.xcstrings` (String Catalog) under a `feature.kind.name` key
(e.g. `auth.field.email`, `auth.action.signUp`) and get pulled in via `String(localized: "key")`.
Exception: the "Manik" wordmark/brand name — it's not translated, leave it as a literal. Add the
key to the catalog in the same change that introduces the string; don't leave it dangling for a
later pass.

Text never uses the system font — always go through `Font.elmsSans(_:_:)`
(`Manik/Assets/Font/Extension+ElmsSans.swift`), e.g. `.font(.elmsSans(.bold, 32))`, never
`.font(.system(...))`, `.font(.title)`, `.bold()`, or similar. Pick the closest weight from
`ElmsSans` (`regular`/`medium`/`semiBold`/`bold`, in `Manik/Assets/Font/ElmsSansWeight.swift`)
instead of layering SwiftUI's own `.fontWeight()` on top. The four `.ttf` files sit next to these
two Swift files in `Manik/Assets/Font/` and are registered by hand in `Info.plist` under
`UIAppFonts` — adding a new weight means dropping the `.ttf` in that folder *and* adding its
filename to `UIAppFonts`, or `Font.custom` silently falls back to the system font with no warning
or crash.
