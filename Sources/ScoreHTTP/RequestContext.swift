import Foundation

/// Per-request mutable context for storing middleware data.
///
/// Middleware can attach data (authenticated user, rate limit info, etc.)
/// that later handlers read via `request.context`.
public struct RequestContext: Sendable {
    /// The authenticated user, set by `AuthMiddleware`.
    public var user: AuthUser?

    /// Raw storage for custom middleware data.
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public init() {}

    public subscript<K: ContextKey>(key: K.Type) -> K.Value? {
        get { storage[ObjectIdentifier(key)] as? K.Value }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

/// A type-safe key for storing values in `RequestContext`.
public protocol ContextKey: Sendable {
    associatedtype Value: Sendable
}

/// Placeholder for the authenticated user type.
/// Applications define their own `AuthUser` conformer via ScoreAuth plugin.
public struct AuthUser: Sendable {
    public let id: UUID
    public let email: String
    public var metadata: [String: String]

    public init(id: UUID, email: String, metadata: [String: String] = [:]) {
        self.id = id; self.email = email; self.metadata = metadata
    }
}
