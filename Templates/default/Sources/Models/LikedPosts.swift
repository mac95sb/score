import Score

struct LikedPosts: Codable {
    var slugs: Set<String> = []

    mutating func add(_ slug: String) {
        slugs.insert(slug)
    }

    func contains(_ slug: String) -> Bool {
        slugs.contains(slug)
    }
}
