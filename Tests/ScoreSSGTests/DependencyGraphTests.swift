import Foundation
import Testing

@testable import ScoreSSG

@Suite("DependencyGraph")
struct DependencyGraphTests {
    func makeGraph() -> DependencyGraph {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-depgraph-\(UUID().uuidString)")
        return DependencyGraph(cacheDirectory: tempDir)
    }

    @Test("adds and queries dependencies")
    func addAndQuery() async {
        let graph = makeGraph()
        await graph.addDependency(page: "/blog/hello", dependsOn: "Content/hello.md")
        let pages = await graph.pagesAffectedBy(file: "Content/hello.md")
        #expect(pages.contains("/blog/hello"))
    }

    @Test("returns empty array for unknown file")
    func unknownFile() async {
        let graph = makeGraph()
        let pages = await graph.pagesAffectedBy(file: "nonexistent.md")
        #expect(pages.isEmpty)
    }

    @Test("clears dependencies for a page")
    func clearPage() async {
        let graph = makeGraph()
        await graph.addDependency(page: "/page", dependsOn: "file.md")
        await graph.clearDependencies(for: "/page")
        let pages = await graph.pagesAffectedBy(file: "file.md")
        #expect(!pages.contains("/page"))
    }

    @Test("persists and reloads")
    func persistAndReload() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-persist-\(UUID().uuidString)")
        let graph = DependencyGraph(cacheDirectory: tempDir)

        await graph.addDependency(page: "/a", dependsOn: "a.md")
        await graph.addDependency(page: "/b", dependsOn: "b.md")
        try await graph.save()

        let loaded = DependencyGraph(cacheDirectory: tempDir)
        try await loaded.load()

        let pages = await loaded.pagesAffectedBy(file: "a.md")
        #expect(pages.contains("/a"))

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("allPages returns sorted list")
    func allPagesSorted() async {
        let graph = makeGraph()
        await graph.addDependency(page: "/z", dependsOn: "z.md")
        await graph.addDependency(page: "/a", dependsOn: "a.md")
        let pages = await graph.allPages
        #expect(pages == pages.sorted())
    }
}
