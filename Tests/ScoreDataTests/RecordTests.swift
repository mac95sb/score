import Foundation
import Testing

@testable import ScoreData

// MARK: - Sample Record

struct Article: Record {
    static let tableName = "articles"
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var title: String
    var body: String
    var views: Int

    init(title: String, body: String = "", views: Int = 0) {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.title = title
        self.body = body
        self.views = views
    }
}

// MARK: - Tests

@Suite("Record Protocol")
struct RecordTests {

    // MARK: - Protocol conformance

    @Test("Record has expected table name")
    func tableName() {
        #expect(Article.tableName == "articles")
    }

    @Test("quotedTableName wraps and escapes the identifier")
    func quotedTableName() {
        #expect(Article.quotedTableName == "\"articles\"")
    }

    @Test("jsonExtractPath escapes the key against SQL/JSON-path injection")
    func jsonPathEscaping() {
        // Normal key is double-quoted as a literal JSON object label.
        #expect(jsonExtractPath(forKey: "title") == "'$.\"title\"'")
        // A single quote is doubled so it stays inside the SQL string literal
        // instead of terminating it.
        #expect(jsonExtractPath(forKey: "a'b") == "'$.\"a''b\"'")
    }

    @Test("Record generates unique ids on init")
    func uniqueIDs() {
        let a = Article(title: "A")
        let b = Article(title: "B")
        #expect(a.id != b.id)
    }

    @Test("Record timestamps are set on init")
    func timestampsSet() {
        let before = Date()
        let article = Article(title: "Test")
        let after = Date()
        #expect(article.createdAt >= before)
        #expect(article.createdAt <= after)
        #expect(article.updatedAt >= before)
    }

    // MARK: - JSON encoding

    @Test("Record encodes to JSON successfully")
    func jsonEncoding() throws {
        let article = Article(title: "Hello", body: "World", views: 42)
        let encoder = JSONEncoder()
        let data = try encoder.encode(article)
        #expect(!data.isEmpty)
        let json = String(data: data, encoding: .utf8) ?? ""
        #expect(json.contains("Hello"))
        #expect(json.contains("42"))
    }

    @Test("Record round-trips through JSON")
    func jsonRoundTrip() throws {
        let original = Article(title: "Round Trip", body: "content", views: 10)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Article.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.views == original.views)
    }

    // MARK: - CRUD against in-memory SQLite

    @Test("insert and retrieve article from SQLite")
    func insertAndRetrieve() async throws {
        let db = try await DatabaseContext.sqlite(path: ":memory:")
        try await db.createTableIfNeeded(for: Article.self)

        let article = Article(title: "SQLite Test", body: "body text", views: 5)
        let saved = try await db.insert(article)

        let found = try await db.find(Article.self, id: saved.id)
        #expect(found?.title == "SQLite Test")
        #expect(found?.views == 5)
    }

    @Test("update article modifies stored values")
    func updateArticle() async throws {
        let db = try await DatabaseContext.sqlite(path: ":memory:")
        try await db.createTableIfNeeded(for: Article.self)

        let article = try await db.insert(Article(title: "Before"))
        try await db.update(article) { $0.title = "After" }

        let found = try await db.find(Article.self, id: article.id)
        #expect(found?.title == "After")
    }

    @Test("delete removes article from store")
    func deleteArticle() async throws {
        let db = try await DatabaseContext.sqlite(path: ":memory:")
        try await db.createTableIfNeeded(for: Article.self)

        let article = try await db.insert(Article(title: "To Delete"))
        try await db.delete(Article.self, id: article.id)

        let found = try await db.find(Article.self, id: article.id)
        #expect(found == nil)
    }

    @Test("query with orderBy returns sorted results")
    func orderedQuery() async throws {
        let db = try await DatabaseContext.sqlite(path: ":memory:")
        try await db.createTableIfNeeded(for: Article.self)

        _ = try await db.insert(Article(title: "Banana"))
        _ = try await db.insert(Article(title: "Apple"))
        _ = try await db.insert(Article(title: "Cherry"))

        let sorted = try await db.query(Article.self).orderBy(\.title).all()
        #expect(sorted.map(\.title) == ["Apple", "Banana", "Cherry"])
    }
}
