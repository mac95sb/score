# Score

A Swift-first framework for building web applications — described in Swift, rendered to vanilla HTML, CSS, and JavaScript.

**[Documentation](https://mac95sb.github.io/score/documentation/score)** · **[Showcase](#showcase)** · **[Getting Started](https://mac95sb.github.io/score/documentation/score/gettingstarted)**

```swift
struct ArticleCard: View {
    let post: Post
    var body: some View {
        VStack {
            Heading(3) { post.title }
            Text { post.excerpt }.font(color: .muted)
        }
        .padding(6)
        .border(radius: .lg)
        .on(.hover) { $0.shadow(.md).translate(y: .px(-2)) }
        .animate(.all, duration: 150.ms)
    }
}
```

## Installation

```bash
curl -fsSL https://github.com/mac95sb/score/releases/latest/download/score \
  -o ~/.local/bin/score && chmod +x ~/.local/bin/score
```

Then scaffold a new project:

```bash
score new my-site
cd my-site && score dev
```

## License

MIT
