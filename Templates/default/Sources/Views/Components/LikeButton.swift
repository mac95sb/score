import Score

struct LikeButton: View {
    let slug: String
    let count: Int

    init(slug: String, count: Int) {
        self.slug = slug
        self.count = count
    }

    var body: some View {
        Link(to: "/api/likes/\(slug)") {
            HStack {
                Text { "Likes" }
                    .font(color: .muted)
                Text { "\(count)" }
                    .font(color: .muted)
            }
            .flex(align: .center, gap: 2)
        }
        .font(size: .sm)
        .animate(.all, duration: 150.ms)
    }
}
