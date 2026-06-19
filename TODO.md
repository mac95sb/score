# Score Todo

## Questions

- [x] Does the template need to contain a custom ContentTheme or can it work
      based on the default styles? → static template now writes `Sources/Views/ContentThemes.swift`
      with a `.blog` ContentTheme; BlogPostPage uses it.
- [x] Feels weird to go from explaining starting a new application and rendering
      a few elements to talking about packaging the app for native systems in
      the getting started article. → Moved to `NativeApps.md`; added "Going
      Further" nav category in `Score.md`. Tutorial still needed.
- [x] Move the code quality section of the Getting Started md file to its own
      section. → Moved to `CodeQualityAndPlugins.md` under "Going Further".
- [ ] Should we keep all of the variants on div (Stack, HStack, Grid, etc.) or
      should we shift everything over to just use `Stack` and style/layout
      things are handled by modifiers?
- [ ] I think maybe it's a good idea to discourage server side rendered pages
      and instead favour pages and controllers to be separate? Do you agree with
      this or doyou think this is a bad idea? I just think keeping it an obvious
      split of views are frontend and logic is backend will keep a) the mental
      model simple and b) the deployment solutions simple.

## Tasks

- [ ] The general application structure should follow
      https://developer.apple.com/tutorials/swiftui/design-pattern
- [ ] Add swift blocks from README to the @./scripts/format-doc-snippets.swift
      so all are formatted the same way.
- [x] score dev currently breaks with stale SwiftPM git cache → `buildPackage`
      now captures stderr, detects the git-cache error, and shows an actionable
      hint to run `swift package reset`.
- [x] The AGENTS.md should also add a CLAUDE.md by default and the --agents
      should be able to have `default|agents|claude|none`. → Done. `score new`
      now accepts `--agents default|agents|claude|none` and AGENTS.md has full
      Score API quick reference.
- [ ] Not all docc tutorial code snippets on the right hand side are getting
      swift syntax highlighting.
- [x] `score generate` command needs updates to standard paths → pages now go to
      `Sources/Views/Pages/`, components to `Sources/Views/Components/`. Added
      `controller` generator type → `Sources/Controllers/`.
- [x] We should probably also add `score generate` commands to the Makefile →
      `make page|component|action|record|middleware|controller NAME=Foo` added.
- [x] We should supply a selection of snippets for the above as well? → Done.
      `score snippets` CLI command installs VS Code (`.vscode/score.code-snippets`)
      and/or Xcode (`.codesnippet` plists) snippets for all generator types.
      `SnippetsCommand.swift` must be kept in sync with `GenerateCommand.swift`.
- [x] We also should supply a generate completions command →
      `score completions
      zsh|bash|fish` added.
- [x] During the @./Documentation.docc/{Articles,Tutorials}/ it's important that
      occurences of things like `Application|View|Page|Metadata` link out to the
      symbol they are referring to. → Fixed double-backtick symbol links across
      GettingStarted, ThemeAndTokens, ViewHierarchy, DataLayer, APIRoutes.
- [x] The default and static template should include a Localizable.xcstrings →
      written to `Sources/Localizable.xcstrings` with EN, ES, DE, RU, ZH-Hans
      seeds for app.name, nav._, action._, footer.* keys; Package.swift
      declares `.process("Localizable.xcstrings")` so `Bundle.module` can load
      it. A `t()` / `L()` Score API is Task 7 below.
- [ ] Score as a library in the same way it provides theme dropdown building
      helpers needs to do the same for translations.
- [ ] We need to build out tooling for translated Content, perhaps if a Content
      directory contains language codes it will generate them behind `/` for
      default language (matches up with that in Localizable) and then `/es/**/*`
      this is how Localizable should work in general and part of score lint
      should flag if a language code exists in `.xcstrings` but not in
      Content/**
- [x] Score lint should also check the general structure and dependencies and if
      it doesn't seem like a Score application it should flag this. →
      `score-project` rule added; warns if Package.swift has no Score
      dependency.
- [x] Score lint should also, by default but optional to switch off, encourage
      the recommended application structure → `file-structure` rule added; flags
      Page/Record/Middleware/RouteCollection types outside their canonical dirs.
- [x] Perhaps githook wiring should be an option or something under the
      `score lint` subcommand → `score lint --install-hook` wires
      `.git/hooks/pre-commit` (appends safely if hook already exists).
- [x] Plugins should also get its own section under the same category as code
      quality and native bundling → split into `Plugins.md` and `CodeQuality.md`;
      `CodeQualityAndPlugins.md` now cross-links both.
- [x] Page-controller separation: enforce via `score lint` → `no-async-page` rule
      added; flags `try await` in Page body outside `static func instances()`.
      Documented in `APIRoutes.md` "Pages Are Pure Views" section.
- [x] The docc symbol information are not showing on the generated documentation
      sites? → Root cause: `Score` umbrella's symbol graph doesn't carry docComments
      for `@_exported import ScoreCore` symbols. Fixed by switching docs generation
      to `--target ScoreCore`; catalog renamed `Score.md` → `ScoreCore.md`;
      Makefile and CI updated. Symbol descriptions now appear correctly.
- [ ] It seems not all symbols are documented with proper docc comments, see the
      ScoreCore/Elements to see how docc comments should be written and then
      ensure all code symbols in @Sources are documented this way with summary,
      description, params, retursn, throws, example, etc

> [!IMPORTANT]
> Ensure all Documentation.docc (both comments and Articles/Tutorials are
> updated in accordance with the changes that are made.
