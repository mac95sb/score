import Score

struct Post: Record {
    var id: UUID = UUID()
    var title: String
    var slug: String
    var excerpt: String
    var body: String
    var published: Bool = false
    var createdAt: Date = .now
    var updatedAt: Date = .now
}
