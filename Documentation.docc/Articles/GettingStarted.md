# Getting Started with Score

Create your first Score project and run it locally in under five minutes.

## Overview

Score projects are Swift packages. You create one with the `score new` CLI, then
run `score dev` to start a live-reloading development server.

> Note: Score requires Swift 6 (Xcode 16 or later, or the Swift 6 toolchain on
> Linux).

## Installation

### CLI (recommended)

Download the latest CLI binary directly to `~/.local/bin`:

```sh
curl -fsSL https://github.com/mac95sb/score/releases/latest/download/score \
  -o ~/.local/bin/score && chmod +x ~/.local/bin/score
score --version
```

> Note: Make sure `~/.local/bin` is on your `PATH`. Add
> `export PATH="$HOME/.local/bin:$PATH"` to your shell profile if needed.

### Manual (Swift Package Manager)

If you prefer to add Score as a library dependency without the CLI, add it to
your `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/mac95sb/score", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            dependencies: [
                .product(name: "Score", package: "score")
            ],
            path: "Sources"
        )
    ]
)
```

Then create `Sources/Application.swift` as your entry point:

```swift
import Score

@main
struct MyApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "My App",
            titleSeparator: " — ",
            description: "A site built with Score.",
            baseURL: "https://example.com"
        )
    }

    var theme: SiteTheme { .default }

    var routes: some RouteCollection {
        Page("/") { HomePage() }
    }
}
```

Run `swift run` to start the development server.

## Creating a Project

```sh
score new MyBlog --template default
cd MyBlog
score dev
```

Three scaffold templates are available:

| Template       | Description                                                              |
| -------------- | ------------------------------------------------------------------------ |
| `default`      | Full-featured app — pages, API routes, and Markdown content              |
| `static`       | Static site — Markdown content with no server-side logic                 |
| `kitchen-sink` | Examples of every Score element, modifier and feature in one application |

## Project Structure

The `default` template produces this layout:

```
MyBlog/
├── Package.swift
├── Sources/
│   ├── Models/             # Record-conforming data models
│   ├── Views/
│   │   ├── Pages/          # Page views rendered by routes
│   │   └── Components/     # Reusable view components
│   ├── Controllers/        # RouteCollection controllers
│   └── Application.swift   # Main entry point
├── Content/posts/          # Markdown content with YAML frontmatter
└── Public/                 # Static assets copied verbatim to the build output
```

## The Application Entry Point

Every Score app has an `@main` struct conforming to `Application`:

```swift
import Score

@main
struct MyBlog: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "My Blog",
            titleSeparator: " — ",
            description: "A blog about Swift.",
            baseURL: "https://myblog.com"
        )
    }

    var theme: SiteTheme { .default }

    var routes: some RouteCollection {
        PostsController()
    }

    var database: some DatabaseConfig {
        SQLiteDatabase(path: ".score/db.sqlite")
    }
}
```

## Your First Page

Pages conform to ``Page``, which extends ``View`` with metadata:

```swift
struct HomePage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home", description: "Welcome to My Blog.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Welcome to My Blog" }
                    .font(size: .fourXL, weight: .bold)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
```

## Development Server

```sh
score dev
```

- Watches `Sources/`, `Content/`, `Public/`, and `Localizable.xcstrings` for
  changes
- Rebuilds and restarts the server on any change
- Injects a Server-Sent Events live-reload script so the browser refreshes
  automatically

## Building for Production

```sh
score build
```

Output lands in `.score/build/`. Static sites produce HTML, CSS, and JS. Hybrid
apps also compile a self-contained NIO server binary at `.score/build/Server`.

## Next Steps

Work through the articles in this order to build a complete mental model of
Score:

1. <doc:ViewHierarchy> — how views compose into a full page tree
2. <doc:ModifierSystem> — styling with Score's complete CSS modifier API
3. <doc:ThemeAndTokens> — colours, typography, spacing, and dark mode
4. <doc:ComponentTheming> — opt-in default styles for built-in interactive
   elements
5. <doc:RichTextContent> — Markdown content, frontmatter, and content themes
6. <doc:ReactiveState> — `@State`, `@Binding`, and `@Action` for interactive
   components
7. <doc:DataLayer> — the ORM, query builder, and key-value cache
8. <doc:APIRoutes> — page routes, API endpoints, and middleware

The tutorials walk through the same progression hands-on: <doc:Score>.

Once your app is running, explore these topics when you're ready:

- <doc:CodeQuality> — linting, formatting, CI integration, and git hook wiring
- <doc:Plugins> — extending Score with official and custom Swift package plugins
- <doc:NativeApps> — packaging your Score site as a native macOS, iOS, Windows,
  Linux, or Android app, and sharing typed API contracts with a Swift client
