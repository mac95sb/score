# Theme and Tokens

Score's design system: theme tokens, colour palettes, dark mode, and
whole-theme presets.

## Overview

A ``SiteTheme`` describes your application's entire visual system — colours,
fonts, spacing, radii, shadows, and breakpoints. Score emits it as CSS custom
properties (`--color-primary`, `--radius-md`, `--shadow-lg`, …), and
everything else — modifiers, component themes, content themes — references
those variables, so changing the theme restyles the whole site consistently.

```swift
@main
struct MySite: Application {
    var theme: SiteTheme {
        var theme = SiteTheme.default
        theme.colors.primary = .indigo(600)
        theme.radii = ThemeRadii(sm: 2, md: 6, lg: 10, xl: 14, twoXL: 20, full: 9999)
        return theme
    }
}
```

### Custom tokens

Add your own CSS custom properties with ``ThemeToken``:

```swift
theme.tokens = [
    ThemeToken("--header-height", "4rem"),
    ThemeToken("--content-width", "42rem"),
]
```

Token names and values are sanitised on emission — a token contributes
exactly one declaration and can never inject further CSS.

### Dark mode and named themes

Set ``SiteTheme/darkColors`` to opt in to dark mode; Score emits both a
`prefers-color-scheme` media query and a `[data-theme="dark"]` attribute
variant for manual toggles. ``SiteTheme/customThemes`` adds further named
palettes selectable via `data-theme="<name>"`.

## Colour palettes

``ThemePalette`` pairs a light and dark ``ThemeColors`` built from the
built-in colour scales (the full Tailwind-style scales on `Color`, e.g.
`.indigo(600)`).

**Hue palettes** are named after their primary colour:
`.violet` (default), `.indigo`, `.blue`, `.emerald`, `.teal`, `.rose`, `.mono`.

**Thematic palettes** are named after a mood and combine multiple scales —
distinct primary and accent hues, a `tint` scale that washes the secondary
and tertiary surfaces with colour, and warm (`stone`) or cool (`slate`,
`zinc`) neutrals:

| Palette | Primary | Accent | Surface wash | Neutrals |
| --- | --- | --- | --- | --- |
| `.ocean` | blue | teal | sky | slate |
| `.forest` | emerald | amber | emerald | stone |
| `.sunset` | orange | rose | amber | stone |
| `.midnight` | indigo | violet | indigo | slate |
| `.berry` | fuchsia | pink | pink | zinc |
| `.ember` | red | orange | orange | stone |
| `.citrus` | lime | amber | lime | stone |

Build your own from any scale functions:

```swift
let custom = ThemePalette(
    primary: Color.purple,
    accent: Color.lime,
    tint: Color.pink,        // optional surface wash
    neutral: Color.zinc
)
```

Apply a palette directly (`theme.colors = ThemePalette.ocean.light`;
`theme.darkColors = ThemePalette.ocean.dark`) or feed it to a preset. Every
palette includes its dark variant — presets apply both automatically.

## Whole-theme presets

``ThemePreset`` configures radii, shadows, and component styles while
inheriting whichever palette you pair it with:

```swift
var theme: SiteTheme { .preset(.modern, palette: .indigo) }
var theme: SiteTheme { .preset(.neoBrutalism, palette: .ember) }
```

- `.minimal` — hairline shadows, small radii, quiet/plain components.
- `.modern` — generous radii, layered soft shadows, blurred dialog backdrops.
- `.soft` — extra-round corners, pill buttons, diffuse shadows.
- `.neoBrutalism` — square corners, thick black borders, hard offset
  shadows, bold type.

A preset returns an ordinary ``SiteTheme`` — adjust any property afterwards,
including per-component overrides (see <doc:ComponentTheming>).

> Important: There is intentionally no raw `customCSS`/`customJS`/`customHTML`
> escape hatch while Score is dogfooded pre-launch. All theme strings are
> sanitised to a single CSS declaration value.
