import ScoreCore

// APIPrefix is defined in ScoreCore. Re-exported here with a ScoreRouter-specific helper.

extension APIPrefix {
    /// Combine this prefix with an additional path segment.
    ///
    /// ```swift
    /// APIPrefix.v1.combined(with: "/posts")  // "/api/v1/posts"
    /// ```
    public func combined(with path: String) -> String {
        let base = self.prefix
        if path.isEmpty || path == "/" { return base }
        let separator = path.hasPrefix("/") ? "" : "/"
        return base + separator + path
    }
}
