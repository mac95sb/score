import Foundation
import Testing
@testable import ScorePackaging

@Suite("Embedded kit export")
struct EmbeddedKitTests {

    static let appSource = """
    import Score
    import Foundation

    struct Post: Record {
        var id: UUID = UUID()
        var title: String
        var createdAt: Date = .now
        var updatedAt: Date = .now
    }

    struct PostsController: RouteCollection {
        var routes: [Route] {
            [Route(method: .GET, pathPattern: "/posts", handler: list)]
        }
    }
    """

    private func makeProject() throws -> URL {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("score-embedded-\(UUID().uuidString)")
        try fm.createDirectory(
            at: root.appendingPathComponent("Sources/App"), withIntermediateDirectories: true)
        try Self.appSource.write(
            to: root.appendingPathComponent("Sources/App/App.swift"), atomically: true, encoding: .utf8)
        return root
    }

    @Test("exportTarget writes kit sources directly into the target directory")
    func exportTarget() throws {
        let root = try makeProject()
        defer { try? FileManager.default.removeItem(at: root) }

        let exporter = SwiftUIKitExporter(options: .init(
            kitName: "AppKit",
            sourcesDirectory: root.appendingPathComponent("Sources").path,
            excludedDirectories: ["AppKit"]
        ))
        let target = root.appendingPathComponent("Sources/AppKit")
        let result = try exporter.exportTarget(into: target)

        #expect(result.recordNames == ["Post"])
        #expect(result.filesWritten.contains("ScoreRecord.swift"))
        #expect(result.filesWritten.contains("Models/Post.swift"))
        // No standalone package scaffolding in embedded mode.
        #expect(!result.filesWritten.contains("Package.swift"))
        #expect(!FileManager.default.fileExists(atPath: target.appendingPathComponent("Package.swift").path))
    }

    @Test("regeneration excludes the kit's own generated models")
    func excludesOwnModels() throws {
        let root = try makeProject()
        defer { try? FileManager.default.removeItem(at: root) }
        let sourcesPath = root.appendingPathComponent("Sources").path

        let exporter = SwiftUIKitExporter(options: .init(
            kitName: "AppKit",
            sourcesDirectory: sourcesPath,
            excludedDirectories: ["AppKit"]
        ))
        let target = root.appendingPathComponent("Sources/AppKit")
        _ = try exporter.exportTarget(into: target)
        // Second run scans a tree that now contains the generated kit; the
        // exclusion must keep the result identical instead of doubling up.
        let second = try exporter.exportTarget(into: target)
        #expect(second.recordNames == ["Post"])
    }

    @Test("exportTarget removes stale generated models")
    func removesStaleModels() throws {
        let root = try makeProject()
        defer { try? FileManager.default.removeItem(at: root) }

        let exporter = SwiftUIKitExporter(options: .init(
            kitName: "AppKit",
            sourcesDirectory: root.appendingPathComponent("Sources").path,
            excludedDirectories: ["AppKit"]
        ))
        let target = root.appendingPathComponent("Sources/AppKit")
        let stale = target.appendingPathComponent("Models/Deleted.swift")
        try FileManager.default.createDirectory(
            at: target.appendingPathComponent("Models"), withIntermediateDirectories: true)
        try "public struct Deleted {}".write(to: stale, atomically: true, encoding: .utf8)

        _ = try exporter.exportTarget(into: target)
        #expect(!FileManager.default.fileExists(atPath: stale.path))
    }

    @Test("KitRegenerator regenerates targets carrying the generated marker")
    func regenerator() throws {
        let root = try makeProject()
        defer { try? FileManager.default.removeItem(at: root) }
        let sourcesPath = root.appendingPathComponent("Sources").path

        // No kit yet — nothing to regenerate.
        #expect(KitRegenerator.regenerateEmbeddedKits(sourcesDirectory: sourcesPath).isEmpty)

        let exporter = SwiftUIKitExporter(options: .init(
            kitName: "AppKit",
            sourcesDirectory: sourcesPath,
            excludedDirectories: ["AppKit"]
        ))
        _ = try exporter.exportTarget(into: root.appendingPathComponent("Sources/AppKit"))

        // Add a record, then regenerate.
        let newRecord = """
        import Foundation
        struct Comment: Record {
            var id: UUID = UUID()
            var body: String
            var createdAt: Date = .now
            var updatedAt: Date = .now
        }
        """
        try newRecord.write(
            to: root.appendingPathComponent("Sources/App/Comment.swift"),
            atomically: true, encoding: .utf8)

        let regenerated = KitRegenerator.regenerateEmbeddedKits(sourcesDirectory: sourcesPath)
        #expect(regenerated == ["AppKit"])
        let commentModel = root.appendingPathComponent("Sources/AppKit/Models/Comment.swift")
        #expect(FileManager.default.fileExists(atPath: commentModel.path))
    }
}

@Suite("PackageManifestPatcher")
struct PackageManifestPatcherTests {

    static let scaffoldManifest = """
    // swift-tools-version: 6.0
    import PackageDescription

    let package = Package(
        name: "MyApp",
        platforms: [.macOS(.v15)],
        dependencies: [
            .package(url: "https://github.com/mac95sb/score.git", branch: "main"),
        ],
        targets: [
            .executableTarget(
                name: "MyApp",
                dependencies: [
                    .product(name: "Score", package: "score"),
                ]
            ),
        ]
    )
    """

    private func writeManifest(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-manifest-\(UUID().uuidString).swift")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @Test("adds a products section and target to a scaffolded manifest")
    func patchScaffold() throws {
        let url = try writeManifest(Self.scaffoldManifest)
        defer { try? FileManager.default.removeItem(at: url) }

        let changed = try PackageManifestPatcher.addLibraryTarget(named: "MyAppKit", toManifestAt: url)
        #expect(changed)

        let patched = try String(contentsOf: url, encoding: .utf8)
        #expect(patched.contains(".library(name: \"MyAppKit\", targets: [\"MyAppKit\"])"))
        #expect(patched.contains(".target(name: \"MyAppKit\")"))
        #expect(patched.contains("products: ["))
        // products section must precede the targets section it references.
        let productsIndex = try #require(patched.range(of: "products: [")).lowerBound
        let targetsIndex = try #require(patched.range(of: "targets: [")).lowerBound
        #expect(productsIndex < targetsIndex)
    }

    @Test("is idempotent")
    func idempotent() throws {
        let url = try writeManifest(Self.scaffoldManifest)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(try PackageManifestPatcher.addLibraryTarget(named: "MyAppKit", toManifestAt: url))
        let afterFirst = try String(contentsOf: url, encoding: .utf8)
        #expect(try !PackageManifestPatcher.addLibraryTarget(named: "MyAppKit", toManifestAt: url))
        let afterSecond = try String(contentsOf: url, encoding: .utf8)
        #expect(afterFirst == afterSecond)
    }

    @Test("inserts into an existing products section")
    func existingProducts() throws {
        let manifest = """
        let package = Package(
            name: "MyApp",
            products: [
                .executable(name: "myapp", targets: ["MyApp"]),
            ],
            targets: [
                .executableTarget(name: "MyApp"),
            ]
        )
        """
        let url = try writeManifest(manifest)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(try PackageManifestPatcher.addLibraryTarget(named: "MyAppKit", toManifestAt: url))
        let patched = try String(contentsOf: url, encoding: .utf8)
        #expect(patched.contains(".library(name: \"MyAppKit\", targets: [\"MyAppKit\"])"))
        // The existing executable product is untouched.
        #expect(patched.contains(".executable(name: \"myapp\", targets: [\"MyApp\"])"))
    }
}
