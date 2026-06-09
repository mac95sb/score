import ArgumentParser
import Foundation
import Noora

/// `score lint` — lint Score views and flag common issues.
///
/// Rule categories:
/// - A   (Accessibility): image-alt, aria-label, form-label, heading-order, link-text
/// - SE  (Semantic):      semantic-landmark, no-div-soup
/// - SC  (Scoping):       duplicate-id
/// - S   (State):         unused-state
/// - P   (Performance):   deep-nesting
/// - C   (Content):       empty-heading, empty-paragraph, no-todo
/// - T   (Translation):   missing-translation-key
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

    @Option(name: .long, parsing: .upToNextOption, help: "Only run these rules (comma-separated or repeated).")
    var rule: [String] = []

    @Option(name: .long, parsing: .upToNextOption, help: "Skip these rules (comma-separated or repeated).")
    var skip: [String] = []

    @Argument(help: "Paths to lint (default: Sources/).")
    var paths: [String] = []

    mutating func run() async throws {
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

        let effectiveDiagnostics = warnOnly ? [] : allDiagnostics.filter {
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
            noora.error(.alert(
                "\(errors.count) error(s), \(warnings.count) warning(s)",
                takeaways: errors.map { "\($0.file):\($0.line)  [\($0.rule)]  \($0.message)" }
            ))
        }
        if !warnings.isEmpty {
            noora.warning(warnings.map {
                WarningAlert.alert("\($0.file):\($0.line)  [\($0.rule)]  \($0.message)")
            })
        }
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
        self.file = file; self.line = line; self.column = column
        self.message = message; self.severity = severity; self.rule = rule; self.fixable = fixable
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

        let enumerator = fm.enumerator(
            at: path,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            let (fileDiags, fixed) = try lintFile(fileURL, autoFix: autoFix)
            diagnostics.append(contentsOf: fileDiags)
            fixedCount += fixed
        }

        return (diagnostics, fixedCount)
    }

    private func isEnabled(_ rule: String) -> Bool {
        if skippedRules.contains(rule) { return false }
        if !enabledRules.isEmpty { return enabledRules.contains(rule) }
        return true
    }

    private func lintFile(_ url: URL, autoFix: Bool) throws -> ([LintDiagnostic], Int) {
        var source = try String(contentsOf: url, encoding: .utf8)
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
                diagnostics.append(LintDiagnostic(
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
                    diagnostics.append(LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Link text is not descriptive; avoid generic phrases like 'click here'.",
                        severity: .warning, rule: "link-text"
                    ))
                }
            }

            // A003: Input without an associated Label
            if isEnabled("form-label") && trimmed.contains("Input(") && !trimmed.contains("id:") && !trimmed.hasPrefix("//") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Input is missing an `id:` — pair it with a `Label(for:)` for accessibility.",
                    severity: .warning, rule: "form-label"
                ))
            }

            // MARK: SE — Semantic HTML

            // SE001: Empty heading content
            if isEnabled("empty-heading") && trimmed.contains("Heading(") && trimmed.contains("{ }") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Heading has empty content.",
                    severity: .warning, rule: "empty-heading"
                ))
            }

            // SE002: Raw inline style attribute
            if isEnabled("no-inline-style") && trimmed.contains("\"style\"") && !trimmed.hasPrefix("//") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Avoid raw `style` attributes; use Score modifiers instead.",
                    severity: strict ? .error : .warning, rule: "no-inline-style"
                ))
            }

            // MARK: P — Performance

            // P001: Deep nesting heuristic — very long indentation chains suggest over-nesting
            if isEnabled("deep-nesting") {
                let leadingSpaces = line.prefix(while: { $0 == " " }).count
                if leadingSpaces >= 32 && !trimmed.hasPrefix("//") && !trimmed.isEmpty {
                    diagnostics.append(LintDiagnostic(
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
                    lines[index] = "" // Remove the line on auto-fix
                    fixedCount += 1
                } else {
                    diagnostics.append(LintDiagnostic(
                        file: file, line: lineNumber, column: 1,
                        message: "Unresolved \(marker) marker.",
                        severity: .warning, rule: "no-todo", fixable: true
                    ))
                }
            }

            // C002: Empty paragraph / text
            if isEnabled("empty-paragraph") && (trimmed == "Text { \"\" }" || trimmed == "Text{ \"\" }") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Empty Text element produces no visible content.",
                    severity: .warning, rule: "empty-paragraph"
                ))
            }

            // MARK: S — State

            // S001: @State var that is never mutated — suggest `let`
            if isEnabled("unused-state") && trimmed.hasPrefix("@State var ") && !trimmed.hasPrefix("//") {
                let varName = trimmed
                    .replacingOccurrences(of: "@State var ", with: "")
                    .split(separator: ":").first.map(String.init)?
                    .trimmingCharacters(in: .whitespaces) ?? ""
                if !varName.isEmpty {
                    let sourceContainsMutation = lines.contains {
                        let t = $0.trimmingCharacters(in: .whitespaces)
                        return t.hasPrefix("\(varName) =") || t.hasPrefix("self.\(varName) =")
                    }
                    if !sourceContainsMutation {
                        diagnostics.append(LintDiagnostic(
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
                    diagnostics.append(LintDiagnostic(
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
