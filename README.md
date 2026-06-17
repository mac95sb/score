<p align="center">
  <!-- <img src="icon.png" width="64" height="64" alt="Score"> -->
</p>

# Score

Compose web apps in Swift — rendered to vanilla HTML, CSS, and JavaScript.

**[Documentation](https://mac95sb.github.io/score/documentation/score)** ·
**[Tutorials](https://mac95sb.github.io/score/tutorials/score)** ·
**[Showcase](#showcase)**

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

Open `http://localhost:8080`. Edit any file in `Sources/` or `Content/` and the
browser reloads automatically.

For guides, tutorials, and the full API reference, see the
**[documentation](https://mac95sb.github.io/score/documentation/score)**.

## Runnable Examples

The packages under `Templates/` reference the local checkout and run without
installing Score:

```bash
# Quick smoke test — covers every Score system
make ks-dev           # score dev with hot-reload (builds Score debug first)
make ks-run           # swift run, no hot-reload

# Scaffold templates
swift run --package-path Templates/static
swift run --package-path Templates/default
```

`Templates/kitchen-sink` is the canonical live showcase: every element,
modifier, theme preset, state pattern, animation, and routing API should have
a working example there. It doubles as a regression test — if a change breaks
the kitchen-sink visually, it broke something real.

## Contributing

When adding a new element, modifier, or feature:

1. Add DocC comments to every public API (with a usage code block).
2. Update the relevant `Sources/Score/Documentation.docc/Articles/` article, or add one.
3. Add a live demo section to `Templates/kitchen-sink/Sources/Application.swift`.
4. Add tests in `Tests/ScoreCoreTests/`.

See `AGENTS.md` for the full contributor checklist and architecture notes.

## License

Apache 2.0
