# Theme and Design Tokens

Configure colours, typography, spacing, and dark mode from a single `SiteTheme`.

## Overview

Score's design token system flows from `SiteTheme` declared on your
`Application`. Every modifier references the theme —
`.background(color: .primary)` resolves through the token system to an `oklch()`
value in the final CSS. Changing a token in one place updates every component
that references it.

All colours are stored and output in `oklch`. The `Color` type accepts any input
format and normalises internally.

## Semantic Colour Aliases

Favor semantic aliases rather than raw palette values. Components stay
theme-agnostic — change the alias once in `SiteTheme` and every component
updates:

```swift
Color.primary  // main brand colour
Color.accent  // secondary highlight
Color.surface  // card and panel backgrounds
Color.secondary  // subtle backgrounds
Color.tertiary  // extra-subtle backgrounds
Color.muted  // placeholder and subdued text
Color.destructive  // errors and dangerous actions
```

## The Full Palette

Every hue ships with a complete 50–950 lightness scale (steps: 50, 100, 200,
300, 400, 500, 600, 700, 800, 900, 950).

| Group | Hues |
|-------|------|
| Neutral | `slate` · `gray` · `zinc` · `neutral` · `stone` |
| Warm | `red` · `orange` · `amber` · `yellow` |
| Nature | `lime` · `green` · `emerald` · `teal` · `cyan` |
| Cool | `sky` · `blue` · `indigo` · `violet` · `purple` |
| Vivid | `fuchsia` · `pink` · `rose` |

```swift
Color.violet(600)  // mid-dark violet
Color.emerald(400)  // light emerald
Color.slate(100)  // near-white slate tint
```

Semantic aliases are single-value tokens — they resolve through the theme at runtime and do not accept shade numbers. To get a lighter or darker variant, use `.lighten()`, `.darken()`, or `.opacity()`:

```swift
Color.primary.opacity(0.1)  // 10% opacity overlay
Color.primary.lighten(0.1)  // 10% lighter
Color.accent.darken(0.15)  // 15% darker
```

### Custom Colour Scales

To use a brand colour not in the built-in palette, pass an explicit `Color`
value and register a named `customPalette` on `SiteTheme`:

```swift
var theme: SiteTheme {
    SiteTheme(
        customPalettes: [
            "brand": ThemeColors(
                primary: Color(hex: "#0F4C81"),
                accent: Color(hex: "#F4A300"),
                surface: .white,
                secondary: Color(hex: "#EFF4FA"),
                tertiary: Color(hex: "#E0EAF7"),
                muted: Color(hex: "#6B7C93"),
                text: Color(hex: "#1A202C"),
                destructive: Color(hex: "#C0392B")
            )
        ]
    )
}
```

Pair with a `ThemeSelector(palette:)` to let users switch between palettes at
runtime without a page reload.

## Colour Input Formats

```swift
Color(hex: "#6366F1")
Color(rgb: 0.388, 0.400, 0.945)  // values in 0.0–1.0 range
Color(hsl: 239, 84, 67)  // hue 0–360, saturation/lightness 0–100
Color(oklch: 0.6, 0.2, 270)
```

## Colour Modifiers

```swift
Color.primary.opacity(0.1)
Color.primary.opacity(0.5)
Color.violet(500).lighten(0.15)
Color.slate(900).darken(0.1)
Color.primary.mix(.accent, by: 0.5)
```

## Defining a Theme

Override `theme` on your `Application`:

```swift
@main
struct MySite: Application {
    var theme: SiteTheme {
        SiteTheme(
            colors: ThemeColors(
                primary: .violet(600),
                accent: .emerald(400),
                surface: .white,
                secondary: .violet(50),
                tertiary: .violet(100),
                text: .slate(900),
                muted: .slate(500),
                destructive: .rose(600)
            ),
            fonts: ThemeFonts(
                body: .system,
                heading: .custom("Fraunces", url: "/fonts/Fraunces.woff2"),
                mono: .systemMono
            ),
            radii: ThemeRadii(sm: 4, md: 8, lg: 12, xl: 16, twoXL: 24, full: 9999),
            breakpoints: ThemeBreakpoints(phone: 480, tablet: 768, desktop: 1024, wide: 1280, ultrawide: 1536)
        )
    }
}
```

For most apps, `SiteTheme.preset(_:palette:)` is simpler — it fills in all the defaults from the chosen palette and preset:

```swift
var theme: SiteTheme { .preset(.modern, palette: .violet) }
```

## Custom Fonts

`FontFamily.custom` supports both self-hosted and remote font services.

### Self-hosted (recommended)

Provide a font name and the URL to your `.woff2` file. Score emits a
`<link rel="preload">` and an `@font-face` rule automatically:

```swift
SiteTheme(
    fonts: ThemeFonts(
        body: .custom("Inter", url: "/fonts/Inter.woff2"),
        heading: .custom("Fraunces", url: "/fonts/Fraunces.woff2"),
        mono: .systemMono
    )
)
```

Place your font files in `Public/fonts/` so Score copies them verbatim to the
build output.

### Remote (e.g. Google Fonts)

Pass the stylesheet URL as `url:` and the CDN origins as `supplementaryURLs:`
so the browser can preconnect before it knows it needs the font:

```swift
SiteTheme(
    fonts: ThemeFonts(
        body: .system,
        heading: .custom(
            "Playfair Display",
            url: "https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700",
            supplementaryURLs: [
                "https://fonts.googleapis.com",
                "https://fonts.gstatic.com",
            ]
        ),
        mono: .systemMono
    )
)
```

Score emits:

```html
<link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700">
```

## Dark Mode

Pass `darkColors` to emit both OS-preference and manual override CSS:

```swift
SiteTheme(
    colors: ThemeColors(surface: .white, text: .slate(900), ...),
    darkColors: ThemeColors(surface: Color(oklch: 0.12, 0, 0), text: .slate(100), ...)
)
```

Score emits:

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: oklch(0.12 0 0);
  }
}
[data-theme="dark"] :root {
  --color-surface: oklch(0.12 0 0);
}
```

Add a `ThemeSelector` to let users toggle manually — Score writes the
`data-theme` attribute to `<html>` and persists the selection in `localStorage`.

## Spacing Scale

Score uses a 4 pt base unit at `multiplier: 1.0`. The same step numbers apply
everywhere: `.padding()`, `.margin()`, `.frame()`, `.translate()`,
`.flex(gap:)`, `.grid(gap:)`.

| Step | px | Step | px | Step | px  |
| ---- | -- | ---- | -- | ---- | --- |
| 0    | 0  | 6    | 24 | 16   | 64  |
| 1    | 4  | 7    | 28 | 20   | 80  |
| 2    | 8  | 8    | 32 | 24   | 96  |
| 3    | 12 | 9    | 36 | 32   | 128 |
| 4    | 16 | 10   | 40 | 48   | 192 |
| 5    | 20 | 12   | 48 | 64   | 256 |

Explicit values bypass the scale: `.px(n)`, `.rem(n)`, `.percent(n)`, `.vw(n)`,
`.vh(n)`, `.dvh(n)`, `.auto`, `.full`, `.screen`, `.min`, `.max`, `.fit`.

## Font Size Scale

| Name    | px | Name       | px |
| ------- | -- | ---------- | -- |
| `.xs`   | 12 | `.twoXL`   | 24 |
| `.sm`   | 14 | `.threeXL` | 30 |
| `.base` | 16 | `.fourXL`  | 36 |
| `.lg`   | 18 | `.fiveXL`  | 48 |
| `.xl`   | 20 | `.sixXL`   | 60 |

## Palette, Preset, and Colour Scheme Model

Score's theming system has three distinct layers:

**Hue scales** (`Color.violet(500)`, `Color.slate(200)`) are raw colour values —
use them anywhere a `Color` is accepted, including token definitions, modifier
arguments, and component parameters.

**`ThemePalette`** is a paired light + dark `ThemeColors` bundle. Pass one to
`SiteTheme.preset(_:palette:)` to drive the entire site's colour tokens from a
single named choice.

| Palette | Character |
|---------|-----------|
| `.violet` | Purple primary, emerald accent |
| `.indigo` | Blue-purple primary, sky accent |
| `.blue` | Blue primary, cyan accent |
| `.emerald` | Green primary, amber accent |
| `.teal` | Teal primary, orange accent |
| `.rose` | Red-pink primary, amber accent |
| `.mono` | Slate primary, blue accent |
| `.ocean` | Deep blue-teal |
| `.forest` | Forest green |
| `.sunset` | Warm orange-rose |
| `.midnight` | Deep indigo-violet |
| `.berry` | Berry pink-purple |
| `.ember` | Ember orange-red |
| `.citrus` | Lime-amber |

```swift
var theme: SiteTheme { .preset(.modern, palette: .indigo) }
```

**`ThemePreset`** configures shape tokens (radii, shadows) and enables component
styles. Available presets: `.minimal`, `.modern`, `.soft`, `.neoBrutalism`.

**Colour Schemes** (`ThemeColors` extensions — `.rosePine`, `.tokyoNight`, etc.)
are hand-tuned full colour overrides for dark mode or named custom themes. Unlike
`ThemePalette`, which generates light and dark from hue functions, colour schemes
are crafted for specific aesthetics. Register them as `darkColors` or
`customThemes` on `SiteTheme`.

## Colour Schemes

Score ships curated colour schemes based on popular editor themes. Use them as
a dark-mode palette or as named custom themes on `SiteTheme`:

```swift
var theme: SiteTheme {
    SiteTheme(
        darkColors: .tokyoNight,  // OS-dark-mode variant
        customThemes: [
            "rose-pine": .rosePine,
            "vesper": .vesper,
            "one-dark": .oneDark,
            "gruvbox": .gruvboxDark,
        ]
    )
}
```

Available presets (all on `ThemeColors`):

| Name               | Style                        |
| ------------------ | ---------------------------- |
| `.rosePine`        | Warm purple dark             |
| `.rosePineDawn`    | Warm purple light            |
| `.tokyoNight`      | Cool blue-purple dark        |
| `.tokyoNightStorm` | Slightly lighter Tokyo Night |
| `.vesper`          | Minimal warm-toned dark      |
| `.oneDark`         | Atom One Dark — blue-grey    |
| `.gruvboxDark`     | Retro warm dark              |
| `.gruvboxLight`    | Retro warm light             |

## Theme Selector Component

`ThemeSelector` renders a `<select>` dropdown that switches themes at runtime by
writing a `data-theme` attribute to `<html>`. Selection is persisted in
`localStorage`.

```swift
// In a navigation bar or settings panel
ThemeSelector([
    .init("Default", themeKey: ""),
    .init("Rosé Pine", themeKey: "rose-pine"),
    .init("Tokyo Night", themeKey: "tokyo-night"),
    .init("One Dark", themeKey: "one-dark"),
    .init("Gruvbox", themeKey: "gruvbox"),
])
```

Pass `mode: .palette` to switch colour palettes independently of other theme
settings (e.g. light vs dark is a theme choice; accent colour is a palette
choice):

```swift
ThemeSelector(palette: [
    .init("Default", themeKey: ""),
    .init("Warm", themeKey: "warm"),
    .init("Cool", themeKey: "cool"),
])
```

## Shadows

Shadows are referenced through semantic tokens — use `.shadow(.sm)`,
`.shadow(.md)`, `.shadow(.lg)`, `.shadow(.xl)`, `.shadow(.twoXL)`, or
`.shadow(ring:)`. The token values are emitted as CSS custom properties by
`SiteTheme`:

```swift
.shadow(.md)  // var(--shadow-md)
    .shadow(.lg, color: .primary.opacity(0.2))  // coloured shadow
    .shadow(ring: 2, color: .primary.opacity(0.4))  // focus ring
```

## See Also

- <doc:ModifierSystem>
- <doc:ComponentTheming>
- <doc:GettingStarted>
