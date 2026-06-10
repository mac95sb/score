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
            shadows {
                sm: Shadow(y: 1, blur: 2, color: Color(oklch: 0, 0, 0).opacity(0.05))
                md: "0 4px 6px oklch(0 0 0 / 0.07)"
                lg: "0 10px 15px oklch(0 0 0 / 0.1)"
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

## Related Concepts

- <doc:ModifierSystem> — applying tokens via modifiers
- <doc:ViewHierarchy> — the view layer that consumes tokens
