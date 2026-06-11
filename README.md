<p align="center">
  <img src="icon.svg" width="64" height="64" alt="Score">
</p>

# Score

Compose web apps in Swift — rendered to vanilla HTML, CSS, and JavaScript.

**[Documentation](https://mac95sb.github.io/score/documentation/score)** · **[Tutorials](https://mac95sb.github.io/score/tutorials/score)** · **[Showcase](#showcase)**

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

## Quick Start

```bash
# Install the CLI
curl -fsSL https://github.com/mac95sb/score/releases/latest/download/score \
  -o ~/.local/bin/score && chmod +x ~/.local/bin/score

# Create and run a project
score new my-site
cd my-site && score dev
```

Open `http://localhost:8080`. Edit any file in `Sources/` or `Content/` and the browser reloads automatically.

For guides, tutorials, and the full API reference, see the **[documentation](https://mac95sb.github.io/score/documentation/score)**.

## License

Apache 2.0
