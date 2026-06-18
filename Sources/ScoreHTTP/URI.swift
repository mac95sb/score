import Foundation

/// A parsed URI with path, query, and fragment components.
public struct URI: Sendable, Hashable {
    public let scheme: String?
    public let host: String?
    public let port: Int?
    public let path: String
    public let query: [String: String]
    public let fragment: String?

    public init(string: String) {
        guard let components = URLComponents(string: string) else {
            self.scheme = nil
            self.host = nil
            self.port = nil
            self.path = string
            self.query = [:]
            self.fragment = nil
            return
        }
        self.scheme = components.scheme
        self.host = components.host
        self.port = components.port
        self.path = components.path.isEmpty ? "/" : components.path
        self.fragment = components.fragment
        var queryDict: [String: String] = [:]
        for item in components.queryItems ?? [] {
            queryDict[item.name] = item.value ?? ""
        }
        self.query = queryDict
    }

    public init(path: String, query: [String: String] = [:]) {
        self.scheme = nil
        self.host = nil
        self.port = nil
        self.path = path
        self.query = query
        self.fragment = nil
    }

    public var string: String {
        guard !query.isEmpty else { return path }
        var components = URLComponents()
        components.path = path
        // Sort keys for deterministic output; use URLQueryItem for proper percent-encoding.
        components.queryItems = query.sorted(by: { $0.key < $1.key })
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.string ?? path
    }
}
