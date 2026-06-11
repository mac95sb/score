# ``Score``

A Swift-first full-stack web framework.

## Overview

Score lets you describe web content, layout, and behaviour in Swift using a
SwiftUI-like result-builder DSL. It renders to vanilla HTML, CSS, and
JavaScript — no WASM, no transpilation. Swift is the authoring language;
the browser receives standard web-platform output.

```swift
struct ArticleCard: View {
    let post: ContentPost
    var body: some View {
        VStack {
            Heading(3) { post.frontmatter.title }
            Text { post.frontmatter.excerpt ?? "" }.font(color: .muted)
        }
        .padding(6)
        .border(radius: .lg)
        .on(.hover) { $0.shadow(.md).translate(y: .px(-2)) }
        .animate(.all, duration: 150.ms)
    }
}
```

## Topics

### Getting Started
- <doc:GettingStarted>

### Core Concepts
- <doc:ViewHierarchy>
- <doc:ThemeAndTokens>
- <doc:ComponentTheming>
- <doc:ModifierSystem>

### Building Applications
- <doc:ReactiveState>
- <doc:DataLayer>
- <doc:APIRoutes>

### Community
- <doc:Showcase>
