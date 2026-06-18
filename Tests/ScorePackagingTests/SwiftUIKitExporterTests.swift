import Foundation
import Testing

@testable import ScorePackaging

@Suite("SwiftUIKitExporter")
struct SwiftUIKitExporterTests {

    static let appSource = """
        import Score
        import Foundation

        struct Post: Record {
            var id: UUID = UUID()
            var title: String
            var slug: String
            var published: Bool = false
            var createdAt: Date = .now
            var updatedAt: Date = .now

            var excerpt: String { String(title.prefix(80)) }
        }

        struct PostsController: RouteCollection {
            var routes: [Route] {
                [
                    Route(method: .GET,    pathPattern: "/posts",     handler: list),
                    Route(method: .GET,    pathPattern: "/posts/:id", handler: show),
                    Route(method: .POST,   pathPattern: "/posts",     handler: create),
                    Route(method: .DELETE, pathPattern: "/posts/:id", handler: delete),
                ]
            }
        }
        """

    private func makeExporter() -> SwiftUIKitExporter {
        SwiftUIKitExporter(options: .init(kitName: "DemoKit"))
    }

    // MARK: - Parsing

    @Test("parses record properties, skipping computed ones")
    func recordParsing() {
        let records = makeExporter().parseRecords(in: Self.appSource)
        #expect(records.count == 1)
        let post = records[0]
        #expect(post.name == "Post")
        #expect(post.properties.map(\.name) == ["id", "title", "slug", "published", "createdAt", "updatedAt"])
        #expect(post.properties[1].type == "String")
        #expect(post.properties[3].defaultValue == "false")
    }

    @Test("parses controller routes with handler names and path parameters")
    func controllerParsing() {
        let controllers = makeExporter().parseControllers(in: Self.appSource)
        #expect(controllers.count == 1)
        let controller = controllers[0]
        #expect(controller.name == "PostsController")
        #expect(controller.namespace == "Posts")
        #expect(controller.endpoints.count == 4)
        #expect(controller.endpoints[0].name == "list")
        #expect(controller.endpoints[1].name == "show")
        #expect(controller.endpoints[1].pathParameters == ["id"])
    }

    // MARK: - Export

    @Test("exports a complete standalone Swift package")
    func export() throws {
        let fm = FileManager.default
        let workDir = fm.temporaryDirectory
            .appendingPathComponent("score-export-\(UUID().uuidString)")
        let sourcesDir = workDir.appendingPathComponent("Sources/App")
        let outputDir = workDir.appendingPathComponent("dist/DemoKit")
        try fm.createDirectory(at: sourcesDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: workDir) }

        try Self.appSource.write(
            to: sourcesDir.appendingPathComponent("App.swift"), atomically: true, encoding: .utf8)

        let exporter = SwiftUIKitExporter(
            options: .init(
                kitName: "DemoKit",
                sourcesDirectory: workDir.appendingPathComponent("Sources").path
            ))
        let result = try exporter.export(into: outputDir)

        #expect(result.recordNames == ["Post"])
        #expect(result.controllerNames == ["PostsController"])
        #expect(result.endpointCount == 4)

        func read(_ relative: String) throws -> String {
            try String(contentsOf: outputDir.appendingPathComponent(relative), encoding: .utf8)
        }

        let model = try read("Sources/DemoKit/Models/Post.swift")
        #expect(model.contains("public struct Post: Record"))
        #expect(model.contains("public var title: String"))
        #expect(model.contains("public init("))
        #expect(model.contains("published: Bool = false"))
        #expect(!model.contains("excerpt"))

        let endpoints = try read("Sources/DemoKit/Endpoints.swift")
        #expect(endpoints.contains("public enum Posts"))
        #expect(endpoints.contains("public static var list: Endpoint { Endpoint(.get, \"/posts\") }"))
        #expect(endpoints.contains("public static func show(id: String) -> Endpoint { Endpoint(.get, \"/posts/\\(id)\") }"))

        let client = try read("Sources/DemoKit/ScoreAPIClient.swift")
        #expect(client.contains("public struct ScoreAPIClient"))

        let shim = try read("Sources/DemoKit/ScoreRecord.swift")
        #expect(shim.contains("public protocol Record"))

        let manifest = try read("Package.swift")
        #expect(manifest.contains("name: \"DemoKit\""))
    }

    @Test("missing sources directory throws")
    func missingSources() {
        let exporter = SwiftUIKitExporter(
            options: .init(
                kitName: "DemoKit",
                sourcesDirectory: "/nonexistent/sources"
            ))
        #expect(throws: PackagingError.sourcesDirectoryMissing("/nonexistent/sources")) {
            _ = try exporter.export(
                into: FileManager.default.temporaryDirectory
                    .appendingPathComponent("score-export-fail"))
        }
    }
}
