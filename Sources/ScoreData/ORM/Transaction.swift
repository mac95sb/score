import Foundation

/// A database transaction context.
///
/// Use within a `db.transaction { tx in ... }` block to ensure atomicity.
/// All operations on the transaction are serialised through the underlying
/// `SQLiteConnection` actor, so they execute without interleaving.
///
/// ```swift
/// let post = try await db.transaction { tx in
///     let p = try await tx.insert(draft)
///     try await tx.update(author)
///     return p
/// }
/// ```
public actor DatabaseTransaction {
    private let connection: SQLiteConnection

    init(connection: SQLiteConnection) {
        self.connection = connection
    }

    // MARK: - Insert

    /// Insert a record within the transaction, stamping `updatedAt` to now.
    @discardableResult
    public func insert<R: Record>(_ record: R) async throws -> R {
        var r = record
        r.updatedAt = .now
        try await connection.insert(r)
        return r
    }

    // MARK: - Update

    /// Update a record within the transaction, stamping `updatedAt` to now.
    public func update<R: Record>(_ record: R) async throws {
        var r = record
        r.updatedAt = .now
        try await connection.update(r)
    }

    /// Update a record using a mutation closure, then persist.
    public func update<R: Record>(_ record: R, _ mutations: @Sendable (inout R) -> Void) async throws {
        var r = record
        mutations(&r)
        r.updatedAt = .now
        try await connection.update(r)
    }

    // MARK: - Delete

    /// Delete a record of the given type by its UUID.
    public func delete<R: Record>(_ type: R.Type, id: UUID) async throws {
        try await connection.delete(type, id: id)
    }

    // MARK: - Query

    /// Run a fluent query within the transaction context.
    public func query<R: Record>(_ type: R.Type) -> QueryBuilder<R> {
        QueryBuilder(connection: connection)
    }

    /// Find a record by its primary key within the transaction.
    public func find<R: Record>(_ type: R.Type, id: UUID) async throws -> R? {
        try await query(type).filter(\R.id == id).first()
    }

    // MARK: - Raw SQL

    /// Execute raw SQL within the transaction and return result rows.
    public func raw(_ sql: String, parameters: [SQLValue] = []) async throws -> [[String: SQLValue]] {
        try await connection.execute(sql, parameters: parameters)
    }
}
