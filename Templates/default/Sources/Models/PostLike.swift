import Score

struct PostLike: Record {
    var id: UUID = UUID()
    var slug: String
    var createdAt: Date = .now
}
