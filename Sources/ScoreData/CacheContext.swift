import Foundation

// MARK: - CacheExpiry

/// A time-to-live duration for cached values.
public struct CacheExpiry: Sendable {
    public let seconds: TimeInterval

    public static func seconds(_ n: Int) -> CacheExpiry {
        CacheExpiry(seconds: TimeInterval(n))
    }

    public static func minutes(_ n: Int) -> CacheExpiry {
        CacheExpiry(seconds: TimeInterval(n * 60))
    }

    public static func hours(_ n: Int) -> CacheExpiry {
        CacheExpiry(seconds: TimeInterval(n * 3_600))
    }

    public static func days(_ n: Int) -> CacheExpiry {
        CacheExpiry(seconds: TimeInterval(n * 86_400))
    }
}

// MARK: - CacheEntry (internal)

struct CacheEntry: Sendable {
    let data: Data
    let expiresAt: Date?

    var isExpired: Bool {
        guard let expiry = expiresAt else { return false }
        return expiry < Date()
    }
}

// MARK: - CacheContext

/// An in-memory key-value cache with optional per-entry TTL expiry.
///
/// `CacheContext` is safe for concurrent access — all operations are
/// serialised through its actor executor.
///
/// ```swift
/// try await cache.set("featured", value: posts, expiry: .minutes(5))
/// let cached: [Post]? = try await cache.get("featured", as: [Post].self)
/// let views = try await cache.increment("views:\(slug)")
/// ```
public actor CacheContext {
    private var store: [String: CacheEntry] = [:]

    public init() {}

    // MARK: - Set

    /// Store a `Codable` value under `key`.
    ///
    /// - Parameters:
    ///   - key: The cache key.
    ///   - value: Any `Codable & Sendable` value.
    ///   - expiry: Optional TTL. When omitted the entry never expires.
    public func set<V: Codable & Sendable>(
        _ key: String,
        value: V,
        expiry: CacheExpiry? = nil
    ) async throws {
        let data = try JSONEncoder().encode(value)
        let entry = CacheEntry(
            data: data,
            expiresAt: expiry.map { Date().addingTimeInterval($0.seconds) }
        )
        store[key] = entry
    }

    // MARK: - Get

    /// Retrieve a value from the cache.
    ///
    /// Returns `nil` when the key does not exist or the entry has expired.
    /// Expired entries are removed on access.
    public func get<V: Codable & Sendable>(_ key: String, as type: V.Type) async throws -> V? {
        guard let entry = store[key] else { return nil }
        if entry.isExpired {
            store.removeValue(forKey: key)
            return nil
        }
        return try JSONDecoder().decode(type, from: entry.data)
    }

    // MARK: - Increment

    /// Atomically increment a numeric counter and return the new value.
    ///
    /// The counter is initialised to 0 if the key does not exist.
    /// The TTL is refreshed with each increment when `expiry` is provided.
    public func increment(_ key: String, expiry: CacheExpiry? = nil) async throws -> Int {
        let current: Int = (try? await get(key, as: Int.self)) ?? 0
        let next = current + 1
        try await set(key, value: next, expiry: expiry)
        return next
    }

    /// Atomically decrement a numeric counter and return the new value.
    ///
    /// The counter is initialised to 0 if the key does not exist.
    public func decrement(_ key: String, expiry: CacheExpiry? = nil) async throws -> Int {
        let current: Int = (try? await get(key, as: Int.self)) ?? 0
        let next = current - 1
        try await set(key, value: next, expiry: expiry)
        return next
    }

    // MARK: - Delete

    /// Delete a single key.
    public func delete(_ key: String) async throws {
        store.removeValue(forKey: key)
    }

    /// Delete all keys that start with `prefix`.
    public func flush(prefix: String) async throws {
        store = store.filter { !$0.key.hasPrefix(prefix) }
    }

    /// Remove all entries from the cache.
    public func flushAll() async throws {
        store.removeAll()
    }

    // MARK: - Introspection

    /// Return the number of non-expired entries currently held.
    public func count() async -> Int {
        let now = Date()
        return store.values.filter { entry in
            guard let expiry = entry.expiresAt else { return true }
            return expiry >= now
        }.count
    }

    /// Return all non-expired cache keys.
    public func keys() async -> [String] {
        let now = Date()
        return store.compactMap { (key, entry) -> String? in
            guard let expiry = entry.expiresAt else { return key }
            return expiry >= now ? key : nil
        }
    }
}
