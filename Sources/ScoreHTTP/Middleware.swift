import Foundation
import Logging

/// A type that intercepts and optionally transforms requests and responses.
///
/// ```swift
/// struct LoggingMiddleware: Middleware {
///     func handle(
///         _ request: Request,
///         next: @Sendable (Request) async throws -> Response
///     ) async throws -> Response {
///         let start = Date()
///         let response = try await next(request)
///         let ms = Int(Date().timeIntervalSince(start) * 1000)
///         print("\(request.method) \(request.uri.path) → \(response.status.rawValue) (\(ms)ms)")
///         return response
///     }
/// }
/// ```
public protocol Middleware: Sendable {
    func handle(
        _ request: Request,
        next: @Sendable (Request) async throws -> Response
    ) async throws -> Response
}

// MARK: - Built-in middleware

/// Adds common security headers to every response.
public struct SecurityHeadersMiddleware: Middleware {
    public init() {}

    public func handle(
        _ request: Request,
        next: @Sendable (Request) async throws -> Response
    ) async throws -> Response {
        let response = try await next(request)
        var headers = response.headers
        headers["X-Content-Type-Options"] = "nosniff"
        headers["X-Frame-Options"] = "SAMEORIGIN"
        headers["X-XSS-Protection"] = "1; mode=block"
        headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        return Response(status: response.status, headers: headers, body: response.body)
    }
}

/// Logs each request with method, path, status, and duration.
public struct LoggingMiddleware: Middleware {
    private let logger: Logger

    public init(logger: Logger = Logger(label: "score.http")) {
        self.logger = logger
    }

    public func handle(
        _ request: Request,
        next: @Sendable (Request) async throws -> Response
    ) async throws -> Response {
        let start = Date()
        do {
            let response = try await next(request)
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            logger.info("[\(ms)ms] \(request.method) \(request.uri.path) → \(response.status.rawValue)")
            return response
        } catch {
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            logger.error("[\(ms)ms] \(request.method) \(request.uri.path) → ERROR: \(error)")
            throw error
        }
    }
}

/// Passes responses through unchanged; reserves the hook for NIO-level gzip compression.
///
/// Full gzip compression is applied at the NIO channel pipeline level via
/// `NIOHTTPCompressHandler` from NIOExtras. This middleware type exists so
/// applications can place it in the middleware stack as documentation of intent.
public struct CompressionMiddleware: Middleware {
    public init() {}

    public func handle(
        _ request: Request,
        next: @Sendable (Request) async throws -> Response
    ) async throws -> Response {
        // Compression is handled at the NIO pipeline level (NIOHTTPCompressHandler).
        try await next(request)
    }
}
