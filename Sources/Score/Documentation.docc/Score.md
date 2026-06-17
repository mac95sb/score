# ``Score``

A Swift-first full-stack web framework.

## Overview

Score lets you describe web content, layout, and behaviour in Swift using a
SwiftUI-like result-builder DSL. It renders to vanilla HTML, CSS, and JavaScript.

> Important: Score is pre-release. APIs may change before v1. Raw HTML, CSS,
> and JavaScript escape hatches are intentionally absent — everything flows
> through Score's structured APIs. If your use case cannot be expressed through
> the structured API, open an issue describing it.

```swift
struct ArticleCard: View {
    let post: ContentPost
    @State var saved: Bool = false

    @Action func toggleSaved() { saved.toggle() }

    var body: some View {
        VStack {
            Heading(3) {
                post.frontmatter.title
            }
            Text {
                post.frontmatter.excerpt ?? ""
            }
            .font(color: .muted)
            Button(.ghost, action: toggleSaved) {
                saved ? "Saved" : "Save"
            }
        }
        .padding(6)
        .border(radius: .lg)
        .on(.hover) { $0.shadow(.md).translate(y: .px(-2)) }
        .animate(.all, duration: 150.ms)
    }
}
```

Pages and components are Swift structs. Modifiers emit scoped CSS. State
annotations emit minimal vanilla JavaScript. The result is standard, readable
HTML, CSS, and JS — deployable to any static host or run as a NIO server.

## Topics

### Get Started

- <doc:GettingStarted>

### Tutorials

- <doc:BuildingYourFirstApp>
- <doc:AddingABlog>

### Core Concepts

- <doc:ViewHierarchy>
- <doc:ModifierSystem>
- <doc:ThemeAndTokens>
- <doc:ComponentTheming>
- <doc:RichTextContent>

### Building Applications

- <doc:ReactiveState>
- <doc:DataLayer>
- <doc:APIRoutes>

### Community

- <doc:Showcase>
