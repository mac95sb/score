import Testing
@testable import ScoreData
import Foundation

// MARK: - Test Record

struct Post: Record {
    static let tableName = "posts"
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var title: String
    var published: Bool

    init(title: String, published: Bool = false) {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.title = title
        self.published = published
    }
}

@Suite("QueryBuilder")
struct QueryBuilderTests {
    func makeDB() async throws -> DatabaseContext {
        try await DatabaseContext.sqlite(path: ":memory:")
    }

    @Test("insert and find by id")
    func insertAndFind() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        let post = Post(title: "Hello")
        let saved = try await db.insert(post)

        // Diagnostic: verify the row exists at all
        let allRows = try await db.raw("SELECT id, data FROM \"posts\"")
        let rowCount = allRows.count
        let storedId = allRows.first?["id"] as? String ?? "<nil>"
        let storedData = allRows.first?["data"] as? String ?? "<nil>"

        // Diagnostic: what does json_extract return?
        let jsonExtractRows = try await db.raw(
            "SELECT json_extract(data, '$.\"id\"') AS extracted_id FROM \"posts\""
        )
        let extractedId = jsonExtractRows.first?["extracted_id"] as? String ?? "<nil>"

        // Diagnostic: what does a string-bound comparison return?
        let matchRows = try await db.raw(
            "SELECT id FROM \"posts\" WHERE json_extract(data, '$.\"id\"') = ?",
            parameters: [saved.id.uuidString]
        )
        let matchCount = matchRows.count

        let found = try await db.find(Post.self, id: saved.id)
        #expect(
            found?.title == "Hello",
            "rowCount=\(rowCount) storedId=\(storedId) storedData=\(storedData) extractedId=\(extractedId) matchCount=\(matchCount) searchId=\(saved.id.uuidString)"
        )
    }

    @Test("query returns all records")
    func queryAll() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        _ = try await db.insert(Post(title: "A"))
        _ = try await db.insert(Post(title: "B"))
        _ = try await db.insert(Post(title: "C"))

        let all = try await db.query(Post.self).all()
        #expect(all.count == 3)
    }

    @Test("filter by boolean field")
    func filterBoolean() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        _ = try await db.insert(Post(title: "Draft", published: false))
        _ = try await db.insert(Post(title: "Live", published: true))

        let published = try await db.query(Post.self).filter(\.published == true).all()
        #expect(published.count == 1)
        #expect(published.first?.title == "Live")
    }

    @Test("limit restricts result count")
    func limitResults() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        for i in 0..<5 {
            _ = try await db.insert(Post(title: "Post \(i)"))
        }
        let limited = try await db.query(Post.self).limit(2).all()
        #expect(limited.count == 2)
    }

    @Test("count returns correct number")
    func countRecords() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        for i in 0..<4 {
            _ = try await db.insert(Post(title: "Post \(i)"))
        }
        let count = try await db.query(Post.self).count()
        #expect(count == 4)
    }

    @Test("update modifies record")
    func updateRecord() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        var post = try await db.insert(Post(title: "Old"))
        try await db.update(post) { $0.title = "New" }

        let found = try await db.find(Post.self, id: post.id)
        #expect(found?.title == "New")
    }

    @Test("delete removes record")
    func deleteRecord() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        let post = try await db.insert(Post(title: "To Delete"))
        try await db.delete(Post.self, id: post.id)

        let found = try await db.find(Post.self, id: post.id)
        #expect(found == nil)
    }

    @Test("exists returns true when record present")
    func existsTrue() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        let post = try await db.insert(Post(title: "Exists"))
        let exists = try await db.query(Post.self).filter(\.id == post.id).exists()
        #expect(exists)
    }

    @Test("exists returns false when absent")
    func existsFalse() async throws {
        let db = try await makeDB()
        try await db.createTableIfNeeded(for: Post.self)

        let exists = try await db.query(Post.self).filter(\.id == UUID()).exists()
        #expect(!exists)
    }
}
