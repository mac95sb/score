import Foundation

/// Configuration for a cache backend.
public protocol CacheConfig: Sendable {
    /// Create a fresh `CacheContext` from this configuration.
    func makeContext() async throws -> CacheContext
}

/// In-memory cache configuration — the default for all Score applications.
///
/// Each call to `makeContext()` returns a new, independent in-memory store.
/// For shared caching across tasks or requests, hold a single `CacheContext`
/// instance on your application object.
public struct InMemoryCacheConfig: CacheConfig {
    public init() {}

    public func makeContext() async throws -> CacheContext {
        CacheContext()
    }
}
