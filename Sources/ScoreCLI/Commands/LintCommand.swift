import ArgumentParser
import Foundation
import Noora

/// `score lint` — lint Score views and flag common issues.
///
/// Rule categories:
/// - A   (Accessibility): image-alt, form-label, link-text
/// - SE  (Semantic):      no-inline-style
/// - SC  (Scoping):       duplicate-id
/// - S   (State):         unused-state
/// - P   (Performance):   deep-nesting
/// - C   (Content):       empty-heading, empty-paragraph, no-todo
/// - T   (Translation):   missing-translation-key
/// - ST  (Structure):     file-structure, score-project, no-async-page
struct LintCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint Score views for common issues."
    )

    @Flag(name: .long, help: "Treat warnings as errors.")
    var strict: Bool = false

    @Flag(name: .long, help: "Downgrade all errors to warnings.")
    var warnOnly: Bool = false

    @Flag(name: .long, help: "Attempt to auto-fix fixable issues.")
    var fix: Bool = false

    @Flag(name: .long, help: "Output results as JSON.")
    var json: Bool = false

    @Flag(name: .long, help: "Install `score lint` as a git pre-commit hook in .git/hooks/pre-commit.")
    var installHook: Bool = false

    @Option(name: .long, parsing: .upToNextOption, help: "Only run these rules (comma-separated or repeated).")
    var rule: [String] = []

    @Option(name: .long, parsing: .upToNextOption, help: "Skip these rules (comma-separated or repeated).")
    var skip: [String] = []

    @Argument(help: "Paths to lint (default: Sources/).")
    var paths: [String] = []

    mutating func run() async throws {
        if installHook {
            try installPreCommitHook()
            return
        }

        let targetPaths = paths.isEmpty ? ["Sources"] : paths
        let enabledRules = rule.flatMap { $0.split(separator: ",").map(String.init) }
        let skippedRules = skip.flatMap { $0.split(separator: ",").map(String.init) }
        let linter = ScoreLinter(strict: strict, warnOnly: warnOnly, enabledRules: enabledRules, skippedRules: skippedRules)

        var allDiagnostics: [LintDiagnostic] = []
        var fixedCount = 0
        for path in targetPaths {
            let (diags, fixed) = try linter.lint(path: URL(fileURLWithPath: path), autoFix: fix)
            allDiagnostics.append(contentsOf: diags)
            fixedCount += fixed
        }

        let noora = Noora()
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(allDiagnostics)
            noora.passthrough(TerminalText(stringLiteral: String(data: data, encoding: .utf8) ?? "[]"))
        } else {
            if fix && fixedCount > 0 {
                noora.success(.alert("Auto-fixed \(fixedCount) issue(s)."))
            }
            printDiagnostics(allDiagnostics, noora: noora)
        }

        let effectiveDiagnostics =
            warnOnly
            ? []
            : allDiagnostics.filter {
                $0.severity == .error || (strict && $0.severity == .warning)
            }
        if !effectiveDiagnostics.isEmpty {
            throw CLIError.lintFailed(effectiveDiagnostics.count)
        }
    }

    private func printDiagnostics(_ diagnostics: [LintDiagnostic], noora: Noora) {
        if diagnostics.isEmpty {
            noora.success(.alert("No issues found."))
            return
        }
        let errors = diagnostics.filter { $0.severity == .error }
        let warnings = diagnostics.filter { $0.severity == .warning }
        if !errors.isEmpty {
            noora.error(
                .alert(
                    "\(errors.count) error(s), \(warnings.count) warning(s)",
                    takeaways: errors.map { "\($0.file):\($0.line)  [\($0.rule)]  \($0.message)" }
                ))
        }
        if !warnings.isEmpty {
            noora.warning(
                warnings.map {
                    WarningAlert.alert("\($0.file):\($0.line)  [\($0.rule)]  \($0.message)")
                })
        }
    }

    private func installPreCommitHook() throws {
        let noora = Noora()
        let hookDir = URL(fileURLWithPath: ".git/hooks")
        let hookURL = hookDir.appendingPathComponent("pre-commit")

        guard FileManager.default.fileExists(atPath: ".git") else {
            noora.error(.alert("No .git directory found. Run this from the root of a git repository."))
            throw CLIError.lintFailed(1)
        }

        try FileManager.default.createDirectory(at: hookDir, withIntermediateDirectories: true)

        let script = "#!/bin/sh\nscore lint\n"
        if FileManager.default.fileExists(atPath: hookURL.path) {
            let existing = (try? String(contentsOf: hookURL, encoding: .utf8)) ?? ""
            guard !existing.contains("score lint") else {
                noora.info(.alert("Pre-commit hook already contains `score lint` — nothing to do."))
                return
            }
            // Append to existing hook rather than overwriting it.
            let updated = existing.hasSuffix("\n") ? existing + "score lint\n" : existing + "\nscore lint\n"
            try updated.write(to: hookURL, atomically: true, encoding: .utf8)
        } else {
            try script.write(to: hookURL, atomically: true, encoding: .utf8)
            // Make executable.
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: hookURL.path
            )
        }
        noora.success(.alert("Installed pre-commit hook.", takeaways: [".git/hooks/pre-commit"]))
    }
}

// MARK: - LintDiagnostic

struct LintDiagnostic: Codable, Sendable {
    enum Severity: String, Codable { case warning, error }
    let file: String
    let line: Int
    let column: Int
    let message: String
    let severity: Severity
    let rule: String
    let fixable: Bool

    init(file: String, line: Int, column: Int = 1, message: String, severity: Severity, rule: String, fixable: Bool = false) {
        self.file = file
        self.line = line
        self.column = column
        self.message = message
        self.severity = severity
        self.rule = rule
        self.fixable = fixable
    }
}

// MARK: - ScoreLinter

struct ScoreLinter: Sendable {
    let strict: Bool
    let warnOnly: Bool
    let enabledRules: [String]
    let skippedRules: [String]

    // Returns (diagnostics, fixedCount)
    func lint(path: URL, autoFix: Bool) throws -> ([LintDiagnostic], Int) {
        var diagnostics: [LintDiagnostic] = []
        var fixedCount = 0
        let fm = FileManager.default

        guard fm.fileExists(atPath: path.path) else { return ([], 0) }

        // ST001/ST002: detect whether this looks like a Score project
        if isEnabled("score-project") {
            let packagePath = URL(fileURLWithPath: "Package.swift")
            if let pkg = try? String(contentsOf: packagePath, encoding: .utf8) {
                if !pkg.contains("score") && !pkg.contains("Score") {
                    diagnostics.append(
                        LintDiagnostic(
                            file: "Package.swift", line: 1,
                            message: "Package.swift does not appear to depend on Score. Run `score lint` from a Score project root.",
                            severity: .warning, rule: "score-project"
                        ))
                }
            }
        }

        let enumerator = fm.enumerator(
            at: path,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }

            // ST002: flag types in the wrong directory
            if isEnabled("file-structure") {
                if let diag = checkFileStructure(fileURL) {
                    diagnostics.append(diag)
                }
            }

            // ST003: Page types should not do async work in their body
            if isEnabled("no-async-page") {
                if let diag = checkAsyncPage(fileURL) {
                    diagnostics.append(diag)
                }
            }

            let (fileDiags, fixed) = try lintFile(fileURL, autoFix: autoFix)
            diagnostics.append(contentsOf: fileDiags)
            fixedCount += fixed
        }

        return (diagnostics, fixedCount)
    }

    /// Warn when a `Page` type performs async work directly in its `body`,
    /// which should live in the `RouteCollection` controller instead.
    private func checkAsyncPage(_ url: URL) -> LintDiagnostic? {
        guard let source = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let conformsToPage = source.contains(": Page") || source.contains(":Page")
        guard conformsToPage else { return nil }

        // Allow `try await` inside `static func instances()` (StaticPage pattern).
        // Strip that section before checking.
        let withoutInstances = source.replacingOccurrences(
            of: #"static func instances\(\)[^}]*\}"#,
            with: "",
            options: .regularExpression
        )
        guard withoutInstances.contains("try await") else { return nil }

        return LintDiagnostic(
            file: url.path, line: 1,
            message: "Page type contains `try await` — move data fetching into the RouteCollection controller and pass data through the Page's initialiser.",
            severity: .warning, rule: "no-async-page"
        )
    }

    /// Warn when a `Page` type lives outside `Sources/Views/Pages/`,
    /// a `Record` type outside `Sources/Models/`, etc.
    private func checkFileStructure(_ url: URL) -> LintDiagnostic? {
        guard let source = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let path = url.path

        let conformsToPage = source.contains(": Page") || source.contains(":Page")
        let conformsToRecord = source.contains(": Record") || source.contains(":Record")
        let conformsToMiddleware = source.contains(": Middleware") || source.contains(":Middleware")
        let conformsToRouteCollection =
            source.contains(": RouteCollection") || source.contains(":RouteCollection")

        if conformsToPage && !path.contains("/Views/Pages/") && !path.contains("/Pages/") {
            return LintDiagnostic(
                file: path, line: 1,
                message: "Page type is outside Sources/Views/Pages/ — move it to match the recommended structure.",
                severity: .warning, rule: "file-structure"
            )
        }
        if conformsToRecord && !path.contains("/Models/") {
            return LintDiagnostic(
                file: path, line: 1,
                message: "Record type is outside Sources/Models/ — move it to match the recommended structure.",
                severity: .warning, rule: "file-structure"
            )
        }
        if conformsToMiddleware && !path.contains("/Middleware/") {
            return LintDiagnostic(
                file: path, line: 1,
                message: "Middleware type is outside Sources/Middleware/ — move it to match the recommended structure.",
                severity: .warning, rule: "file-structure"
            )
        }
        if conformsToRouteCollection && !path.contains("/Controllers/") {
            return LintDiagnostic(
                file: path, line: 1,
                message: "RouteCollection type is outside Sources/Controllers/ — move it to match the recommended structure.",
                severity: .warning, rule: "file-structure"
            )
        }
        return nil
    }

    private func isEnabled(_ rule: String) -> Bool {
        if skippedRules.contains(rule) { return false }
        if !enabledRules.isEmpty { return enabledRules.contains(rule) }
        return true
    }

    private func lintFile(_ url: URL, autoFix: Bool) throws -> ([LintDiagnostic], Int) {
        let source = try String(contentsOf: url, encoding: .utf8)
        var lines = source.components(separatedBy: "\n")
        var diagnostics: [LintDiagnostic] = []
        let file = url.path
        var fixedCount = 0

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // MARK: A — Accessibility

            // A001: Image without alt
            if isEnabled("image-alt") && trimmed.contains("Image(") && !trimmed.contains("alt:") && !trimmed.hasPrefix("//") {
                diagnostics.append(
                    LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Image element is missing an `alt:` attribute.",
                        severity: .warning, rule: "image-alt"
                    ))
            }

            // A002: Link without descriptive text — bare "click here" / "read more"
            if isEnabled("link-text") {
                let lower = trimmed.lowercased()
                let badPhrases = ["\"click here\"", "\"read more\"", "\"here\"", "\"learn more\""]
                if trimmed.contains("Link(") && badPhrases.contains(where: { lower.contains($0) }) {
                    diagnostics.append(
                        LintDiagnostic(
                            file: file, line: lineNumber, column: 1,
                            message: "Link text is not descriptive; avoid generic phrases like 'click here'.",
                            severity: .warning, rule: "link-text"
                        ))
                }
            }

            // A003: Input without an associated id — no `id:` parameter and no `.attribute("id"` modifier
            if isEnabled("form-label") && trimmed.contains("Input(")
                && !trimmed.contains("id:")
                && !trimmed.contains(".attribute(\"id\"")
                && !trimmed.hasPrefix("//")
            {
                diagnostics.append(
                    LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Input is missing an `id:` — pair it with a `Label(for:)` for accessibility.",
                        severity: .warning, rule: "form-label"
                    ))
            }

            // MARK: SE — Semantic HTML

            // SE001: Empty heading content
            if isEnabled("empty-heading") && trimmed.contains("Heading(") && trimmed.contains("{ }") {
                diagnostics.append(
                    LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Heading has empty content.",
                        severity: .warning, rule: "empty-heading"
                    ))
            }

            // SE002: Raw inline style attribute
            if isEnabled("no-inline-style") && trimmed.contains("\"style\"") && !trimmed.hasPrefix("//") {
                diagnostics.append(
                    LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Avoid raw `style` attributes; use Score modifiers instead.",
                        severity: strict ? .error : .warning, rule: "no-inline-style"
                    ))
            }

            // MARK: SC — Scoping

            // SC001: Duplicate `id:` values across lines in the same file
            if isEnabled("duplicate-id") {
                let idMatches = trimmed.range(of: #"id:\s*"([^"]+)""#, options: .regularExpression)
                if let range = idMatches {
                    let idToken = String(trimmed[range])
                    let idValue =
                        idToken
                        .replacingOccurrences(of: #"id:\s*""#, with: "", options: .regularExpression)
                        .replacingOccurrences(of: "\"", with: "")
                    let occurrences = lines.filter { $0.contains("id: \"\(idValue)\"") }.count
                    if occurrences > 1 {
                        diagnostics.append(
                            LintDiagnostic(
                                file: file, line: lineNumber, column: 1,
                                message: "Duplicate element id \"\(idValue)\" found \(occurrences) times in this file.",
                                severity: .warning, rule: "duplicate-id"
                            ))
                    }
                }
            }

            // MARK: P — Performance

            // P001: Deep nesting heuristic — very long indentation chains suggest over-nesting
            if isEnabled("deep-nesting") {
                let leadingSpaces = line.prefix(while: { $0 == " " }).count
                if leadingSpaces >= 32 && !trimmed.hasPrefix("//") && !trimmed.isEmpty {
                    diagnostics.append(
                        LintDiagnostic(
                            file: file, line: lineNumber, column: 1,
                            message: "Deeply nested view hierarchy (\(leadingSpaces / 4) levels) may hurt render performance. Consider extracting a sub-component.",
                            severity: .warning, rule: "deep-nesting"
                        ))
                }
            }

            // MARK: C — Content

            // C001: TODO / FIXME markers
            if isEnabled("no-todo") && (trimmed.contains("TODO:") || trimmed.contains("FIXME:")) {
                let marker = trimmed.contains("TODO:") ? "TODO" : "FIXME"
                if autoFix {
                    lines[index] = ""  // Remove the line on auto-fix
                    fixedCount += 1
                } else {
                    diagnostics.append(
                        LintDiagnostic(
                            file: file, line: lineNumber, column: 1,
                            message: "Unresolved \(marker) marker.",
                            severity: .warning, rule: "no-todo", fixable: true
                        ))
                }
            }

            // C002: Empty paragraph / text
            if isEnabled("empty-paragraph") && (trimmed == "Text { \"\" }" || trimmed == "Text{ \"\" }") {
                diagnostics.append(
                    LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Empty Text element produces no visible content.",
                        severity: .warning, rule: "empty-paragraph"
                    ))
            }

            // MARK: S — State

            // S001: @State var that is never mutated — suggest `let`
            if isEnabled("unused-state") && trimmed.hasPrefix("@State var ") && !trimmed.hasPrefix("//") {
                let varName =
                    trimmed
                    .replacingOccurrences(of: "@State var ", with: "")
                    .split(separator: ":").first.map(String.init)?
                    .trimmingCharacters(in: .whitespaces) ?? ""
                if !varName.isEmpty {
                    let sourceContainsMutation = lines.contains {
                        let t = $0.trimmingCharacters(in: .whitespaces)
                        return t.hasPrefix("\(varName) =") || t.hasPrefix("self.\(varName) =")
                    }
                    if !sourceContainsMutation {
                        diagnostics.append(
                            LintDiagnostic(
                                file: file, line: lineNumber, column: 1,
                                message: "`@State var \(varName)` is never mutated; consider using `let` instead.",
                                severity: .warning, rule: "unused-state"
                            ))
                    }
                }
            }

            // MARK: T — Translation

            // T001: Hard-coded string literal passed directly to Text (should use LocalizedKey or i18n)
            if isEnabled("missing-translation-key") && trimmed.contains("Text {") {
                let haslocalizedKey = trimmed.contains("LocalizedKey") || trimmed.contains("t(") || trimmed.contains("NSLocalizedString")
                let hasHardcodedString = trimmed.range(of: "Text\\s*\\{\\s*\"[^\"]+\"", options: .regularExpression) != nil
                if hasHardcodedString && !haslocalizedKey {
                    diagnostics.append(
                        LintDiagnostic(
                            file: file, line: lineNumber, column: 1,
                            message: "Hard-coded string in `Text {}` — use a translation key for localization.",
                            severity: .warning, rule: "missing-translation-key"
                        ))
                }
            }
        }

        // Write back auto-fixed source if needed
        if autoFix && fixedCount > 0 {
            let fixed = lines.joined(separator: "\n")
            try fixed.write(to: url, atomically: true, encoding: .utf8)
        }

        return (diagnostics, fixedCount)
    }
}
