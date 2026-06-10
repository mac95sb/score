# View Hierarchy

Understand how Score's views compose into a full page tree.

## Overview

Score's view system mirrors SwiftUI's result-builder pattern. Every piece of
UI is a ``View`` — a Swift type with a `body` property that returns more views.
Score renders the tree to HTML at build time (static) or request time (server-rendered).

Nothing Swift runs in the browser. The output is standard HTML, CSS, and JS.

## The View Protocol

```swift
public protocol View: Sendable {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}
```

Conform any struct to ``View`` to make it a reusable component:

```swift
struct PricingCard: View {
    let plan: Plan

    var body: some View {
        VStack {
            Heading(3) { plan.name }
            Text { plan.price }.font(size: .threeXL).font(weight: .bold)
        }
        .padding(8)
        .border(radius: .xl)
    }
}
```

## String Literals as Views

String literals are valid ``View``s everywhere — no wrapper type needed:

```swift
Heading(1) { "Hello World" }
Heading(2) { "Welcome, \(user.name)" }
```

## Layout Elements

| Element | Renders to | Notes |
|---------|-----------|-------|
| ``Stack`` | `<div>` | Direction via `.flex()` |
| ``HStack`` | `<div>` | Horizontal flex shorthand |
| ``VStack`` | `<div>` | Vertical flex shorthand |
| ``ZStack`` | `<div>` | Absolutely-positioned children |
| ``Grid`` | `<div>` | CSS Grid shorthand |
| ``Spacer`` | `<div>` | Flexible space |
| ``Divider`` | `<hr>` | Horizontal or vertical |
| ``ScrollView`` | `<div>` | Scrollable container |

## Semantic Containers

Prefer semantic elements over generic ``Stack``s — screen readers and search
engines use them for navigation and context.

| Element | Renders to | Notes |
|---------|-----------|-------|
| ``Article`` | `<article>` | Self-contained content unit |
| ``Section`` | `<section>` | Thematic grouping |
| ``Header`` | `<header>` | Page or section header |
| ``Footer`` | `<footer>` | Page or section footer |
| ``Nav`` | `<nav>` | Navigation landmark |
| ``Main`` | `<main>` | Primary page content (one per page) |
| ``Aside`` | `<aside>` | Supplementary or sidebar content |

## Content Elements

```swift
Heading(1) { "Main title" }                      // <h1>–<h6>
Text { "A paragraph of text." }                  // <p> (block) or <span> (inline)
Code("let x = 42")                               // <code> inline
CodeBlock(language: .swift) { sourceCode }       // <pre><code> block
Blockquote { "A quoted passage." }               // <blockquote>
RichText(markdown: post.content)                 // parsed Markdown → Score views
```

``Text`` infers `<p>` for multi-sentence content and `<span>` for short inline
text. Prefer interpolating strings directly in parent closures over explicit
`Text {}` wrappers for simple labels.

## The Page Protocol

``Page`` extends ``View`` with metadata and an optional render mode:

```swift
struct BlogPostPage: Page {
    let post: Post

    var metadata: PageMetadata {
        PageMetadata(
            title: post.title,
            description: post.excerpt,
            ogType: .article,
            canonicalURL: "/blog/\(post.slug)"
        )
    }

    var body: some View { ... }
}
```

Score emits `<title>`, Open Graph tags, and canonical links from ``PageMetadata``
automatically.

## Iteration

Standard Swift `for` loops work inside `@ViewBuilder` closures:

```swift
VStack {
    for post in posts {
        ArticleCard(post: post)
    }
}
```

## Conditional Views

```swift
if isLoggedIn {
    DashboardView()
} else {
    LoginPrompt()
}
```

Conditions on `let` constants resolve at render time (zero JS emitted).
Conditions on `@State` properties emit data-attribute-driven DOM toggles.

## CSS Scoping

Score derives a CSS class from each ``View``'s Swift type name using kebab-case:
`ArticleCard` → `.article-card`. Output is standard, readable vanilla HTML:

```html
<div class="article-card">
  <h3>Post Title</h3>
  <p>Excerpt text.</p>
</div>
```

Child components (separate ``View`` structs) have their own CSS scope. A parent
cannot reach into a child's scope via modifiers — pass styling context as a
constructor parameter instead.

## Static vs Server-Rendered Pages

Routes returning a ``View`` are statically rendered at build time by default.
Override per route when dynamic content is needed:

```swift
GET("/dashboard", mode: .serverRendered) { req in
    DashboardPage(user: req.context.user!)
}
```

Available render modes: `.static`, `.serverRendered`,
`.incrementalStaticRegeneration(ttl:)`.

## Related Concepts

- <doc:ModifierSystem> — styling views
- <doc:ThemeAndTokens> — design tokens and themes
- <doc:ReactiveState> — `@State` and `@Binding`
