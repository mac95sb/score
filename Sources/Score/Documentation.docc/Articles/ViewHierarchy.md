# View Hierarchy

Understand how Score's views compose into a full page tree.

## Overview

Score's view system mirrors SwiftUI's result-builder pattern. Every piece of
UI is a ``View`` — a Swift type with a `body` property that returns more views.
Score renders the tree to HTML at build time (static) or request time
(server-rendered). The output is standard HTML, CSS, and JS.

## Layout Elements

| Element | Renders to | Notes |
|---------|-----------|-------|
| ``Stack`` | `<div>` | Direction via `.flex()` |
| ``HStack`` | `<div>` | Horizontal flex shorthand |
| ``VStack`` | `<div>` | Vertical flex shorthand |
| ``ZStack`` | `<div>` | Absolutely-positioned children |
| ``Grid`` | `<div>` | CSS Grid shorthand |
| ``Spacer`` | `<div>` | Flexible space |
| ``Divider`` | `<hr>` | Horizontal or vertical rule |
| ``ScrollView`` | `<div>` | Scrollable container |

### Layout and Alignment

`HStack` and `VStack` are direction shorthands — they pre-apply
`display: flex; flex-direction: row` (or `column`) but carry no alignment
defaults. Alignment, gap, wrapping, and justification are all modifier-driven:

```swift
HStack {
    Heading(2) { "Score" }
    Spacer()
    NavLinks()
}
.flex(align: .center, justify: .spaceBetween, gap: 4)
```

Use `Stack` when the flex direction needs to change at a breakpoint:

```swift
Stack {
    SidePanel()
    MainContent()
}
.flex(direction: .horizontal, gap: 8)
.flex(direction: .vertical, gap: 4, at: .phone)
```

`Grid` pre-applies `display: grid`; column count and gap are set via
`.grid(columns:gap:)`:

```swift
Grid {
    for card in cards { FeatureCard(card: card) }
}
.grid(columns: 3, gap: 6)
```

## Semantic Containers

Prefer semantic elements over a generic ``Stack`` — screen readers and search
engines use semantic elements for navigation and context.

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

| Element | Renders to | Notes |
|---------|-----------|-------|
| ``Heading`` | `<h1>`–`<h6>` | Level 1–6 as first argument |
| ``Text`` | `<p>` or `<span>` | Infers block vs inline from context |
| ``Code`` | `<code>` | Inline code fragment |
| ``CodeBlock`` | `<pre><code>` | Fenced block with optional language |
| ``Blockquote`` | `<blockquote>` | Block quotation |
| ``RichText`` | parsed HTML | Markdown string rendered as Score views |

``Text`` infers `<p>` for multi-sentence content and `<span>` for short inline
text. Prefer interpolating strings directly in parent closures over explicit
`Text {}` wrappers for simple labels.

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
            Text { plan.price }
                .font(size: .threeXL, weight: .bold)
        }
        .padding(8)
        .border(radius: .xl)
    }
}
```

## String Literals as Views

String literals are a valid ``View`` type — use them anywhere a view is expected:

```swift
Heading(1) { "Hello World" }
Heading(2) { "Welcome, \(user.name)" }
```

## CSS Scoping

Score derives a CSS class from each ``View``'s Swift type name using kebab-case:
`ArticleCard` → `.article-card`. Output is standard, readable vanilla HTML:

```html
<div class="article-card">
  <h3>Post Title</h3>
  <p>Excerpt text.</p>
</div>
```

Child components (separate ``View`` structs) have their own CSS scope. Pass
styling context as a constructor parameter — see Passing Styling Context below.

## Passing Styling Context to Child Components

A parent cannot reach into a child's CSS scope through modifiers. When a child
needs styling information from its caller, pass it as a constructor parameter:

```swift
struct CalloutCard: View {
    enum Style { case info, warning, success }

    let style: Style
    let title: String

    private var accentColor: Color {
        switch style {
        case .info:    return .primary
        case .warning: return .accent
        case .success: return Color.emerald(500)
        }
    }

    var body: some View {
        VStack {
            Heading(4) { title }
                .font(color: accentColor)
        }
        .border(color: accentColor, width: 2, radius: .lg)
        .padding(5)
    }
}

CalloutCard(style: .warning, title: "Heads up")
```

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

Conditions on `let` constants resolve at render time — no JavaScript emitted.
Conditions on `@State` properties emit data-attribute-driven DOM toggles.

## Accessing Component Data in Body

Access struct properties directly — Swift's dot syntax is concise enough that
intermediate variable bindings rarely help:

```swift
var body: some View {
    VStack {
        Text { author.name }.font(weight: .semibold)
        Text { author.bio }.font(color: .muted)
    }
}
```

When the same derived value appears in multiple places, bind it once at the top
of `body`:

```swift
var body: some View {
    let (name, bio) = (author.name, author.bio)
    return VStack {
        Text { name }.font(weight: .semibold)
        Text { bio }.font(color: .muted)
    }
}
```

## The Page Protocol

``Page`` extends ``View`` with metadata and an optional render mode:

```swift
struct BlogPostPage: Page {
    let post: Post

    var metadata: PageMetadata? {
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

## See Also

- <doc:ModifierSystem>
- <doc:ThemeAndTokens>
- <doc:RichTextContent>
