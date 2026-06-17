# Agent & contributor guidance

## Build and test

```bash
swift build            # build all targets
swift test             # run the full test suite (swift-testing, @Suite/@Test)
swift format --recursive Sources Tests          # format
swift format lint --recursive Sources Tests     # check formatting (CI gate)
```

The package requires Swift 6 / macOS 15 (Linux is supported; SQLite via
`libsqlite3-dev`).

## Project layout

- `Sources/ScoreCore` — views, elements, modifiers, theme system (incl. `ComponentTheme`)
- `Sources/ScoreHTTP` / `ScoreRouter` / `ScoreData` / `ScoreSSG` / `ScoreBuild` — server, routing, ORM, SSG, asset pipeline
- `Sources/ScorePackaging` — native WebView shell generators and the SwiftUI kit exporter
- `Sources/ScoreCLI` — the `score` executable (ArgumentParser + Noora for terminal UI)

## Adding a new element, modifier, or feature

Follow these steps for every addition to the public API — agents and contributors
alike:

1. **Implementation** — add to the appropriate `Sources/ScoreCore/` subdirectory
   (elements in `Elements/`, modifiers in `Modifiers/`, etc.).

2. **DocC comments** — every public type, property, and method needs a doc
   comment. Non-trivial APIs must include a usage code block so that DocC can
   render it as a live example. See existing elements for the expected style.

3. **Sources/Score/Documentation.docc article** — if the feature touches a documented system
   (modifiers, theming, state, routing, data, animation), update the relevant
   article in `Sources/Score/Documentation.docc/Articles/`. New systems get a new article.

4. **Kitchen-sink demo** — add a section or live example to
   `Templates/kitchen-sink/Sources/Application.swift`. The kitchen-sink is the
   primary smoke test and visual changelog. If it is not in the kitchen-sink,
   it does not exist for practical purposes.

5. **Tests** — add tests in `Tests/ScoreCoreTests/` covering CSS emission and
   any behaviour guarantees. See `ComponentThemeTests.swift` for the style.

## CSS pipeline (dev vs. production)

**Dev mode** (`score dev`): styles are injected as inline `<style>` tags on
every request. This is intentional — no caching concern, instant hot-reload,
no separate file-serving endpoint needed.

**Production static build** (`score build`): the infrastructure for external
CSS files already exists (`StyleCollector`, `CSSBundleSplitter`,
`AssetFingerprinter` in `Sources/ScoreBuild/`) but is not yet wired up in
`ApplicationMain.build()`. Currently the build output also uses inline `<style>`
tags. Wiring up fingerprinted `styles.css` output is a pre-launch task.

## Conventions

- CLI output goes through **Noora** (`ui.success/info/warning/error`,
  `ui.progressStep` spinners) — never bare `print`. The only exceptions are
  machine-readable data written to stdout (e.g. `score lint --json`, the
  `score routes` table).
- Generated-code templates live next to their generators as Swift string
  literals; keep generated output deterministic (sort dictionary keys).

## Theming architecture

All theming lives in `Sources/ScoreCore/Theme/`:

- `SiteTheme.swift` — `SiteTheme` (colors, fonts, spacing, radii, shadows,
  breakpoints, tokens, `darkColors`, `customThemes`) and its CSS-variable
  emission (`cssVariables()`). Custom `ThemeToken`s are sanitised on emission.
- `ComponentTheme.swift` — opt-in default styles for Button/Link/Dialog/
  Input/Badge with presets, design knobs, and structured `overrides` /
  `variantOverrides` dictionaries. Defaults to `.none` (no CSS emitted).
- `ThemePresets.swift` — `ThemePalette` (light+dark `ThemeColors` pairs built
  from the colour scales in `Color/ColorPalette.swift`) and `ThemePreset`
  (`.minimal`, `.modern`, `.soft`, `.neoBrutalism`) with the
  `SiteTheme.preset(_:palette:)` factory.
- `ContentTheme.swift` — markdown content styling (closure-based wrappers).

Rules when extending:

- **Palettes**: hue palettes are named after their primary colour; thematic
  palettes are named after a mood and combine multiple scales (primary +
  accent hues, a `tint` scale that washes secondary/tertiary surfaces, warm
  `stone` or cool `slate`/`zinc` neutrals). Every palette must provide a dark
  variant. Add new ones in `ThemePresets.swift` and list them in `README.md`
  and `Sources/Score/Documentation.docc`.
- **Presets**: a preset configures radii, shadows, and `components`, and must
  inherit whatever palette it is given (never hard-code colours other than
  true black/white accents like neo-brutalism borders). Presets must enable
  component styles and remain fully tweakable afterwards.
- **Component CSS**: all rules zero-specificity via `:where()` and emitted
  before collected modifier CSS, so per-usage modifiers always win. All
  values/properties route through `cssValueSanitize`/`cssPropertySanitize`
  (single choke point: `mergeDeclarations`). Output must be deterministic.
- `SiteTheme.default` must stay visually unchanged: `components` defaults to
  `.none` so existing sites opt in explicitly.

Tests live in `Tests/ScoreCoreTests/ComponentThemeTests.swift` and
`ThemePresetTests.swift` (including the zero-specificity and sanitisation
guarantees — keep those green when touching emission).

## Pre-launch constraints (do not violate)

Score is being dogfooded ahead of launch. The following features are
**deliberately absent** and **must not be implemented until launch**:

- **`customCSS`** — raw CSS string escape hatches, anywhere (this was removed
  from `ComponentTheme` on purpose; do not reintroduce it)
- **`customJS`** — raw JavaScript injection APIs
- **`customHTML`** — raw HTML injection APIs (e.g. `RawHTML`/`innerHTML`-style
  views)

Styling must be expressible through `SiteTheme`/`ComponentTheme`/`ContentTheme`
and the structured `overrides` dictionaries; behaviour through Score's element
and state APIs. If a task seems to require one of these escape hatches, treat
it as a framework gap: extend the structured API instead, or flag it — do not
add a raw passthrough.

Two invariants enforce this in code — preserve them:

- Theme strings (token values, override values, colour/padding knobs) pass
  through `cssValueSanitize`/`cssPropertySanitize` so a value can never escape
  its CSS declaration (`{`, `}`, `;` are stripped). Route any new raw-string
  CSS emission through these helpers.
- Markdown link URLs go through `RichText.isSafeLinkURL` (http/https/mailto/
  tel/relative only); `javascript:`/`data:` URLs render as plain text. All
  other HTML output is escaped via `htmlEscape`/`attributeEscape`.

Component-theme CSS must stay zero-specificity (`:where()` selectors) so
per-usage modifiers always win over theme defaults.
