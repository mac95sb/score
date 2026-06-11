# Component Theming

Opt-in default styles for built-in components, configured entirely in your
theme.

## Overview

Score's interactive elements — ``Button``, ``Link``, ``Dialog``, ``Input``,
and ``Badge`` — render as semantic HTML with no styling by default. Default
styles live on ``SiteTheme/components`` as a ``ComponentTheme``, mirroring how
``ContentTheme`` styles markdown content: enable defaults per component type,
pick a variation, and override individual declarations in place.

Every generated rule references the theme's CSS custom properties
(`--color-primary`, `--radius-md`, …), so component styles automatically
follow your ``ThemeColors``, ``ThemeRadii``, and dark-mode palettes.

### Default appearance

With the default ``ComponentTheme/none`` nothing is emitted. Once enabled,
each ``ButtonVariant`` gets a distinct look (primary/destructive filled with
their theme colours, secondary on the secondary colour, ghost/outline/icon
transparent), dialogs become elevated cards with a dimmed backdrop, links use
the accent colour with hover underlines, inputs gain borders and focus rings,
and badges render as small filled pills.

### Enabling components

```swift
var theme: SiteTheme {
    var theme = SiteTheme.default
    theme.components = .default                                  // everything
    // theme.components = ComponentTheme(button: .default)      // or selectively
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

### Overriding generated declarations

```swift
theme.components.button?.overrides["padding"] = "0.75rem 2rem"
theme.components.button?.variantOverrides[.primary] = [
    "background": "var(--color-accent)",
    "text-transform": "uppercase",
]
```

Override keys that match a generated declaration replace it inside the same
rule; new keys are appended — no specificity battles.

> Important: There is intentionally no raw `customCSS`, `customJS`, or
> `customHTML` escape hatch while Score is dogfooded pre-launch. Express
> styling through the structured overrides above.
