import Foundation

/// An HTTP error that can be thrown from route handlers.
public struct HTTPError: Error, Sendable {
    public let status: HTTPStatus
    public let message: String?

    public init(status: HTTPStatus, message: String? = nil) {
        self.status = status; self.message = message
    }

    public static let notFound = HTTPError(status: .notFound)
    public static let badRequest = HTTPError(status: .badRequest)
    public static let unauthorized = HTTPError(status: .unauthorized)
    public static let forbidden = HTTPError(status: .forbidden)
    public static let internalServerError = HTTPError(status: .internalServerError)
    public static let tooManyRequests = HTTPError(status: .tooManyRequests)
    public static let unprocessableEntity = HTTPError(status: .unprocessableEntity)

    public enum HTTPStatus: Int, Sendable {
        case ok = 200
        case created = 201
        case noContent = 204
        case movedPermanently = 301
        case found = 302
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case unprocessableEntity = 422
        case upgradeRequired = 426
        case tooManyRequests = 429
        case internalServerError = 500
        case serviceUnavailable = 503

        public var reasonPhrase: String {
            switch self {
            case .ok: return "OK"
            case .created: return "Created"
            case .noContent: return "No Content"
            case .movedPermanently: return "Moved Permanently"
            case .found: return "Found"
            case .badRequest: return "Bad Request"
            case .unauthorized: return "Unauthorized"
            case .forbidden: return "Forbidden"
            case .notFound: return "Not Found"
            case .methodNotAllowed: return "Method Not Allowed"
            case .unprocessableEntity: return "Unprocessable Entity"
            case .upgradeRequired: return "Upgrade Required"
            case .tooManyRequests: return "Too Many Requests"
            case .internalServerError: return "Internal Server Error"
            case .serviceUnavailable: return "Service Unavailable"
            }
        }
    }
}
