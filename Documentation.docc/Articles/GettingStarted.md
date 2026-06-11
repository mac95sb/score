# Getting Started with Score

Create your first Score project and run it locally in under five minutes.

## Overview

Score projects are Swift packages. You create one with the `score new` CLI,
then run `score dev` to start a live-reloading development server.

> Note: Score requires Swift 6 (Xcode 16 or later, or the Swift 6 toolchain on Linux).

## Installation

Download the latest CLI binary directly to `~/.local/bin`:

```bash
curl -fsSL https://github.com/mac95sb/score/releases/latest/download/score \
  -o ~/.local/bin/score && chmod +x ~/.local/bin/score
score --version
```

> Note: Make sure `~/.local/bin` is on your `PATH`. Add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile if needed.

## Creating a Project

```bash
score new MyBlog --template default
cd MyBlog
score dev
```

Two templates are available:

| Template | Description |
|----------|-------------|
| `default` | Full-featured app — pages, API routes, and Markdown content |
| `static` | Static site — Markdown content with no server-side logic |

## Project Structure

The `default` template produces this layout:

```
MyBlog/
├── Package.swift
├── Sources/
│   ├── Models/          Record-conforming data models
│   ├── Views/
│   │   ├── Pages/       Page views rendered by routes
│   │   └── Components/  Reusable view components
│   ├── Controllers/     RouteCollection controllers
│   └── Application.swift
├── Content/posts/       Markdown content with YAML frontmatter
└── Public/              Static assets copied verbatim to the build output
```

## The Application Entry Point

Every Score app has an `@main` struct conforming to ``Application``:

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

```bash
score dev
```

- Watches `Sources/`, `Content/`, `Public/`, and `Localizable.xcstrings` for changes
- Rebuilds and restarts the server on any change
- Injects a Server-Sent Events live-reload script so the browser refreshes automatically

## Building for Production

```bash
score build
```

Output lands in `.score/build/`. Static sites produce HTML, CSS, and JS.
Hybrid apps also compile a self-contained NIO server binary at `.score/build/Server`.

## Next Steps

- <doc:ViewHierarchy> — learn how views compose
- <doc:ThemeAndTokens> — colours, typography, and spacing
- <doc:ModifierSystem> — styling with Score's modifier API
