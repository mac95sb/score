# __NAME__

A Score web application.

## Project structure

- `Sources/Models/` — Record-conforming data models
- `Sources/Views/Pages/` — Page views rendered by routes
- `Sources/Views/Components/` — Reusable view components
- `Sources/Controllers/` — RouteCollection controllers (pages + API)
- `Sources/Application.swift` — App entry point and configuration
- `Content/posts/` — Markdown content files with YAML frontmatter
- `Public/` — Static assets copied verbatim to the build output

## Running locally

```bash
score dev
```

## Building for production

```bash
score build
```
