# Score

Compose web apps in Swift — rendered to vanilla HTML, CSS, and JavaScript.

**[Documentation](https://mac95sb.github.io/score/documentation/score)** ·
**[Tutorials](https://mac95sb.github.io/score/tutorials/score)**

```swift
struct ArticleCard: View {
    let post: ContentPost
    var body: some View {
        VStack {
            Heading(3) {
                post.frontmatter.title
            }
            Text {
                post.frontmatter.excerpt ?? ""
            }
            .font(color: .muted)
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
# Build the CLI from source
git clone https://github.com/mac95sb/score
cd score
swift build -c release
cp .build/release/score ~/.local/bin/score

# Create and run a project
score new my-site
cd my-site && score dev
```

Open `http://localhost:8080`. Edit any file in `Sources/` or `Content/` and the
browser reloads automatically.

For guides, tutorials, and the full API reference, see the
**[documentation](https://mac95sb.github.io/score/documentation/score)**.

## Runnable Examples

`Templates/kitchen-sink` references the local checkout and runs without
installing Score:

```bash
make ks-dev    # score dev with hot-reload (builds Score debug first)
```

It is the canonical live showcase: every element, modifier, theme preset,
state pattern, animation, and routing API has a working example there. It
doubles as a regression test — if a change breaks the kitchen-sink visually,
it broke something real.

`Templates/default` and `Templates/static` are scaffold templates used by
`score new`; browse them as examples of the expected project structure.

## Contributing

When adding a new element, modifier, or feature:

1. Add DocC comments to every public API (with a usage code block).
2. Update the relevant `Sources/Score/Documentation.docc/Articles/` article, or add one.
3. Add a live demo section to `Templates/kitchen-sink/Sources/Application.swift`.
4. Add tests in `Tests/ScoreCoreTests/`.

See `AGENTS.md` for the full contributor checklist and architecture notes.

## License

Apache 2.0
