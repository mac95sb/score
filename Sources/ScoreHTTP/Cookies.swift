import Foundation

/// An HTTP cookie.
public struct Cookie: Sendable {
    public let name: String
    public let value: String
    public let domain: String?
    public let path: String?
    public let expires: Date?
    public let maxAge: Int?
    public let secure: Bool
    public let httpOnly: Bool
    public let sameSite: SameSite?

    public enum SameSite: String, Sendable {
        case strict = "Strict"
        case lax = "Lax"
        case none = "None"
    }

    public init(
        name: String, value: String,
        domain: String? = nil, path: String? = "/",
        expires: Date? = nil, maxAge: Int? = nil,
        secure: Bool = true, httpOnly: Bool = true,
        sameSite: SameSite? = .lax
    ) {
        self.name = name
        self.value = value
        self.domain = domain
        self.path = path
        self.expires = expires
        self.maxAge = maxAge
        self.secure = secure
        self.httpOnly = httpOnly
        self.sameSite = sameSite
    }

    /// Serialize to a `Set-Cookie` header value.
    public var headerValue: String {
        var parts = ["\(name)=\(value)"]
        if let domain = domain { parts.append("Domain=\(domain)") }
        if let path = path { parts.append("Path=\(path)") }
        if let maxAge = maxAge { parts.append("Max-Age=\(maxAge)") }
        if let expires = expires {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = TimeZone(identifier: "GMT")
            parts.append("Expires=\(fmt.string(from: expires))")
        }
        if secure { parts.append("Secure") }
        if httpOnly { parts.append("HttpOnly") }
        if let sameSite = sameSite { parts.append("SameSite=\(sameSite.rawValue)") }
        return parts.joined(separator: "; ")
    }

    /// Parse cookies from a `Cookie` header value.
    public static func parse(from headerValue: String) -> [String: String] {
        var cookies: [String: String] = [:]
        for pair in headerValue.components(separatedBy: "; ") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                cookies[String(parts[0]).trimmingCharacters(in: .whitespaces)] =
                    String(parts[1]).trimmingCharacters(in: .whitespaces)
            }
        }
        return cookies
    }
}
