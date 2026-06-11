import Foundation

// MARK: - CLIError

enum CLIError: Error, CustomStringConvertible {
    case buildFailed
    case buildNotFound(String)
    case directoryExists(String)
    case fileExists(String)
    case lintFailed(Int)
    case translationsMissing(Int)
    case executableNotFound
    case invalidName(String)

    var description: String {
        switch self {
        case .invalidName(let name):
            return """
            Invalid name '\(name)'. Names must start with a letter and contain \
            only letters, numbers, hyphens, or underscores.
            """
        case .buildFailed:
            return "Swift build failed. Check compiler output above."
        case .buildNotFound(let dir):
            return "Build output not found at '\(dir)'. Run `score build` first."
        case .directoryExists(let name):
            return "Directory '\(name)' already exists."
        case .fileExists(let path):
            return "File '\(path)' already exists. Use --force to overwrite."
        case .lintFailed(let count):
            return "\(count) lint error(s) found."
        case .translationsMissing(let count):
            return "\(count) missing translation key(s)."
        case .executableNotFound:
            return "Built executable not found. Run `swift build` first."
        }
    }
}

// MARK: - Name validation

/// Validate a user-supplied project/kit/file name before it is interpolated
/// into generated source, package manifests, or filesystem paths.
///
/// Restricting to `^[A-Za-z][A-Za-z0-9_-]*$` blocks:
/// - path traversal (`..`, `/`, `\`) when the name becomes a directory/file,
/// - code injection (`"`, `)`, `;`, newlines) into generated `Package.swift`
///   and other templates.
func validateName(_ name: String) throws {
    guard let first = name.first, first.isLetter, first.isASCII else {
        throw CLIError.invalidName(name)
    }
    let isValid = name.allSatisfy { ch in
        (ch.isASCII && ch.isLetter) || ch.isNumber || ch == "-" || ch == "_"
    }
    guard isValid else { throw CLIError.invalidName(name) }
}

// MARK: - Build helper

/// Run `swift build` with the given configuration.
///
/// - Returns: `true` on success, `false` on build failure.
func buildPackage(configuration: String, verbose: Bool) async throws -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    process.arguments = ["build", "-c", configuration]

    if !verbose {
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.standardError
    }

    try process.run()
    process.waitUntilExit()
    return process.terminationStatus == 0
}

/// Locate the built executable in `.build/debug/` or `.build/release/`.
func locateExecutable() throws -> URL {
    let fm = FileManager.default

    // Determine the package name from Package.swift
    let packageName = detectPackageName() ?? "App"

    let candidates = [
        URL(fileURLWithPath: ".build/debug/\(packageName)"),
        URL(fileURLWithPath: ".build/release/\(packageName)"),
        URL(fileURLWithPath: ".build/arm64-apple-macosx/debug/\(packageName)"),
        URL(fileURLWithPath: ".build/arm64-apple-macosx/release/\(packageName)"),
        URL(fileURLWithPath: ".build/x86_64-apple-macosx/debug/\(packageName)"),
        URL(fileURLWithPath: ".build/x86_64-unknown-linux-gnu/debug/\(packageName)"),
        URL(fileURLWithPath: ".build/x86_64-unknown-linux-gnu/release/\(packageName)"),
    ]

    for candidate in candidates {
        if fm.fileExists(atPath: candidate.path) {
            return candidate
        }
    }

    throw CLIError.executableNotFound
}

private func detectPackageName() -> String? {
    guard let pkg = try? String(contentsOfFile: "Package.swift", encoding: .utf8) else { return nil }
    // Look for: name: "Foo"
    if let range = pkg.range(of: #"name:\s*"([^"]+)""#, options: .regularExpression) {
        let match = String(pkg[range])
        if let nameRange = match.range(of: #""([^"]+)""#, options: .regularExpression) {
            return match[nameRange].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
    }
    return nil
}

// MARK: - FileWatcher

/// A simple polling-based file watcher for development hot-reload.
actor FileWatcher {
    private let directories: [URL]
    private let onChange: @Sendable (URL) -> Void
    private var lastModificationDates: [URL: Date] = [:]

    init(directories: [URL], onChange: @Sendable @escaping (URL) -> Void) {
        self.directories = directories
        self.onChange = onChange
    }

    func start() async {
        while !Task.isCancelled {
            checkForChanges()
            try? await Task.sleep(for: .milliseconds(500))
        }
    }

    private func checkForChanges() {
        let fm = FileManager.default
        for dir in directories {
            guard let enumerator = fm.enumerator(
                at: dir,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { continue }

            while let fileURL = enumerator.nextObject() as? URL {
                guard let attrs = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                      let modDate = attrs.contentModificationDate else { continue }

                if let lastDate = lastModificationDates[fileURL] {
                    if modDate > lastDate {
                        lastModificationDates[fileURL] = modDate
                        onChange(fileURL)
                    }
                } else {
                    lastModificationDates[fileURL] = modDate
                }
            }
        }
    }
}
