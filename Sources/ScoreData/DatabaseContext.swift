import Foundation

/// The primary interface for database operations in route handlers and server actions.
///
/// Obtain a `DatabaseContext` from your `DatabaseConfig` and pass it to your
/// handlers — or store it in a `RequestContext` extension for implicit access.
///
/// ```swift
/// GET("/blog") { req in
///     let posts = try await db.query(Post.self)
///         .filter(\.published == true)
///         .orderBy(\.createdAt, .descending)
///         .all()
///     return BlogIndexPage(posts: posts)
/// }
/// ```
public actor DatabaseContext {
    private let connection: SQLiteConnection

    private init(connection: SQLiteConnection) {
        self.connection = connection
    }

    /// Create a context backed by a SQLite file (or `:memory:` for testing).
    public static func sqlite(path: String) async throws -> DatabaseContext {
        let conn = try await SQLiteConnection(path: path)
        return DatabaseContext(connection: conn)
    }

    // MARK: - Query

    /// Start a fluent query for the given `Record` type.
    ///
    /// ```swift
    /// try await db.query(Post.self).filter(\.published == true).all()
    /// ```
    public func query<R: Record>(_ type: R.Type) -> QueryBuilder<R> {
        QueryBuilder(connection: connection)
    }

    /// Find a single record by its UUID primary key.
    ///
    /// Returns `nil` when no record with the given `id` exists.
    public func find<R: Record>(_ type: R.Type, id: UUID) async throws -> R? {
        try await query(type).filter(\R.id == id).first()
    }

    // MARK: - Mutations

    /// Insert a new record.
    ///
    /// `createdAt` is preserved if already set; `updatedAt` is always refreshed.
    @discardableResult
    public func insert<R: Record>(_ record: R) async throws -> R {
        var r = record
        if r.createdAt == .distantPast { r.createdAt = .now }
        r.updatedAt = .now
        try await connection.insert(r)
        return r
    }

    /// Update an existing record, refreshing `updatedAt`.
    public func update<R: Record>(_ record: R) async throws {
        var r = record
        r.updatedAt = .now
        try await connection.update(r)
    }

    /// Update a record by applying a mutation closure, then persist.
    ///
    /// ```swift
    /// try await db.update(post) { $0.published = true }
    /// ```
    public func update<R: Record>(_ record: R, _ mutations: @Sendable (inout R) -> Void) async throws {
        var r = record
        mutations(&r)
        r.updatedAt = .now
        try await connection.update(r)
    }

    /// Delete a record of the given type by its UUID.
    public func delete<R: Record>(_ type: R.Type, id: UUID) async throws {
        try await connection.delete(type, id: id)
    }

    // MARK: - Transactions

    /// Execute a closure within a database transaction.
    ///
    /// The transaction is committed on success and rolled back on any thrown error.
    ///
    /// ```swift
    /// let post = try await db.transaction { tx in
    ///     let p = try await tx.insert(draft)
    ///     try await tx.update(author)
    ///     return p
    /// }
    /// ```
    public func transaction<T: Sendable>(
        _ block: @Sendable (DatabaseTransaction) async throws -> T
    ) async throws -> T {
        try await connection.beginTransaction()
        let tx = DatabaseTransaction(connection: connection)
        do {
            let result = try await block(tx)
            try await connection.commitTransaction()
            return result
        } catch {
            try? await connection.rollbackTransaction()
            throw error
        }
    }

    // MARK: - Raw SQL

    /// Execute raw SQL and return rows as dictionaries.
    ///
    /// Prefer the fluent API for type-safe access.
    public func raw(_ sql: String, parameters: [SQLValue] = []) async throws -> [[String: SQLValue]] {
        try await connection.execute(sql, parameters: parameters)
    }

    // MARK: - Schema

    /// Create the table for a `Record` type if it does not yet exist.
    ///
    /// Call this at app startup before issuing any queries against the table.
    ///
    /// ```swift
    /// try await db.createTableIfNeeded(for: Post.self)
    /// ```
    public func createTableIfNeeded<R: Record>(for type: R.Type) async throws {
        try await connection.createTable(for: type)
    }
}
