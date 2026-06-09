import Testing
@testable import ScoreBuild
import Foundation

@Suite("AssetFingerprinter")
struct AssetFingerprinterTests {
    let fp = AssetFingerprinter()

    @Test("inserts 8-character hash before extension")
    func hashInsertion() {
        let data = "body { margin: 0; }".data(using: .utf8)!
        let (name, _) = fp.fingerprint(content: data, originalFilename: "styles.css")
        let parts = name.components(separatedBy: ".")
        // styles.<8chars>.css → 3 parts
        #expect(parts.count == 3)
        #expect(parts[0] == "styles")
        #expect(parts[1].count == 8)
        #expect(parts[2] == "css")
    }

    @Test("same content produces same hash")
    func deterministicHash() {
        let data = "const x = 1;".data(using: .utf8)!
        let (name1, _) = fp.fingerprint(content: data, originalFilename: "app.js")
        let (name2, _) = fp.fingerprint(content: data, originalFilename: "app.js")
        #expect(name1 == name2)
    }

    @Test("different content produces different hash")
    func uniqueHash() {
        let data1 = "version: 1".data(using: .utf8)!
        let data2 = "version: 2".data(using: .utf8)!
        let (name1, _) = fp.fingerprint(content: data1, originalFilename: "v.txt")
        let (name2, _) = fp.fingerprint(content: data2, originalFilename: "v.txt")
        #expect(name1 != name2)
    }

    @Test("handles filename without extension")
    func noExtension() {
        let data = "bin".data(using: .utf8)!
        let (name, _) = fp.fingerprint(content: data, originalFilename: "binary")
        #expect(name.contains("."))
        #expect(!name.hasSuffix("."))
    }

    @Test("writes fingerprinted file to disk")
    func writesToDisk() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("fp-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let content = "h1 { font-size: 2rem; }".data(using: .utf8)!
        let written = try fp.writeWithFingerprint(
            content: content,
            originalFilename: "headings.css",
            to: tempDir
        )

        #expect(written.hasPrefix("headings."))
        #expect(written.hasSuffix(".css"))
        let fileURL = tempDir.appendingPathComponent(written)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
