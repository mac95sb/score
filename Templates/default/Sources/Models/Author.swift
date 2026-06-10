import Score

struct Author: Record {
    var id: UUID = UUID()
    var name: String
    var email: String
    var bio: String = ""
    var createdAt: Date = .now
}
