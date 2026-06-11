import ArgumentParser
import Foundation
import Noora

/// `score translations` — manage i18n/l10n translation files.
///
/// Provides sub-commands for extracting translatable strings from source
/// files, validating that all translation keys are covered, and generating
/// typed Swift accessors.
struct TranslationsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "translations",
        abstract: "Manage i18n/l10n translation files.",
        subcommands: [
            TranslationsExtractCommand.self,
            TranslationsValidateCommand.self,
            TranslationsGenerateCommand.self,
        ]
    )
}

// MARK: - Extract

struct TranslationsExtractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract",
        abstract: "Extract translatable strings from source files."
    )

    @Option(name: .shortAndLong, help: "Source directory to scan.")
    var source: String = "Sources"

    @Option(name: .shortAndLong, help: "Output directory for translation files.")
    var output: String = "Translations"

    @Option(name: .shortAndLong, help: "Base locale (e.g. en).")
    var locale: String = "en"

    mutating func run() async throws {
        let noora = Noora()
        let extractor = TranslationExtractor()

        let keys = try await noora.progressStep(
            message: "Extracting translatable strings from \(source)…"
        ) { _ in
            try extractor.extract(from: URL(fileURLWithPath: source))
        }

        let outputDir = URL(fileURLWithPath: output)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let outputFile = outputDir.appendingPathComponent("\(locale).yaml")
        let yaml = keys
            .sorted()
            .map { key in "\"\(key)\": \"\(key)\"" }
            .joined(separator: "\n")
        try yaml.write(to: outputFile, atomically: true, encoding: .utf8)

        noora.success(.alert("Extracted \(keys.count) key(s)", takeaways: ["\(outputFile.path)"]))
    }
}

// MARK: - Validate

struct TranslationsValidateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Check that all translation keys are covered across locales."
    )

    @Option(name: .shortAndLong, help: "Translations directory.")
    var directory: String = "Translations"

    @Option(name: .shortAndLong, help: "Base locale to compare against.")
    var base: String = "en"

    mutating func run() async throws {
        let dir = URL(fileURLWithPath: directory)
        let validator = TranslationValidator()
        let issues = try validator.validate(in: dir, base: base)

        let noora = Noora()
        if issues.isEmpty {
            noora.success(.alert("All translations are complete."))
        } else {
            noora.warning(issues.map { WarningAlert.alert("\($0)") })
            throw CLIError.translationsMissing(issues.count)
        }
    }
}

// MARK: - Generate

struct TranslationsGenerateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate typed Swift accessors from translation files."
    )

    @Option(name: .shortAndLong, help: "Translations directory.")
    var directory: String = "Translations"

    @Option(name: .shortAndLong, help: "Output Swift file.")
    var output: String = "Sources/Generated/Translations.swift"

    @Option(name: .shortAndLong, help: "Base locale.")
    var locale: String = "en"

    mutating func run() async throws {
        let dir = URL(fileURLWithPath: directory)
        let generator = TranslationCodeGenerator()
        let swiftCode = try generator.generate(from: dir, locale: locale)

        let outputURL = URL(fileURLWithPath: output)
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try swiftCode.write(to: outputURL, atomically: true, encoding: .utf8)
        Noora().success(.alert("Generated typed accessors", takeaways: ["\(output)"]))
    }
}

// MARK: - TranslationExtractor

struct TranslationExtractor: Sendable {
    func extract(from directory: URL) throws -> Set<String> {
        var keys = Set<String>()
        let fm = FileManager.default
        let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            let source = try String(contentsOf: fileURL, encoding: .utf8)
            // Extract L("key") and Localized("key") patterns
            let pattern = #"(?:L|Localized)\(\s*"([^"]+)"\s*\)"#
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(source.startIndex..., in: source)
                for match in regex.matches(in: source, range: range) {
                    if let keyRange = Range(match.range(at: 1), in: source) {
                        keys.insert(String(source[keyRange]))
                    }
                }
            }
        }
        return keys
    }
}

// MARK: - TranslationValidator

struct TranslationValidator: Sendable {
    func validate(in directory: URL, base: String) throws -> [String] {
        let fm = FileManager.default
        let yamlFiles = try fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "yaml" }

        guard let baseFile = yamlFiles.first(where: { $0.deletingPathExtension().lastPathComponent == base }) else {
            return ["Base locale '\(base).yaml' not found in \(directory.path)"]
        }

        let baseKeys = try loadKeys(from: baseFile)
        var issues: [String] = []

        for file in yamlFiles where file != baseFile {
            let locale = file.deletingPathExtension().lastPathComponent
            let localeKeys = try loadKeys(from: file)
            let missing = baseKeys.subtracting(localeKeys)
            for key in missing.sorted() {
                issues.append("[\(locale)] Missing key: \"\(key)\"")
            }
        }
        return issues
    }

    private func loadKeys(from file: URL) throws -> Set<String> {
        let content = try String(contentsOf: file, encoding: .utf8)
        var keys = Set<String>()
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            if let colonIdx = trimmed.firstIndex(of: ":") {
                let key = trimmed[trimmed.startIndex..<colonIdx]
                    .trimmingCharacters(in: .init(charactersIn: "\" "))
                keys.insert(key)
            }
        }
        return keys
    }
}

// MARK: - TranslationCodeGenerator

struct TranslationCodeGenerator: Sendable {
    func generate(from directory: URL, locale: String) throws -> String {
        let fm = FileManager.default
        guard let baseFile = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .first(where: { $0.deletingPathExtension().lastPathComponent == locale }) else {
            throw CLIError.translationsMissing(0)
        }

        let content = try String(contentsOf: baseFile, encoding: .utf8)
        var keys: [(swift: String, key: String)] = []
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            if let colonIdx = trimmed.firstIndex(of: ":") {
                let key = trimmed[trimmed.startIndex..<colonIdx]
                    .trimmingCharacters(in: .init(charactersIn: "\" "))
                let swiftName = key.components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { !$0.isEmpty }
                    .enumerated()
                    .map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }
                    .joined()
                keys.append((swiftName, key))
            }
        }

        let properties = keys.map { (swift, key) in
            "    static var \(swift): String { L(\"\(key)\") }"
        }.joined(separator: "\n")

        return """
        // Generated by `score translations generate` — do not edit manually.
        import Foundation

        public enum Strings {
        \(properties)
        }

        /// Look up a translation key in the current bundle.
        public func L(_ key: String, _ args: CVarArg...) -> String {
            let format = NSLocalizedString(key, bundle: .main, comment: "")
            return args.isEmpty ? format : String(format: format, arguments: args)
        }
        """
    }
}
