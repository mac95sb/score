import Score

struct BlogPostPage: Page {
    let post: Post

    var metadata: PageMetadata? {
        PageMetadata(
            title: post.title,
            description: post.excerpt,
            ogType: .article,
            canonicalURL: "/blog/\(post.slug)"
        )
    }

    var contentTheme: ContentTheme { .article }

    var body: some View {
        Main {
            Article {
                Heading(1) { post.title }
                    .font(size: .fourXL)
                    .font(weight: .bold)
                    .font(wrap: .balance)
                Text { post.excerpt }
                    .font(size: .lg)
                    .font(color: .muted)
                    .margin(top: 4)
                Divider()
                    .margin(y: 8)
                Text { post.body }
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
            .padding(12, at: .desktop)
        }
    }
}
