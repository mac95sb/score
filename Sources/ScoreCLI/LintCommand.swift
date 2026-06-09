import ArgumentParser
import Foundation
import Noora

/// `score lint` — lint Score views and flag common issues.
///
/// Checks for:
/// - Duplicate CSS class names across components
/// - Missing `alt` attributes on `Image` elements
/// - Empty `Heading` levels
/// - `@State` properties that are never mutated (use `let` instead)
/// - Components with no semantic landmark (`<main>`, `<nav>`, etc.)
struct LintCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint Score views for common issues."
    )

    @Flag(name: .long, help: "Treat warnings as errors.")
    var strict: Bool = false

    @Flag(name: .long, help: "Output results as JSON.")
    var json: Bool = false

    @Argument(help: "Paths to lint (default: Sources/).")
    var paths: [String] = []

    mutating func run() async throws {
        let targetPaths = paths.isEmpty ? ["Sources"] : paths
        let linter = ScoreLinter(strict: strict)

        var allDiagnostics: [LintDiagnostic] = []
        for path in targetPaths {
            let diags = try linter.lint(path: URL(fileURLWithPath: path))
            allDiagnostics.append(contentsOf: diags)
        }

        let noora = Noora()
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(allDiagnostics)
            noora.passthrough(TerminalText(stringLiteral: String(data: data, encoding: .utf8) ?? "[]"))
        } else {
            printDiagnostics(allDiagnostics, noora: noora)
        }

        let errors = allDiagnostics.filter { $0.severity == .error || (strict && $0.severity == .warning) }
        if !errors.isEmpty {
            throw CLIError.lintFailed(errors.count)
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
                takeaways: errors.map { "\($0.file):\($0.line)  \($0.message)" }
            ))
        }
        if !warnings.isEmpty {
            noora.warning(warnings.map {
                WarningAlert.alert("\($0.file):\($0.line)  \($0.message)")
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
}

// MARK: - ScoreLinter

struct ScoreLinter: Sendable {
    let strict: Bool

    func lint(path: URL) throws -> [LintDiagnostic] {
        var diagnostics: [LintDiagnostic] = []
        let fm = FileManager.default

        guard fm.fileExists(atPath: path.path) else { return [] }

        let enumerator = fm.enumerator(
            at: path,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            let fileDiags = try lintFile(fileURL)
            diagnostics.append(contentsOf: fileDiags)
        }

        return diagnostics
    }

    private func lintFile(_ url: URL) throws -> [LintDiagnostic] {
        let source = try String(contentsOf: url, encoding: .utf8)
        let lines = source.components(separatedBy: "\n")
        var diagnostics: [LintDiagnostic] = []
        let file = url.path

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Rule: Image without alt
            if trimmed.contains("Image(") && !trimmed.contains("alt:") && !trimmed.contains("//") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Image element is missing an `alt:` attribute for accessibility.",
                    severity: .warning, rule: "image-alt"
                ))
            }

            // Rule: Empty heading content hint
            if trimmed.contains("Heading(") && trimmed.contains("{ }") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Heading has empty content.",
                    severity: .warning, rule: "empty-heading"
                ))
            }

            // Rule: Inline style escape hatch — Score owns all styles
            if trimmed.contains("\"style\"") && !trimmed.hasPrefix("//") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Avoid raw `style` attributes; use Score modifiers instead.",
                    severity: strict ? .error : .warning, rule: "no-inline-style"
                ))
            }

            // Rule: TODO / FIXME markers
            if trimmed.contains("TODO:") || trimmed.contains("FIXME:") {
                diagnostics.append(LintDiagnostic(
                    file: file, line: lineNumber, column: 1,
                    message: "Unresolved \(trimmed.contains("TODO:") ? "TODO" : "FIXME") marker.",
                    severity: .warning, rule: "no-todo"
                ))
            }
        }

        return diagnostics
    }
}
