# Theme and Design Tokens

Configure colours, typography, spacing, and dark mode from a single ``SiteTheme``.

## Overview

Score's design token system flows from ``SiteTheme`` declared on your
``Application``. Every modifier references the theme — `.background(color: .primary)`
resolves through the token system to an `oklch()` value in the final CSS.
Changing a token in one place updates every component that references it.

All colours are stored and output in `oklch`. The ``Color`` type accepts
any input format and normalises internally.

## Semantic Colour Aliases

Use semantic aliases rather than raw palette values. Components stay
theme-agnostic — change the alias once in ``SiteTheme`` and every component updates:

```swift
Color.primary      // main brand colour
Color.accent       // secondary highlight
Color.surface      // card and panel backgrounds
Color.secondary    // subtle backgrounds
Color.tertiary     // extra-subtle backgrounds
Color.muted        // placeholder and subdued text
Color.destructive  // errors and dangerous actions
```

## The Full Palette

Every hue ships with a complete 50–950 lightness scale:

```swift
Color.violet(600)
Color.emerald(400)
Color.slate(500)
// All hues: slate, gray, zinc, neutral, stone, red, orange, amber, yellow,
// lime, green, emerald, teal, cyan, sky, blue, indigo, violet, purple,
// fuchsia, pink, rose
```

Semantic aliases can be shaded the same way:

```swift
Color.primary(300)
Color.primary(600)
Color.primary(900)
```

## Colour Input Formats

```swift
Color(hex: "#6366F1")
Color(rgb: 99, 102, 241)
Color(hsl: 239, 84, 67)
Color(oklch: 0.6, 0.2, 270)
```

## Colour Modifiers

```swift
Color.primary.opacity(0.1)
Color.primary(300).opacity(0.5)
Color.violet(500).lighten(0.15)
Color.slate(900).darken(0.1)
Color.primary.mix(.accent, by: 0.5)
```

## Defining a Theme

Override `theme` on your ``Application``:

```swift
@main
struct MySite: Application {
    var theme: SiteTheme {
        SiteTheme {
            colors {
                primary:     .violet(600)
                accent:      .emerald(400)
                surface:     .white
                muted:       .slate(500)
                destructive: .rose(600)
            }
            fonts {
                body:    .system
                heading: .custom("Fraunces", url: "/fonts/Fraunces.woff2")
                mono:    .systemMono
            }
            radii {
                sm: 4; md: 8; lg: 12; xl: 16; twoXL: 24
            }
            breakpoints {
                phone: 480; tablet: 768; desktop: 1024; wide: 1280; ultrawide: 1536
            }
        }
    }
}
```

## Dark Mode

The `dark {}` block emits both OS-preference and manual override CSS:

```swift
SiteTheme {
    colors {
        surface: .white
        text:    .slate(900)
    }
    dark {
        surface: Color(oklch: 0.12, 0, 0)
        text:    .slate(100)
    }
}
```

Score emits:

```css
@media (prefers-color-scheme: dark) { :root { --color-surface: oklch(0.12 0 0); } }
[data-theme="dark"] :root { --color-surface: oklch(0.12 0 0); }
```

Toggle manually with `@State var theme: AppTheme` — Score wires the
`data-theme` attribute automatically.

## Spacing Scale

Score uses the same numeric scale as Tailwind CSS — 4 pt base unit at
`multiplier: 1.0`. The same step numbers apply everywhere: `.padding()`,
`.margin()`, `.frame()`, `.translate()`, `.flex(gap:)`, `.grid(gap:)`.

| Step | px | Step | px | Step | px |
|------|-----|------|-----|------|-----|
| 0 | 0 | 6 | 24 | 16 | 64 |
| 1 | 4 | 7 | 28 | 20 | 80 |
| 2 | 8 | 8 | 32 | 24 | 96 |
| 3 | 12 | 9 | 36 | 32 | 128 |
| 4 | 16 | 10 | 40 | 48 | 192 |
| 5 | 20 | 12 | 48 | 64 | 256 |

Explicit values bypass the scale: `.px(n)`, `.rem(n)`, `.percent(n)`,
`.vw(n)`, `.vh(n)`, `.dvh(n)`, `.auto`, `.full`, `.screen`, `.min`, `.max`, `.fit`.

## Font Size Scale

| Name | px | Name | px |
|------|-----|------|-----|
| `.xs` | 12 | `.twoXL` | 24 |
| `.sm` | 14 | `.threeXL` | 30 |
| `.base` | 16 | `.fourXL` | 36 |
| `.lg` | 18 | `.fiveXL` | 48 |
| `.xl` | 20 | `.sixXL` | 60 |

## Custom Design Tokens

Add arbitrary CSS custom properties via the token escape hatch:

```swift
var theme: SiteTheme {
    SiteTheme { colors { primary: .violet(600) } }
    tokens: {
        Token("--brand-gradient", "linear-gradient(135deg, oklch(0.6 0.2 270), oklch(0.7 0.15 220))")
        Token("--hero-height", "calc(100dvh - 64px)")
    }
}
```

## Developer Theme Presets

Score ships colour palettes based on popular editor themes. Use them as
`darkColors` or `customThemes` entries on ``SiteTheme``:

```swift
var theme: SiteTheme {
    SiteTheme(
        darkColors: .tokyoNight,          // OS-dark-mode variant
        customThemes: [
            "rose-pine":    .rosePine,
            "vesper":       .vesper,
            "one-dark":     .oneDark,
            "gruvbox":      .gruvboxDark,
        ]
    )
}
```

Available presets (all on `ThemeColors`):

| Name | Style |
|------|-------|
| `.rosePine` | Warm purple dark |
| `.rosePineDawn` | Warm purple light |
| `.tokyoNight` | Cool blue-purple dark |
| `.tokyoNightStorm` | Slightly lighter Tokyo Night |
| `.vesper` | Minimal warm-toned dark |
| `.oneDark` | Atom One Dark — blue-grey |
| `.gruvboxDark` | Retro warm dark |
| `.gruvboxLight` | Retro warm light |

## Theme Selector Component

``ThemeSelector`` renders a `<select>` dropdown that switches themes at runtime
by writing a `data-theme` attribute to `<html>`. Selection is persisted in
`localStorage`.

```swift
// In a navigation bar or settings panel
ThemeSelector([
    .init("Default",     themeKey: ""),
    .init("Rosé Pine",   themeKey: "rose-pine"),
    .init("Tokyo Night", themeKey: "tokyo-night"),
    .init("One Dark",    themeKey: "one-dark"),
    .init("Gruvbox",     themeKey: "gruvbox"),
])
```

Pass `mode: .palette` to switch colour palettes independently of other theme
settings (e.g. light vs dark is a theme choice; accent colour is a palette
choice):

```swift
ThemeSelector(palette: [
    .init("Default", themeKey: ""),
    .init("Warm",    themeKey: "warm"),
    .init("Cool",    themeKey: "cool"),
])
```

## Shadows

Shadows are referenced through semantic tokens — use `.shadow(.sm)`, `.shadow(.md)`,
`.shadow(.lg)`, `.shadow(.xl)`, `.shadow(.twoXL)`, or `.shadow(ring:)`.
The token values are emitted as CSS custom properties by ``SiteTheme``:

```swift
.shadow(.md)                             // var(--shadow-md)
.shadow(.lg, color: .primary.opacity(0.2))  // coloured shadow
.shadow(ring: 2, color: .primary.opacity(0.4))  // focus ring
```

## Related Concepts

- <doc:ModifierSystem> — applying tokens via modifiers
- <doc:ViewHierarchy> — the view layer that consumes tokens
