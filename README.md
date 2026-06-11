# Score

A Swift-first full-stack web framework. Describe web content, layout, and
behaviour entirely in Swift — Score renders vanilla HTML, CSS, and JavaScript
with no WASM and no JS build step.

## Quick start

```bash
git clone https://github.com/mac95sb/score.git && cd score
swift build -c release            # builds the `score` CLI
score new MySite
cd MySite
score dev                          # → http://localhost:8080, hot-reload
```

## Building an app — the full flow

### 1. Create a project

```bash
score new MySite                   # --template default | static | minimal
```

This scaffolds a ready-to-run package:

```
MySite/
├── Package.swift          # depends on Score
├── Makefile               # common tasks (see below)
├── Sources/MySite/
│   └── App.swift          # @main Application with routes
├── Content/               # markdown content
└── Public/                # static assets, copied verbatim
```

### 2. Pages and routes

Your `@main` type conforms to `Application` and declares metadata, theme,
and routes:

```swift
@main
struct MySiteApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(title: "MySite", baseURL: "https://mysite.com")
    }

    var theme: SiteTheme { .preset(.modern, palette: .indigo) }

    @RouteBuilder
    var routes: some RouteCollection {
        Page(path: "/", page: HomePage())
    }
}

struct HomePage: Page {
    var body: some View {
        Main {
            Heading(1) { "Welcome" }
            Text { "Built with Score." }
        }
    }
}
```

Scaffold new pieces with `score generate page|component|action|record|middleware <Name>`.

### 3. Data — records and controllers

`Record` types map to SQLite tables; `RouteCollection` controllers expose
them as API routes (under `/api/v1` by default):

```swift
struct Post: Record {
    var id: UUID = UUID()
    var title: String
    var published: Bool = false
    var createdAt: Date = .now
    var updatedAt: Date = .now
}

struct PostsController: RouteCollection {
    var routes: [Route] {
        [
            Route(method: .GET,  pathPattern: "/posts",     handler: list),
            Route(method: .GET,  pathPattern: "/posts/:id", handler: show),
            Route(method: .POST, pathPattern: "/posts",     handler: create),
        ]
    }
}
```

### 4. Content

Drop markdown files in `Content/` and render them with `RichText`; style the
output via `ContentTheme`. Raw HTML in markdown is escaped, and link URLs are
restricted to safe schemes.

### 5. Theme it

One line gets a complete design system — palette, dark mode, component
styles:

```swift
var theme: SiteTheme { .preset(.soft, palette: .ocean) }
```

See [Component theming](#component-theming) below for variants, overrides,
and the palette catalogue.

### 6. Develop, build, preview

```bash
score dev          # hot-reload dev server
score build        # static build → .score/build/ (minified, fingerprinted)
score preview      # serve the static build exactly as a CDN would
```

### 7. Go native

```bash
score package windows|android|linux   # WebView shells (see Native packaging)
score package swiftui                 # Records + API client for SwiftUI apps
```

### Makefile

Every scaffolded project ships with a `Makefile` wrapping all of the above:

```bash
make dev / build / preview / test / lint / routes
make package-windows / package-android / package-linux / package-swiftui
make clean / help
```

## CLI reference

| Command | Purpose |
| --- | --- |
| `score new <Name>` | Scaffold a project (`--template default\|static\|minimal`) |
| `score dev` | Dev server with hot-reload (regenerates SwiftUI kits) |
| `score build` | Static build to `.score/build/` |
| `score preview` | Serve the static build locally |
| `score generate <type> <Name>` | Boilerplate: page, component, action, record, middleware |
| `score routes` | Print the route table |
| `score lint` | Lint Score views (`--json` for machine output) |
| `score translations` | Extract / validate / generate i18n keys |
| `score package <platform>` | Native shells + SwiftUI kit export |

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

### Conflicts with modifiers

Per-usage modifiers always beat theme defaults. Component-theme rules are
emitted as zero-specificity `:where()` selectors and placed before the
collected modifier CSS, so this works exactly as you'd expect:

```swift
theme.components.button = .default            // theme says padding: 0.5rem 1rem
// …
Button(.primary) { "Save" }.padding(8)        // this button gets padding 32px
```

The theme provides the baseline; any modifier on the element wins on both
specificity and source order — no `!important`, ever.

### Palettes and presets

Coordinated light + dark palettes built from the built-in colour scales, and
whole-theme presets that configure radii, shadows, and component styles while
inheriting whichever palette you pick:

```swift
var theme: SiteTheme { .preset(.modern, palette: .indigo) }
var theme: SiteTheme { .preset(.neoBrutalism, palette: .emerald) }
var theme: SiteTheme { .preset(.minimal, palette: .mono) }
var theme: SiteTheme { .preset(.soft, palette: .rose) }
```

Hue palettes: `.violet` (default), `.indigo`, `.blue`, `.emerald`, `.teal`,
`.rose`, `.mono`. Thematic palettes combine multiple scales — distinct
primary/accent hues, a colour-washed surface tint, and warm or cool neutrals:
`.ocean`, `.forest`, `.sunset`, `.midnight`, `.berry`, `.ember`, `.citrus`.
Or build your own:
`ThemePalette(primary: Color.purple, accent: Color.lime, tint: Color.pink)`.
Every palette includes a matching dark variant, applied automatically.

Presets: `.minimal` (hairline shadows, quiet components), `.modern` (soft
layered shadows, generous radii, blurred dialog backdrops), `.soft`
(extra-round, pill buttons), `.neoBrutalism` (square corners, thick black
borders, hard offset shadows, bold type). A preset is just a configured
`SiteTheme` — tweak anything afterwards.

## Native packaging

```bash
score package windows    # WebView2 shell (C# / .NET 8) — cross-compile via `make container-build`
score package android    # WebView shell (Kotlin / Gradle)
score package linux      # WebKitGTK shell (C / make)  — container build available
score package swiftui    # Records + typed API client as a library target in this package
```

WebView shells bundle your static export (`score build`) or point at a
deployed URL (`--url`). Windows and Linux projects include a `Containerfile`
and `make container-build`, which defaults to `container` (apple/container)
and also works with `docker` or `podman` (`--container-tool` sets the
default; `CONTAINER=<tool>` overrides per invocation).

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
