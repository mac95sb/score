/// The URL prefix applied to all API route groups.
///
/// Configure via the `apiPrefix` property on your `Application` conformance.
public enum APIPrefix: Sendable {
    case v1, v2, v3, v4, v5, v6, v7, v8, v9
    case custom(String)
    case none

    /// The path string applied before all API routes.
    public var prefix: String {
        switch self {
        case .v1: return "/api/v1"
        case .v2: return "/api/v2"
        case .v3: return "/api/v3"
        case .v4: return "/api/v4"
        case .v5: return "/api/v5"
        case .v6: return "/api/v6"
        case .v7: return "/api/v7"
        case .v8: return "/api/v8"
        case .v9: return "/api/v9"
        case .custom(let s): return s
        case .none: return ""
        }
    }
}
