/// Builds an executable middleware chain from an ordered list of `Middleware` values.
public struct MiddlewareChain: Sendable {
    let middleware: [any Middleware]

    public init(_ middleware: [any Middleware]) { self.middleware = middleware }

    /// Execute the middleware chain, calling `handler` at the tail.
    public func execute(
        _ request: Request,
        handler: @Sendable @escaping (Request) async throws -> Response
    ) async throws -> Response {
        try await execute(request, at: 0, handler: handler)
    }

    private func execute(
        _ request: Request,
        at index: Int,
        handler: @Sendable @escaping (Request) async throws -> Response
    ) async throws -> Response {
        if index >= middleware.count {
            return try await handler(request)
        }
        let m = middleware[index]
        return try await m.handle(request) { req in
            try await self.execute(req, at: index + 1, handler: handler)
        }
    }
}

@resultBuilder
public struct MiddlewareBuilder {
    public static func buildBlock(_ components: any Middleware...) -> [any Middleware] {
        components
    }
}
