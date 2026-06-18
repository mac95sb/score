import Score

struct PostDetailPage: Page {
    let post: Post

    var metadata: PageMetadata? {
        PageMetadata(title: post.title)
    }

    var body: some View {
        Main {
            Article {
                Heading(1) { post.title }
                    .font(size: .fourXL, weight: .bold, wrap: .balance)
                Text { post.body }
                    .margin(top: 6)
                    .font(leading: .relaxed)
                Link(to: "/posts") { "← Back to posts" }
                    .margin(top: 8)
                    .display(.block)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
