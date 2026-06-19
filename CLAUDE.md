# Claude guidance

See `AGENTS.md` for full build/test instructions and conventions.

Key constraint while dogfooding (pre-launch): do **not** implement `customCSS`,
`customJS`, or `customHTML` escape hatches anywhere in the framework. Use the
structured theme `overrides` dictionaries and Score's element/state APIs
instead, and flag genuine gaps rather than adding raw passthroughs.

When adding a new `score generate` type, update `SnippetsCommand.swift`
alongside `GenerateCommand.swift` — both the Xcode and VS Code snippet bodies
must reflect the new generator template.
