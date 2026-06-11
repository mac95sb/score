import Score

struct ArticleCard: View {
    let post: Post

    var body: some View {
        Link(to: "/blog/\(post.slug)") {
            VStack {
                Heading(3) { post.title }
                    .font(size: .xl, weight: .semibold)
                Text { post.excerpt }
                    .font(size: .sm, color: .muted)
                    .margin(top: 2)
            }
            .padding(6)
            .border(color: .muted.opacity(0.2))
            .border(radius: .lg)
            .background(color: .surface)
            .on(.hover) {
                $0.shadow(.md)
                  .translate(y: .px(-2))
            }
            .animate(.all, duration: 150.ms)
        }
    }
}
