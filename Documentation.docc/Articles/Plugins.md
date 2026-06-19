# Plugins

Extend Score with official first-party integrations or build your own plugin as a Swift package.

## Overview

Every Score plugin is a Swift package. Add it as a dependency in `Package.swift`,
import the module, and configure it through the `Application` protocol — the
same interface used for the built-in database and cache. Plugins ship separately
so you only pull in what your project needs.

## Official Plugins

| Plugin           | Package                   | Description                                  |
| ---------------- | ------------------------- | -------------------------------------------- |
| Postgres         | `ScorePostgres`           | `ScoreData` PostgreSQL driver                |
| Redis            | `ScoreRedis`              | `ScoreData` Redis cache driver               |
| Lucide Icons     | `ScoreLucide`             | Type-safe SVG icon library for Score views   |
| Revolut Payments | `ScoreRevolut`            | Revolut payment element for checkout flows   |

## Adding a Plugin

Add the plugin package alongside Score in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mac95sb/score",          branch: "main"),
    .package(url: "https://github.com/mac95sb/score-postgres", branch: "main"),
],
targets: [
    .executableTarget(
        name: "MyApp",
        dependencies: [
            .product(name: "Score",         package: "score"),
            .product(name: "ScorePostgres", package: "score-postgres"),
        ]
    ),
]
```

Then import the module and configure the plugin on `Application`:

```swift
import Score
import ScorePostgres

@main
struct MyApp: Application {
    var database: some DatabaseConfig {
        PostgreSQLDatabase(url: Env.required("DATABASE_URL"))
    }
}
```

Plugin configuration always flows through `Application` protocol requirements
(`database`, `cache`, etc.), so switching between adapters is a one-line change.

## Writing a Custom Plugin

A Score plugin is a Swift package that extends `Application` via protocol
extensions and exposes new elements, modifiers, middleware, or route helpers.

Custom plugins follow the same conventions as official ones:

- No `customCSS`, `customJS`, or `customHTML` escape hatches
- New UI primitives must be expressible through `SiteTheme`/`ComponentTheme` structured APIs
- All HTML output must pass through `htmlEscape`/`attributeEscape`
- Middleware must conform to the `Middleware` protocol

Distribute your plugin as an open Swift package and reference it in
`Package.swift` the same way as any official plugin.
