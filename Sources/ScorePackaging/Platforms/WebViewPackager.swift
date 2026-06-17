import Foundation

// MARK: - PackagingPlatform

/// Native platforms Score can generate WebView shell projects for.
public enum PackagingPlatform: String, Sendable, CaseIterable {
    case windows
    case android
    case linux
}

// MARK: - PackagedApp

/// The result of a packaging run.
public struct PackagedApp: Sendable {
    public let platform: PackagingPlatform
    /// Root directory of the generated project.
    public let outputDirectory: URL
    /// Relative paths of every file written.
    public let filesWritten: [String]
    /// Human-readable build instructions for the generated project.
    public let nextSteps: String

    public init(
        platform: PackagingPlatform,
        outputDirectory: URL,
        filesWritten: [String],
        nextSteps: String
    ) {
        self.platform        = platform
        self.outputDirectory = outputDirectory
        self.filesWritten    = filesWritten
        self.nextSteps       = nextSteps
    }
}

// MARK: - WebViewPackager

/// A generator that wraps a Score app in a native WebView shell project.
///
/// Packagers emit a complete, buildable project for their platform's standard
/// toolchain (MSBuild/.NET, Gradle, or make) — Score does not cross-compile
/// the native shell itself.
public protocol WebViewPackager: Sendable {
    var platform: PackagingPlatform { get }

    /// Generate the shell project into `outputDirectory` (created if needed).
    func package(config: PackagingConfig, into outputDirectory: URL) throws -> PackagedApp
}

// MARK: - ProjectWriter

/// Writes generated project files under a root directory and records
/// the relative path of everything written.
struct ProjectWriter {
    let root: URL
    private(set) var written: [String] = []
    /// Subset of `written` whose on-disk content actually changed.
    private(set) var changed: [String] = []

    init(root: URL) throws {
        self.root = root
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    mutating func write(_ content: String, to relativePath: String) throws {
        let target = root.appendingPathComponent(relativePath)
        written.append(relativePath)

        // Skip identical rewrites so repeated generation (e.g. the dev-server
        // regenerating an embedded kit) doesn't churn modification dates and
        // retrigger file watchers.
        if let existing = try? String(contentsOf: target, encoding: .utf8), existing == content {
            return
        }
        try FileManager.default.createDirectory(
            at: target.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try content.write(to: target, atomically: true, encoding: .utf8)
        changed.append(relativePath)
    }

    /// Copy the contents of a static export directory into `relativePath`.
    mutating func copyStaticExport(from sourcePath: String, to relativePath: String) throws {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: sourcePath, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw PackagingError.staticExportMissing(sourcePath)
        }

        let sourceURL = URL(fileURLWithPath: sourcePath)
        let targetURL = root.appendingPathComponent(relativePath)
        if fm.fileExists(atPath: targetURL.path) {
            try fm.removeItem(at: targetURL)
        }
        try fm.createDirectory(at: targetURL, withIntermediateDirectories: true)

        for item in try fm.contentsOfDirectory(atPath: sourcePath).sorted() {
            try fm.copyItem(
                at: sourceURL.appendingPathComponent(item),
                to: targetURL.appendingPathComponent(item)
            )
        }
        written.append(relativePath + "/")
    }
}
