import Foundation
@_exported import HTTPTypes

/// An incoming HTTP request.
public struct Request: Sendable {
    public let method: HTTPRequest.Method
    public let uri: URI
    public let headers: HTTPFields
    public let body: RequestBody
    public var context: RequestContext
    public var pathParameters: [String: String]

    public init(
        method: HTTPRequest.Method = .get,
        uri: URI,
        headers: HTTPFields = [:],
        body: RequestBody = .empty,
        context: RequestContext = RequestContext(),
        pathParameters: [String: String] = [:]
    ) {
        self.method = method
        self.uri = uri
        self.headers = headers
        self.body = body
        self.context = context
        self.pathParameters = pathParameters
    }

    /// Decode the request body as the given type.
    public func decode<T: Decodable>(_ type: T.Type) async throws -> T {
        try body.decode(type)
    }

    /// Extract a typed path parameter.
    ///
    /// ```swift
    /// let id: UUID = try req.pathParameter("id")
    /// ```
    public func pathParameter<T: LosslessStringConvertible>(_ name: String) throws -> T {
        guard let raw = pathParameters[name] else {
            throw HTTPError(status: .badRequest, message: "Missing path parameter: \(name)")
        }
        guard let value = T(raw) else {
            throw HTTPError(status: .badRequest, message: "Invalid path parameter \(name): expected \(T.self)")
        }
        return value
    }

    /// Cookies parsed from the `Cookie` header.
    public var cookies: [String: String] {
        headers[.cookie].map { Cookie.parse(from: $0) } ?? [:]
    }

    /// The client's remote IP address.
    public var remoteAddress: String {
        headers["X-Forwarded-For"] ?? headers["X-Real-IP"] ?? "unknown"
    }

    /// Query parameters from the URL.
    public var queryParameters: [String: String] { uri.query }

    /// Accept a session token from cookies.
    public var sessionToken: String? { cookies["session"] }
}

// Allow HTTPField access by name string
extension HTTPFields {
    public subscript(name: String) -> String? {
        guard let fieldName = HTTPField.Name(name) else { return nil }
        return self[fieldName]
    }
}

// MARK: - UUID path parameters

/// Lets `UUID` be extracted directly with ``Request/pathParameter(_:)``:
///
/// ```swift
/// let id: UUID = try req.pathParameter("id")
/// ```
extension UUID: @retroactive LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(uuidString: description)
    }
}
