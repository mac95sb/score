import Score

struct LikeButton: View {
    let slug: String

    @State var count: Int
    @State var liked: LikedPosts = LikedPosts()

    init(slug: String, count: Int) {
        self.slug = slug
        self._count = State(initialValue: count)
    }

    // Server action: persists the like to the database.
    @Action func persistLike() async throws {
        _ = try await db.insert(PostLike(slug: slug))
    }

    var body: some View {
        let hasLiked = liked.contains(slug)

        Button(.ghost) {
            HStack {
                Text { hasLiked ? "♥" : "♡" }
                    .font(color: hasLiked ? .primary : .muted)
                Text { "\(count)" }
                    .font(color: .muted)
            }
            .flex(align: .center, gap: 2)
        }
        .font(size: .sm)
        .on(.click) {
            guard !hasLiked else { return }
            // Update client state immediately (persisted to IndexedDB via localFirst).
            liked.add(slug)
            count += 1
            // Fire the server insert in the background.
            persistLike()
        }
        .animate(.all, duration: 150.ms)
    }
}
