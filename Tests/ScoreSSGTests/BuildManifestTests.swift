import Foundation
import Testing

@testable import ScoreSSG

@Suite("AssetManifest")
struct BuildManifestTests {
    @Test("initializes with defaults")
    func defaultInit() {
        let manifest = AssetManifest()
        #expect(manifest.assets.isEmpty)
        #expect(manifest.pages.isEmpty)
        #expect(!manifest.requiresServer)
    }

    @Test("round-trips through ManifestWriter")
    func writeAndRead() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-manifest-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        var manifest = AssetManifest()
        manifest.assets["styles.css"] = "styles.abc123.css"
        manifest.pages = ["/", "/about", "/blog"]
        manifest.requiresServer = false

        let writer = ManifestWriter()
        try writer.write(manifest, to: tempDir)

        let loaded = try writer.read(from: tempDir)
        #expect(loaded.assets["styles.css"] == "styles.abc123.css")
        #expect(loaded.pages.count == 3)
        #expect(loaded.pages.contains("/about"))
        #expect(!loaded.requiresServer)
    }

    @Test("manifest file is valid JSON")
    func manifestIsJSON() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-json-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let manifest = AssetManifest(assets: ["a.css": "a.abc.css"], pages: ["/"])
        let writer = ManifestWriter()
        try writer.write(manifest, to: tempDir)

        let data = try Data(contentsOf: tempDir.appendingPathComponent("asset-manifest.json"))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json != nil)
        #expect(json?["pages"] != nil)
    }
}
