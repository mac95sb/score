import Foundation
@_exported import ScoreCore

/// An outgoing HTTP response.
public struct Response: Sendable {
    public let status: HTTPError.HTTPStatus
    public let headers: [String: String]
    public let body: ResponseBody

    public init(
        status: HTTPError.HTTPStatus = .ok,
        headers: [String: String] = [:],
        body: ResponseBody = .empty
    ) {
        self.status = status
        self.headers = headers
        self.body = body
    }

    // MARK: - Static factories

    /// 200 OK with an optional body.
    public static func ok(_ body: ResponseBody = .empty) -> Response {
        Response(status: .ok, body: body)
    }

    /// 200 OK with an HTML body rendered from a `View`.
    public static func html(_ content: some View) -> Response {
        let html = HTMLRenderer().render(content)
        return Response(status: .ok, body: .html(html))
    }

    /// 200 OK (or custom status) with a JSON-encoded body.
    public static func json<T: Encodable>(
        _ value: T,
        status: HTTPError.HTTPStatus = .ok
    ) throws -> Response {
        let data = try JSONEncoder().encode(value)
        return Response(status: status, body: .json(data))
    }

    /// 201 Created with a JSON-encoded body.
    public static func created<T: Encodable>(_ value: T) throws -> Response {
        try json(value, status: .created)
    }

    /// 204 No Content.
    public static func noContent() -> Response {
        Response(status: .noContent)
    }

    /// Redirect response (302 Found by default, 301 Moved Permanently when `permanent: true`).
    ///
    /// A `location` containing CR/LF/NUL is rejected with 400 to prevent HTTP
    /// response splitting when the target is derived from user input.
    public static func redirect(to location: String, permanent: Bool = false) -> Response {
        guard !location.utf8.contains(where: { $0 == 0x0D || $0 == 0x0A || $0 == 0x00 }) else {
            return Response(status: .badRequest, body: .text("Invalid redirect location"))
        }
        return Response(
            status: permanent ? .movedPermanently : .found,
            headers: ["Location": location]
        )
    }

    /// 404 Not Found with an optional text body.
    public static func notFound(_ message: String? = nil) -> Response {
        Response(status: .notFound, body: message.map { .text($0) } ?? .empty)
    }

    /// 400 Bad Request with an optional text body.
    public static func badRequest(_ message: String? = nil) -> Response {
        Response(status: .badRequest, body: message.map { .text($0) } ?? .empty)
    }

    /// 422 Unprocessable Entity with a JSON-encoded validation-errors body.
    public static func unprocessableEntity<T: Encodable>(_ errors: T) throws -> Response {
        try json(errors, status: .unprocessableEntity)
    }
}
