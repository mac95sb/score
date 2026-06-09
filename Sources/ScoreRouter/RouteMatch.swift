import Foundation

/// The result of matching a URL path against a route pattern.
public struct RouteMatch: Sendable {
    /// The matched route.
    public let route: Route
    /// Extracted path parameters, e.g. `["slug": "hello-world"]`.
    public let parameters: [String: String]

    public init(route: Route, parameters: [String: String]) {
        self.route = route
        self.parameters = parameters
    }
}
