import Foundation

// MARK: - AppSource

/// Where the packaged WebView shell loads the application from.
public enum AppSource: Sendable, Equatable {
    /// Bundle a static export (the output of `score build`) into the app.
    case staticExport(path: String)
    /// Point the WebView at a deployed Score server.
    case remote(url: String)
}

// MARK: - PackagingConfig

/// Configuration shared by all native WebView packagers.
public struct PackagingConfig: Sendable {
    /// Human-readable application name shown in window titles and launchers.
    public var appName: String
    /// Reverse-DNS application identifier (e.g. `com.example.myapp`).
    public var identifier: String
    /// Application version string.
    public var version: String
    /// Where the WebView loads the app from.
    public var source: AppSource
    /// Initial window width in logical pixels (desktop platforms).
    public var windowWidth: Int
    /// Initial window height in logical pixels (desktop platforms).
    public var windowHeight: Int
    /// Default container CLI baked into generated Makefiles for container
    /// builds. Defaults to `container` (apple/container); `docker` and
    /// `podman` are CLI-compatible for the `build`/`run` subcommands the
    /// generated projects use, so any of them can also be swapped in at
    /// invocation time via `make … CONTAINER=<tool>`.
    public var containerTool: String

    public init(
        appName: String,
        identifier: String? = nil,
        version: String = "1.0.0",
        source: AppSource,
        windowWidth: Int = 1024,
        windowHeight: Int = 768,
        containerTool: String = "container"
    ) throws {
        let trimmedName = appName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw PackagingError.invalidAppName(appName)
        }
        self.appName = trimmedName

        let resolvedIdentifier = identifier
            ?? "com.example.\(Self.lowercasedAlphanumeric(trimmedName, fallback: "scoreapp"))"
        guard Self.isValidIdentifier(resolvedIdentifier) else {
            throw PackagingError.invalidIdentifier(resolvedIdentifier)
        }
        self.identifier = resolvedIdentifier

        if case .remote(let url) = source {
            guard let parsed = URL(string: url),
                  let scheme = parsed.scheme?.lowercased(),
                  scheme == "http" || scheme == "https"
            else {
                throw PackagingError.invalidRemoteURL(url)
            }
        }
        self.source       = source
        self.version      = version
        self.windowWidth  = windowWidth
        self.windowHeight = windowHeight

        let trimmedTool = containerTool.trimmingCharacters(in: .whitespacesAndNewlines)
        self.containerTool = trimmedTool.isEmpty ? "container" : trimmedTool
    }

    // MARK: - Derived names

    /// PascalCase name safe for type names and project files (e.g. `MyApp`).
    public var executableName: String {
        let parts = appName.split { !$0.isLetter && !$0.isNumber }
        var name = parts.map { part -> String in
            guard let first = part.first else { return "" }
            return first.uppercased() + part.dropFirst()
        }.joined()
        if name.isEmpty { name = "ScoreApp" }
        if let first = name.first, first.isNumber { name = "App" + name }
        return name
    }

    /// Lowercase name safe for binaries and file names (e.g. `myapp`).
    public var binaryName: String {
        Self.lowercasedAlphanumeric(appName, fallback: "scoreapp")
    }

    /// The identifier rewritten as a valid Java/Kotlin package name.
    public var androidPackage: String {
        let segments = identifier.lowercased().split(separator: ".").map { segment -> String in
            var clean = segment.map { ch -> Character in
                (ch.isLetter && ch.isASCII) || ch.isNumber || ch == "_" ? ch : "_"
            }
            if let first = clean.first, first.isNumber { clean.insert("_", at: 0) }
            return String(clean)
        }
        return segments.joined(separator: ".")
    }

    // MARK: - Helpers

    public static func lowercasedAlphanumeric(_ value: String, fallback: String) -> String {
        let cleaned = value.lowercased().filter { ($0.isLetter && $0.isASCII) || $0.isNumber }
        return cleaned.isEmpty ? fallback : cleaned
    }

    static func isValidIdentifier(_ identifier: String) -> Bool {
        let segments = identifier.split(separator: ".", omittingEmptySubsequences: false)
        guard segments.count >= 2 else { return false }
        for segment in segments {
            guard !segment.isEmpty,
                  segment.allSatisfy({ ($0.isLetter && $0.isASCII) || $0.isNumber || $0 == "_" || $0 == "-" })
            else { return false }
        }
        return true
    }
}

// MARK: - PackagingError

public enum PackagingError: Error, Equatable, CustomStringConvertible {
    case invalidAppName(String)
    case invalidIdentifier(String)
    case invalidRemoteURL(String)
    case staticExportMissing(String)
    case sourcesDirectoryMissing(String)
    case manifestPatchFailed(String)

    public var description: String {
        switch self {
        case .invalidAppName(let name):
            return "Invalid app name: '\(name)'. Provide a non-empty name via --name."
        case .invalidIdentifier(let id):
            return "Invalid identifier: '\(id)'. Use reverse-DNS form, e.g. com.example.myapp."
        case .invalidRemoteURL(let url):
            return "Invalid remote URL: '\(url)'. Use an absolute http(s) URL."
        case .staticExportMissing(let path):
            return "No static export found at '\(path)'. Run `score build` first, or pass --url to load a deployed server instead."
        case .sourcesDirectoryMissing(let path):
            return "Sources directory not found at '\(path)'."
        case .manifestPatchFailed(let reason):
            return "Could not update Package.swift: \(reason)"
        }
    }
}
