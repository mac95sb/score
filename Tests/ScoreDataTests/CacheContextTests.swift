import Foundation
import Testing

@testable import ScoreData

@Suite("CacheContext")
struct CacheContextTests {
    @Test("set and get string value")
    func setAndGet() async throws {
        let cache = CacheContext()
        try await cache.set("key", value: "hello")
        let result: String? = try await cache.get("key", as: String.self)
        #expect(result == "hello")
    }

    @Test("get returns nil for missing key")
    func missingKey() async throws {
        let cache = CacheContext()
        let result: String? = try await cache.get("nonexistent", as: String.self)
        #expect(result == nil)
    }

    @Test("increment returns new value")
    func incrementCounter() async throws {
        let cache = CacheContext()
        let first = try await cache.increment("counter")
        let second = try await cache.increment("counter")
        #expect(first == 1)
        #expect(second == 2)
    }

    @Test("decrement returns decremented value")
    func decrementCounter() async throws {
        let cache = CacheContext()
        try await cache.set("counter", value: 5)
        let result = try await cache.decrement("counter")
        #expect(result == 4)
    }

    @Test("delete removes key")
    func deleteKey() async throws {
        let cache = CacheContext()
        try await cache.set("temp", value: 42)
        try await cache.delete("temp")
        let result: Int? = try await cache.get("temp", as: Int.self)
        #expect(result == nil)
    }

    @Test("flushAll clears all entries")
    func flushAll() async throws {
        let cache = CacheContext()
        try await cache.set("a", value: 1)
        try await cache.set("b", value: 2)
        try await cache.flushAll()
        let count = await cache.count()
        #expect(count == 0)
    }

    @Test("flush with prefix removes matching keys")
    func flushPrefix() async throws {
        let cache = CacheContext()
        try await cache.set("user:1", value: "Alice")
        try await cache.set("user:2", value: "Bob")
        try await cache.set("post:1", value: "Hello")
        try await cache.flush(prefix: "user:")
        let count = await cache.count()
        #expect(count == 1)
    }

    @Test("expired entry returns nil")
    func expiredEntry() async throws {
        let cache = CacheContext()
        // Set with -1 second TTL (already expired)
        let expiry = CacheExpiry(seconds: -1)
        try await cache.set("expired", value: "gone", expiry: expiry)
        let result: String? = try await cache.get("expired", as: String.self)
        #expect(result == nil)
    }

    @Test("non-expired entry returns value")
    func nonExpiredEntry() async throws {
        let cache = CacheContext()
        try await cache.set("fresh", value: "here", expiry: .hours(1))
        let result: String? = try await cache.get("fresh", as: String.self)
        #expect(result == "here")
    }

    @Test("codable struct round-trips")
    func codableRoundTrip() async throws {
        struct Profile: Codable, Equatable {
            let name: String
            let age: Int
        }
        let cache = CacheContext()
        let profile = Profile(name: "Alice", age: 30)
        try await cache.set("profile", value: profile)
        let loaded: Profile? = try await cache.get("profile", as: Profile.self)
        #expect(loaded == profile)
    }
}
