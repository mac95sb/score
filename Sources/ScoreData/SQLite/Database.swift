import Foundation

// MARK: - Global database access

/// Holds the application-wide ``DatabaseContext`` created at startup.
///
/// The Score runtime calls ``bootstrap(_:)`` once, before any route handler
/// runs, using the `Application.database` configuration. Route handlers then
/// reach the database through the global ``db`` property:
///
/// ```swift
/// Page("/blog") { req in
///     let posts = try await db.query(Post.self)
///         .filter(\.published == true)
///         .all()
///     return BlogIndexPage(posts: posts)
/// }
/// ```
public enum Database {
    nonisolated(unsafe) private static var _context: DatabaseContext?
    private static let lock = NSLock()

    /// Install the application-wide database context.
    ///
    /// Called by the Score runtime during startup. Calling it again replaces
    /// the previous context (useful in tests).
    public static func bootstrap(_ context: DatabaseContext) {
        lock.lock()
        defer { lock.unlock() }
        _context = context
    }

    /// Whether ``bootstrap(_:)`` has been called.
    public static var isBootstrapped: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _context != nil
    }

    /// The application-wide database context.
    ///
    /// > Warning: Traps if no database has been bootstrapped. Declare a
    /// > `database` on your `Application` (or call ``bootstrap(_:)`` in tests)
    /// > before touching ``db``.
    public static var context: DatabaseContext {
        lock.lock()
        defer { lock.unlock() }
        guard let context = _context else {
            fatalError("""
                No database configured. Declare `var database: some DatabaseConfig` \
                on your Application, or call Database.bootstrap(_:) before using `db`.
                """)
        }
        return context
    }
}

/// The application's database context — shorthand for ``Database/context``.
public var db: DatabaseContext { Database.context }
