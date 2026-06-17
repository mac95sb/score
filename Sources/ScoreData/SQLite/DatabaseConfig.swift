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

/// The placeholder configuration used when an application declares no database.
///
/// `Application.database` defaults to `NoDatabase`; the runtime skips database
/// bootstrap entirely when it sees this type. Calling `makeContext()` throws.
public struct NoDatabase: DatabaseConfig {
    public struct NotConfigured: Error, CustomStringConvertible {
        public var description: String {
            "No database configured — declare `var database` on your Application."
        }
    }

    public init() {}

    public func makeContext() async throws -> DatabaseContext {
        throw NotConfigured()
    }
}
