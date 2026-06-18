import Foundation

/// Matches a URL path pattern against a concrete path and extracts parameters.
///
/// Pattern syntax:
/// - `/blog/:slug`              — single named parameter
/// - `/users/:id/posts/:postId` — multiple named parameters
/// - `/static/*`                — trailing wildcard (matches any suffix)
public struct PathMatcher: Sendable {
    public let pattern: String
    let segments: [Segment]

    enum Segment: Sendable {
        case literal(String)  // exact segment match (case-insensitive)
        case parameter(String)  // `:name` — captured into parameters dict
        case wildcard  // `*`     — matches anything, stops further matching
    }

    public init(pattern: String) {
        self.pattern = pattern
        self.segments =
            pattern
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { seg -> Segment in
                let s = String(seg)
                if s.hasPrefix(":") { return .parameter(String(s.dropFirst())) }
                if s == "*" { return .wildcard }
                return .literal(s)
            }
    }

    /// Attempt to match `path` against the pattern.
    ///
    /// Returns a dictionary of extracted parameter values on success, or `nil` when the
    /// path does not match.
    public func match(path: String) -> [String: String]? {
        let pathSegments =
            path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)

        // A trailing wildcard may match any number of remaining path segments.
        let hasTrailingWildcard: Bool
        if case .wildcard = segments.last { hasTrailingWildcard = true } else { hasTrailingWildcard = false }

        if hasTrailingWildcard {
            // Pattern (minus wildcard) must be a prefix of the path.
            guard pathSegments.count >= segments.count - 1 else { return nil }
        } else {
            guard pathSegments.count == segments.count else { return nil }
        }

        var parameters: [String: String] = [:]

        for (patternSeg, pathSeg) in zip(segments, pathSegments) {
            switch patternSeg {
            case .literal(let lit):
                if lit.lowercased() != pathSeg.lowercased() { return nil }
            case .parameter(let name):
                parameters[name] = pathSeg
            case .wildcard:
                // Wildcard consumes the remainder — stop processing.
                return parameters
            }
        }

        return parameters
    }
}

// MARK: - Equatable conformance for tests

extension PathMatcher.Segment: Equatable {
    static func == (lhs: PathMatcher.Segment, rhs: PathMatcher.Segment) -> Bool {
        switch (lhs, rhs) {
        case (.literal(let a), .literal(let b)): return a == b
        case (.parameter(let a), .parameter(let b)): return a == b
        case (.wildcard, .wildcard): return true
        default: return false
        }
    }
}
