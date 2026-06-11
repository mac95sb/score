# Score

A Swift-first full-stack web framework. Describe web content, layout, and
behaviour entirely in Swift — Score renders vanilla HTML, CSS, and JavaScript
with no WASM and no JS build step.

## Quick start

```bash
score new MySite
cd MySite
score dev          # or: make dev
```

Every scaffolded project ships with a `Makefile` for the common tasks:

```bash
make dev               # dev server with hot-reload
make build             # static build to .score/build/
make preview           # serve the static build locally
make test              # swift test
make lint              # lint Score views
make package-windows   # native Windows WebView2 app
make package-android   # native Android WebView app
make package-linux     # native Linux WebKitGTK app
make package-swiftui   # export Records + API client for SwiftUI apps
```

## Component theming

Built-in components (Button, Link, Dialog, Input, Badge) ship unstyled by
default. Default styles are opt-in at the theme level via
`SiteTheme.components` — the same pattern as `ContentTheme` for markdown.

### 1. How components look by default

With `components` left at `.none` (the default), Score emits **no component
CSS** — a `Button(.primary) { "Save" }` renders as a bare
`<button data-variant="primary">` styled only by the browser and your own
styles. Once enabled, the defaults are token-driven: primary buttons fill with
`--color-primary`, destructive with `--color-destructive`, outline buttons get
a muted border, dialogs become elevated cards with a dimmed backdrop, links
take the accent colour and underline on hover, inputs get borders and focus
rings. Because every rule references your theme's CSS variables, dark mode and
custom palettes apply automatically.

### 2. How components are enabled

```swift
@main
struct MySite: Application {
    var theme: SiteTheme {
        var theme = SiteTheme.default
        theme.components = .default        // all components, default styles
        return theme
    }
}
```

Or enable only what you need — anything left `nil` emits nothing:

```swift
theme.components = ComponentTheme(button: .default, dialog: .default)
```

### 3. How component customisations are styled

Each component theme has presets and design knobs:

```swift
theme.components.button = .pill                      // capsule buttons
theme.components.button = ButtonTheme(size: .large, radius: .xl, fontWeight: 600)
theme.components.link   = .plain                     // inherit colour, no underline
theme.components.dialog = DialogTheme(backdropBlur: 4)
theme.components.input  = .minimal                   // borderless on secondary colour
theme.components.badge  = .outline
```

### 4. How components are overridden from their default theme-defined values

Every generated CSS declaration can be replaced (or extended) in place via the
structured `overrides` dictionaries — base-level and per-variant:

```swift
// Replace a generated declaration on the shared button rule:
theme.components.button?.overrides["padding"] = "0.75rem 2rem"

// Replace/extend declarations for a single variant:
theme.components.button?.variantOverrides[.primary] = [
    "background": "var(--color-accent)",   // replaces the default background
    "text-transform": "uppercase",         // appended as a new declaration
]
```

Overridden properties replace the generated value inside the same rule, so
specificity never fights you; unknown properties are appended.

## Native packaging

```bash
score package windows    # WebView2 shell (C# / .NET 8) — cross-compile via `make container-build`
score package android    # WebView shell (Kotlin / Gradle)
score package linux      # WebKitGTK shell (C / make)  — container build available
score package swiftui    # Records + typed API client as a library target in this package
```

WebView shells bundle your static export (`score build`) or point at a
deployed URL (`--url`). Windows and Linux projects include a `Containerfile`
and `make container-build`, which works with `docker`, `container`
(apple/container), or `podman` (`--container-tool` sets the default).

The SwiftUI export generates a library target **inside your app's package**
and regenerates on every `score dev` / `score build`, so native clients can
never drift from your records and routes.

## Pre-launch constraints (dogfooding)

While Score is being dogfooded ahead of launch, the following are
**intentionally not implemented** and must not be added until launch:

- `customCSS` — raw CSS escape hatches (in `ComponentTheme` or elsewhere)
- `customJS` — raw JavaScript injection
- `customHTML` — raw HTML injection

All styling goes through the theme system and structured override
dictionaries; all behaviour goes through Score's element and state APIs. This
keeps the dogfooding signal clean — if something can't be expressed without an
escape hatch, that's a framework gap to fix, not a hole to patch around.
See `AGENTS.md` for contributor/agent guidance.
