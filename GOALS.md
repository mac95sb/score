# Score Improvement Goals

## 1. Documentation structure and consistency

### Standardize article format

- [x] Use natural documentation prose throughout all DocC articles.
- [x] Use code blocks only for actual examples, not explanatory instructions.
- [x] Replace mixed code-comment patterns with consistent tables.
- [x] Avoid phrases like "the developer does this"; prefer direct instructional
  language such as "To declare state…".
- [x] Remove repeated "Nothing Swift runs in the browser. No WASM." statements.

### Standardize tables

Use consistent table formats:

For elements:

```text
Element | Renders to | Notes
```

For modifiers:

```text
Modifier | Purpose
```

Apply this to:

- [x] `ViewHierarchy.md`
- [x] `ModifierSystem.md`
- [x] `ThemeAndTokens.md`
- [x] all other `Sources/Score/Documentation.docc/Articles/*` where relevant.

### Rework navigation and related links

- [x] Reorder View Hierarchy as:

  1. Elements
  2. Components
  3. Pages
- [x] Review all article footer sections.
- [x] Avoid duplication between "Related Documentation" and "Core Concepts".

## 2. Pre-release positioning

### Add one clear pre-release callout

- [x] Add near the top of `Score.md`:
  - Score is currently pre-release.
  - Until v1, escape hatches are intentionally not included.
  - Missing use cases should be filed as issues.

### Remove escape-hatch documentation

- [x] Remove `ComponentTheming.md#Overriding-generated-declarations`
- [x] Review related source support for any remaining unsupported escape hatches.

## 3. Elements, modifiers, sizing, and layout

### Elements

- [x] Convert content element docs to linked tables.
- [x] Include links to relevant symbol pages.

### Modifier system

- [x] Convert each modifier category into tables.
- [x] Briefly document params in the article.
- [x] Link modifier names to full symbol docs.

### Size values

- [x] Dedicated section for reusable size values exists in `ModifierSystem.md`.
- [x] Table of available values present in `ThemeAndTokens.md`.
- [x] Examples showing usage across modifiers included.

### Layout API decision

- [x] Resolve whether alignment belongs in params (`HStack(align: .center)`) or
  modifiers (`.flex(align: .center)`), then update `HStack`, `VStack`, `ZStack`,
  `Grid`, docs and examples. If modifier-driven, consider simplifying to `Stack`.

## 4. Themes, tokens, palettes, and presets

### Themes and tokens article

- [x] Replace instructional code blocks with prose, tables, and concise examples.
- [x] Spacing and font size tables present.
- [x] One clear example of theme definition.

### Palette documentation

- [x] Document the full palette with a complete hue × shade table.
- [x] Show custom color scales.

### Presets vs palettes

- [x] Renamed "Developer Theme Presets" → "Colour Schemes".
- [x] Clarify distinction between hue palettes, thematic palettes, and component presets in a dedicated section.

### Component theming

- [x] Clarified that components render semantic HTML and styling is optional.
- [x] Split "Enabling components" into "Enable all" and "Enable a subset".

### Fonts

- [x] `supplementaryURLs` for remote fonts is documented in `ThemeAndTokens.md`.
  Score emits `preconnect` for each supplementary URL and `stylesheet` for the
  main URL. URL type is a plain `String` — no further configurability needed.

## 5. Reactive state and input APIs

### ReactiveState.md

- [x] Remove over-explained code comments.
- [x] Fixed "Two Tiers, One Syntax" — removed "The developer never annotates it."
- [x] Replaced bad client-action example with a UI-only counter.
- [x] No longer uses examples where data mutation implies server sync.

### Input binding

- [x] Removed `.bind(to: $query)` from docs — replaced with `value: $query`.
- [x] Added `Binding<String>` overload to `Input` initializer in source.
- [x] Check tutorials and test snippets for remaining `.bind(to:)` usage.

### Rich text theme

- [x] `.erased()` is required in custom `ContentTheme` closures — the closure
  receives `any View` and `.erased()` converts it to `AnyView` so modifiers
  can be chained on the existential. Kept in examples with an explanatory comment
  in `RichTextContent.md`.

## 6. Data layer and content

### DataLayer.md

- [x] Updated opening paragraph — removed "raw SQL escape hatch" language.
- [x] PostgreSQL and Redis plugin docs with GitHub URLs included.

### Content documentation

- [x] Added `ContentStore` configuration docs to `RichTextContent.md`.
- [x] Added `config:` parameter to `ContentStore` static methods in source.
- [x] Table of all `ContentStoreConfig` options documented.

## 7. Tooling and official plugins

### Add tooling/code-quality section

- [x] Added "Code Quality" section to `GettingStarted.md` covering:
  - `.swift-format`
  - `score lint`
  - CI usage
  - Git hooks

### Add official plugins section

- [x] Document how to add a plugin.
- [x] List and document official plugins once they are published:
  - Revolut Payments — https://developer.revolut.com/
  - Postgres
  - Redis
  - Lucide Icons — https://lucide.dev

## 8. Tutorials

### Sidebar

- [x] `Sources/Score/Documentation.docc/Tutorials/Score.tutorial` is the root
  tutorial file and appears first in the sidebar.

### Installation tutorial

- [x] Mention `~/.local/bin` must exist in `PATH`.
- [x] Split install step into: (1) curl binary, (2) chmod binary.

### Tutorial path restructure

- [x] Rename current static tutorial to "Create a Static Site".
- [x] Add "Create a Full Stack Application" tutorial.

### Tutorial examples

- [x] Ensure all examples reflect current Score APIs.
- [x] Show more surrounding code.
- [x] Use DocC Swift snippet syntax to highlight changed lines.
- [x] Add missing code in "Define a Page".
- [x] Add note to create a `Link` between pages.

## 9. Code quality and API review

- [x] Run a full review across `Sources/` and `Sources/Score/Documentation.docc/`
  for: idiomatic Swift, API Design Guidelines compliance, docs matching real
  source APIs, stale examples, consistent naming, source/doc drift.

## 10. New Features

- [x] Configurable `robots.txt` — `RobotsTxt` struct added to `ScoreCore`.
  `Application` gains a `robotsTxt: RobotsTxt` property (default: `.default`,
  which allows all paths). The build pipeline writes `robots.txt` to the output
  directory automatically.
