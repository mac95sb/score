import Foundation

/// A chainable query builder for fetching records from the database.
///
/// All filter/order/limit/offset calls return a new `QueryBuilder` value;
/// nothing is sent to the database until a terminal method (`all()`, `first()`,
/// `count()`, `exists()`, or `delete()`) is called.
///
/// ```swift
/// let posts = try await db.query(Post.self)
///     .filter(\.published == true)
///     .orderBy(\.createdAt, .descending)
///     .limit(10)
///     .all()
/// ```
public struct QueryBuilder<R: Record>: Sendable {
    let connection: SQLiteConnection
    var filters: [String] = []
    var filterParams: [SQLValue] = []
    var orderByClause: String? = nil
    var limitValue: Int? = nil
    var offsetValue: Int? = nil

    init(connection: SQLiteConnection) {
        self.connection = connection
    }

    // MARK: - Filtering

    /// Filter using a `KeyPathCondition` produced by the `==` operator.
    ///
    /// ```swift
    /// .filter(\.published == true)
    /// .filter(\.slug == "hello-world")
    /// ```
    public func filter<V: Codable & Sendable & Equatable>(_ condition: KeyPathCondition<R, V>) -> QueryBuilder<R> {
        var copy = self
        copy.filters.append("json_extract(data, \(jsonExtractPath(forKey: condition.keyName))) = ?")
        // Encode value to a JSON-compatible SQLValue
        if let strVal = condition.value as? String {
            copy.filterParams.append(strVal)
        } else if let boolVal = condition.value as? Bool {
            // SQLite stores booleans as integers; JSON booleans are true/false strings
            // json_extract returns 1/0 for JSON booleans
            copy.filterParams.append(boolVal ? 1 : 0)
        } else if let intVal = condition.value as? Int {
            copy.filterParams.append(intVal)
        } else if let doubleVal = condition.value as? Double {
            copy.filterParams.append(doubleVal)
        } else if let uuid = condition.value as? UUID {
            copy.filterParams.append(uuid.uuidString)
        } else if let date = condition.value as? Date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            copy.filterParams.append(formatter.string(from: date))
        } else {
            // Generic Codable fallback: encode to JSON scalar string
            let encoded = (try? JSONEncoder().encode(condition.value))
                .flatMap { String(data: $0, encoding: .utf8) }
            copy.filterParams.append(encoded)
        }
        return copy
    }

    // MARK: - Eager loading

    /// Declare a related record type to eagerly load alongside results.
    ///
    /// `include` is a *hint* that the query should side-load `Related` records
    /// matched by the foreign-key field at `keyPath`.  In the JSON document store
    /// backend this is a no-op (relations are embedded); it exists so application
    /// code written against a future relational backend compiles without changes.
    ///
    /// ```swift
    /// let posts = try await db.query(Post.self)
    ///     .include(Author.self, on: \.authorId)
    ///     .all()
    /// ```
    public func include<Related: Record>(
        _ type: Related.Type,
        on keyPath: KeyPath<R, UUID?> & Sendable
    ) -> QueryBuilder<R> {
        self
    }

    /// Overload for non-optional foreign keys.
    public func include<Related: Record>(
        _ type: Related.Type,
        on keyPath: KeyPath<R, UUID> & Sendable
    ) -> QueryBuilder<R> {
        self
    }

    // MARK: - Ordering

    /// Order results by the field extracted from the JSON data column.
    public func orderBy<V: Comparable & Sendable>(
        _ keyPath: KeyPath<R, V> & Sendable,
        _ order: SortOrder = .ascending
    ) -> QueryBuilder<R> {
        var copy = self
        let field = keyPathName(keyPath)
        let dir = order == .ascending ? "ASC" : "DESC"
        copy.orderByClause = "json_extract(data, \(jsonExtractPath(forKey: field))) \(dir)"
        return copy
    }

    // MARK: - Pagination

    /// Limit the number of results returned.
    public func limit(_ n: Int) -> QueryBuilder<R> {
        var copy = self
        copy.limitValue = n
        return copy
    }

    /// Skip the first N matching results.
    public func offset(_ n: Int) -> QueryBuilder<R> {
        var copy = self
        copy.offsetValue = n
        return copy
    }

    // MARK: - Terminal methods

    /// Fetch all matching records.
    public func all() async throws -> [R] {
        try await connection.query(R.self, sql: buildSQL(), parameters: filterParams)
    }

    /// Fetch the first matching record, or `nil` if none match.
    public func first() async throws -> R? {
        try await limit(1).all().first
    }

    /// Return the number of records matching the current filters.
    public func count() async throws -> Int {
        let rows = try await connection.execute(buildCountSQL(), parameters: filterParams)
        return rows.first?["count"] as? Int ?? 0
    }

    /// Return `true` if at least one record matches the current filters.
    public func exists() async throws -> Bool {
        try await count() > 0
    }

    /// Delete all records matching the current filters.
    public func delete() async throws {
        let whereClause = filters.isEmpty ? "" : " WHERE \(filters.joined(separator: " AND "))"
        let sql = "DELETE FROM \(R.quotedTableName)\(whereClause)"
        _ = try await connection.execute(sql, parameters: filterParams)
    }

    // MARK: - SQL Construction

    private func buildSQL() -> String {
        var sql = "SELECT * FROM \(R.quotedTableName)"
        if !filters.isEmpty {
            sql += " WHERE \(filters.joined(separator: " AND "))"
        }
        if let order = orderByClause {
            sql += " ORDER BY \(order)"
        }
        if let limit = limitValue {
            sql += " LIMIT \(limit)"
        }
        if let offset = offsetValue {
            sql += " OFFSET \(offset)"
        }
        return sql
    }

    private func buildCountSQL() -> String {
        var sql = "SELECT COUNT(*) AS count FROM \(R.quotedTableName)"
        if !filters.isEmpty {
            sql += " WHERE \(filters.joined(separator: " AND "))"
        }
        return sql
    }
}

// MARK: - Sort order

public enum SortOrder: Sendable {
    case ascending
    case descending
}

// MARK: - KeyPathCondition

/// A pre-built filter condition produced by the `==` operator on a key path.
///
/// ```swift
/// let condition: KeyPathCondition<Post, Bool> = \.published == true
/// ```
public struct KeyPathCondition<R: Record, V: Sendable>: Sendable {
    /// The JSON field name extracted from `R`'s data column.
    public let keyName: String
    /// The expected value.
    public let value: V
}

/// Produce a `KeyPathCondition` from a `KeyPath` and an expected value.
///
/// ```swift
/// .filter(\.published == true)
/// .filter(\.id == someUUID)
/// ```
public func == <R: Record, V: Codable & Sendable & Equatable>(
    lhs: KeyPath<R, V> & Sendable,
    rhs: V
) -> KeyPathCondition<R, V> {
    KeyPathCondition(keyName: keyPathName(lhs), value: rhs)
}

// MARK: - Key path name helper

/// Extract the property name from a `KeyPath` description.
///
/// Swift's `KeyPath` `debugDescription` is of the form `\Root.property`, so we
/// strip everything up to and including the last `.`.
///
/// For example: `\Post.published` → `"published"`
func keyPathName<Root, Value>(_ keyPath: KeyPath<Root, Value>) -> String {
    let desc = "\(keyPath)"
    if let dotIndex = desc.lastIndex(of: ".") {
        return String(desc[desc.index(after: dotIndex)...])
    }
    return desc
}
