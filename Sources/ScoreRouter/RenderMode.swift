import Foundation

/// Controls how a route renders its response.
public enum RenderMode: Sendable {
    /// Pre-rendered at build time. Default for `Page` / `View`-returning routes.
    case `static`
    /// Rendered on every request. Default for `Response`-returning routes.
    case serverRendered
    /// Rendered once, cached, then revalidated after the given TTL.
    case incrementalStaticRegeneration(ttl: Duration)
}
