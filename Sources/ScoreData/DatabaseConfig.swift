import Foundation

/// Configuration for a database backend.
public protocol DatabaseConfig: Sendable {
    /// Create a database context connected to this backend.
    func makeContext() async throws -> DatabaseContext
}

/// SQLite database configuration.
public struct SQLiteDatabase: DatabaseConfig {
    public let path: String

    public init(path: String) { self.path = path }

    public func makeContext() async throws -> DatabaseContext {
        try await DatabaseContext.sqlite(path: path)
    }
}

/// In-memory SQLite database (for testing).
public struct InMemoryDatabase: DatabaseConfig {
    public init() {}

    public func makeContext() async throws -> DatabaseContext {
        try await DatabaseContext.sqlite(path: ":memory:")
    }
}
