# Claude guidance

See `AGENTS.md` for full build/test instructions and conventions.

Key constraint while dogfooding (pre-launch): do **not** implement `customCSS`,
`customJS`, or `customHTML` escape hatches anywhere in the framework. Use the
structured theme `overrides` dictionaries and Score's element/state APIs
instead, and flag genuine gaps rather than adding raw passthroughs.
