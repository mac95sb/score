# Agent & contributor guidance

## Build and test

```bash
swift build            # build all targets
swift test             # run the full test suite (swift-testing, @Suite/@Test)
```

The package requires Swift 6 / macOS 15 (Linux is supported; SQLite via
`libsqlite3-dev`).

## Project layout

- `Sources/ScoreCore` — views, elements, modifiers, theme system (incl. `ComponentTheme`)
- `Sources/ScoreHTTP` / `ScoreRouter` / `ScoreData` / `ScoreSSG` / `ScoreBuild` — server, routing, ORM, SSG, asset pipeline
- `Sources/ScorePackaging` — native WebView shell generators and the SwiftUI kit exporter
- `Sources/ScoreCLI` — the `score` executable (ArgumentParser + Noora for terminal UI)

## Conventions

- CLI output goes through **Noora** (`ui.success/info/warning/error`,
  `ui.progressStep` spinners) — never bare `print`. The only exceptions are
  machine-readable data written to stdout (e.g. `score lint --json`, the
  `score routes` table).
- Generated-code templates live next to their generators as Swift string
  literals; keep generated output deterministic (sort dictionary keys).

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
