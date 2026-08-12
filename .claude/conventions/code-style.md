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

One agreed exception: **literal fixture arrays inside `#if DEBUG` preview data may stay packed**
(`BookingPreviewData.swift`, `ServicesPreviewData.swift`). A column of `Service(...)` / `block(...)`
calls reads as a table, which is the point of the file, and none of it ships. The exception is for
fixture *literals* only — production code and preview *views* follow the normal rule.

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
