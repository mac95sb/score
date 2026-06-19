# Code Quality

Enforce consistent formatting and correctness in Score projects with built-in linting and CI tooling.

## Overview

Score ships with first-party tooling for formatting, linting, CI integration,
and git hook wiring. All checks run through a single `score lint` command so
your pipeline stays simple.

## Formatting

Score projects use [swift-format](https://github.com/swiftlang/swift-format).
Add a `.swift-format` file at the project root to configure line length and
indentation. The `score new` templates include a `.swift-format` preset.

## Linting

```sh
score lint          # runs swift-format --lint and Score's own rule checks
score lint --fix    # applies auto-fixable formatting in place
```

Score's linter checks for:

- **A (Accessibility)** — missing image alt text, non-descriptive link text, inputs without labels
- **SE (Semantic)** — raw inline style attributes, correct landmark usage
- **SC (Scoping)** — duplicate element IDs in a file
- **S (State)** — `@State` variables that are never mutated
- **P (Performance)** — deeply nested view hierarchies that should be extracted into components
- **C (Content)** — empty headings, empty paragraphs, unresolved `TODO`/`FIXME` markers
- **T (Translation)** — hard-coded strings in `Text {}` that should use a localisation key
- **ST (Structure)** — types placed outside their canonical directories; non-Score packages

Pass `--rule <id>` to run a single rule, `--skip <id>` to suppress one, and
`--strict` to promote all warnings to errors.

## CI

Run `score lint` and `swift test` in CI before merging. A minimal GitHub Actions
workflow:

```yaml
- name: Lint
  run: score lint
- name: Test
  run: swift test
```

## Git Hooks

Wire `score lint` into a pre-commit hook to catch issues before they reach CI.
The quickest way is to let Score install the hook for you:

```sh
score lint --install-hook
```

This writes (or appends to) `.git/hooks/pre-commit` and sets the executable
bit. If a hook already exists, `score lint` is appended rather than overwriting
your existing hook script.

You can also do it manually:

```sh
echo 'score lint' > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```
