# Component Theming

Opt-in default styles for built-in components, configured entirely in your
theme.

## Overview

Score's interactive elements — ``Button``, ``Link``, ``Dialog``, ``Input``,
and ``Badge`` — render as semantic HTML with no styling by default. This keeps
them accessible and composable without imposing visual opinions. Opt-in styling
lives on ``SiteTheme/components`` as a ``ComponentTheme``: enable defaults per
component type and pick a variation. Every generated rule references the theme's
CSS custom properties (`--color-primary`, `--radius-md`, …), so component styles
automatically follow your ``ThemeColors``, ``ThemeRadii``, and dark-mode palettes.

### Default appearance

With the default ``ComponentTheme/none`` nothing is emitted for interactive
elements. Once enabled, each ``ButtonVariant`` gets a distinct look
(primary/destructive filled with their theme colours, secondary on the secondary
colour, ghost/outline/icon transparent), dialogs become elevated cards with a
dimmed backdrop, links use the accent colour with hover underlines, inputs gain
borders and focus rings, and badges render as small filled pills.

### Enable all component styles

To apply Score's default styling to every interactive element at once:

```swift
var theme: SiteTheme {
    var theme = SiteTheme.default
    theme.components = .default
    return theme
}
```

### Enable a subset of components

To enable styles for specific components only:

```swift
var theme: SiteTheme {
    var theme = SiteTheme.default
    theme.components = ComponentTheme(button: .default, input: .default)
    return theme
}
```

### Styling variations

```swift
theme.components.button = .pill                  // presets: .default, .pill, .compact
theme.components.button = ButtonTheme(size: .large, radius: .xl, fontWeight: 600)
theme.components.link   = .underlined            // presets: .default, .underlined, .plain
theme.components.dialog = DialogTheme(backdropBlur: 4)
theme.components.input  = .minimal
theme.components.badge  = .outline
```

### Conflicts with per-usage modifiers

Modifiers on a component instance always win over its theme defaults.
Component-theme rules are emitted as zero-specificity `:where()` selectors
(class-based modifier CSS is `0,1,0`; theme rules are `0,0,0`) and placed
before the collected modifier CSS, so both specificity and source order
resolve in the modifier's favour:

```swift
theme.components.button = .default      // theme baseline: padding 0.5rem 1rem
Button(.primary) { "Save" }.padding(8)  // this instance: padding 32px wins
```

### Palettes and presets

``ThemePalette`` pairs light and dark ``ThemeColors`` built from the built-in
colour scales — hue palettes (`.violet`, `.indigo`, …), thematic multi-scale
palettes (`.ocean`, `.sunset`, `.ember`, …), or
custom via `ThemePalette(primary:accent:tint:neutral:)`. ``ThemePreset``
(`.minimal`, `.modern`, `.soft`, `.neoBrutalism`) configures radii, shadows,
and component styles while inheriting the palette:

```swift
var theme: SiteTheme { .preset(.neoBrutalism, palette: .emerald) }
```

See <doc:ThemeAndTokens> for the full palette catalogue, custom tokens, and
dark-mode behaviour.

> Important: Score does not expose raw `customCSS`, `customJS`, or `customHTML`
> escape hatches. All styling flows through the structured overrides above.
> Theme strings are sanitised so a value cannot escape its CSS declaration, and
> markdown link URLs are restricted to safe schemes. If you find a gap that the
> structured API cannot cover, open an issue describing the use case.

## See Also

- <doc:ThemeAndTokens>
- <doc:ModifierSystem>
- <doc:ViewHierarchy>
