import Foundation

/// The body of an outgoing HTTP response.
public enum ResponseBody: Sendable {
    case empty
    case text(String, encoding: String.Encoding = .utf8)
    case data(Data, contentType: String)
    case json(Data)
    case html(String)

    public var bytes: Data {
        switch self {
        case .empty: return Data()
        case .text(let s, let enc): return s.data(using: enc) ?? Data()
        case .data(let d, _): return d
        case .json(let d): return d
        case .html(let s): return s.data(using: .utf8) ?? Data()
        }
    }

    public var contentType: String {
        switch self {
        case .empty: return "text/plain"
        case .text: return "text/plain; charset=utf-8"
        case .data(_, let ct): return ct
        case .json: return "application/json"
        case .html: return "text/html; charset=utf-8"
        }
    }
}
