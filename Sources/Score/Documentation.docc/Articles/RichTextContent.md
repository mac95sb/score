# Rich Text and Content Rendering

Render Markdown content, apply per-element styling, and compose prose pages.

## Overview

Score provides first-class support for Markdown-based content through
``RichText`` and a flexible ``ContentTheme`` system. This is the primary
path for blog posts, documentation pages, and any content authored outside
Swift source files — typically stored as `.md` files in the `Content/`
directory.

## RichText

``RichText`` takes a Markdown string and renders it to HTML using Score's
built-in parser, which handles headings, paragraphs, lists, blockquotes,
fenced code blocks, inline formatting, and links:

```swift
RichText(markdown: post.content)
```

Pass a ``ContentTheme`` to control how each element type is styled:

```swift
RichText(markdown: post.content, theme: .blog)
```

If no theme is provided, ``RichText`` inherits the page-level `contentTheme`
declared on the ``Page`` conformance.

## Content Themes

``ContentTheme`` is a collection of closures — one per Markdown element type
— that wrap the rendered element in modifiers. This lets you style prose
content in one place rather than scattering modifiers across every page.

Score ships with two built-in themes:

| Theme | Description |
| ----- | ----------- |
| `ContentTheme.default` | No styling applied — plain rendered HTML |
| `ContentTheme.blog` | Generous line height, blockquote borders, comfortable heading sizes |

### Defining a custom theme

Each closure receives the rendered element as `any View`. Call `.erased()` to
convert it to `AnyView` so you can chain modifiers on the existential — without
`.erased()` the compiler cannot prove the concrete type:

```swift
extension ContentTheme {
    static var article: ContentTheme {
        ContentTheme(
            heading: { level, view in
                let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : .twoXL
                return view.erased().font(size: size, weight: .bold).margin(y: .rem(1))
            },
            paragraph: { view in
                view.erased().font(size: .lg, leading: .relaxed).margin(y: .rem(0.75))
            },
            code: { view in
                view.erased()
                    .font(family: .systemMono)
                    .padding(.px(2), .px(6))
                    .border(radius: .sm)
                    .background(color: .surface)
            },
            blockquote: { view in
                view.erased()
                    .border(color: .primary, width: 4, edge: .left)
                    .padding(x: .rem(1.5), y: .rem(1))
                    .font(color: .muted, style: .italic)
            },
            link: { view in
                view.erased().font(color: .primary, decoration: .underline)
            }
        )
    }
}
```

Only override the closures you need — every parameter has a default that passes
the view through unchanged, so you can target just headings and paragraphs
without specifying the rest.

### Applying a theme at the page level

Declare `contentTheme` on your ``Page`` conformance to apply it to every
``RichText`` on that page without passing it at each call site:

```swift
struct BlogPostPage: Page {
    let post: ContentPost

    var contentTheme: ContentTheme { .article }

    var body: some View {
        Main {
            Article {
                Heading(1) { post.frontmatter.title }
                RichText(markdown: post.content)   // inherits .article
            }
        }
    }
}
```

## Loading Markdown Content

### Static sites

``StaticPage`` types load Markdown files from `Content/` at build time:

```swift
struct BlogPostPage: Page, StaticPage {
    let post: ContentPost

    var path: String { "/blog/\(post.slug)" }

    var body: some View { … }

    static func instances() async throws -> [Self] {
        try await ContentStore.posts()
            .filter { $0.frontmatter.published }
            .map { BlogPostPage(post: $0) }
    }
}
```

### Server-rendered sites

Load content in your route handler and pass it to the page:

```swift
Page("/blog/:slug") { req in
    guard let post = try await ContentStore.post(slug: req.pathParameters["slug"]!)
    else { throw HTTPError.notFound }
    return BlogPostPage(post: post)
}
```

## Frontmatter

Markdown files support YAML frontmatter for structured metadata:

```markdown
---
title: Hello World
excerpt: My first post.
date: 2026-01-15
tags: [score, swift]
published: true
---

Post body goes here.
```

Access frontmatter through `ContentPost.frontmatter`:

```swift
post.frontmatter.title      // String
post.frontmatter.excerpt    // String?
post.frontmatter.date       // Date?
post.frontmatter.tags       // [String]
post.frontmatter.published  // Bool
```

Custom fields are available via `frontmatter.custom(_:)`:

```swift
post.frontmatter.custom("author")   // String?
```

## Markdown Extensions

``ContentStoreConfig`` controls which Markdown extensions the parser enables.
Pass a custom config to the ``ContentStore`` static methods:

```swift
let posts = try await ContentStore.posts(config: ContentStoreConfig(
    tableOfContents: true,
    footnotes: true
))
```

| Option | Default | Description |
| ------ | ------- | ----------- |
| `taskLists` | `true` | GitHub-style `- [ ]` and `- [x]` task lists |
| `tableOfContents` | `false` | Auto-generate a TOC from headings |
| `footnotes` | `false` | GitHub-style footnotes |
| `markedText` | `false` | `==highlighted==` text |
| `definitionLists` | `false` | Definition lists (`dl`/`dt`/`dd`) |
| `subscript` | `false` | Subscript text (`~text~`) |
| `superscript` | `false` | Superscript text (`^text^`) |

## Inline Markdown in Views

For short one-off markdown snippets, use ``RichText`` inline rather than
loading from a file:

```swift
RichText(markdown: "Install with **`score new`** or add the package manually.")
```

## See Also

- <doc:ViewHierarchy>
- <doc:ThemeAndTokens>
- <doc:APIRoutes>
