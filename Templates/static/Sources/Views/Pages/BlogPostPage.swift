import Score

struct BlogPostPage: Page {
    let post: ContentPost

    var metadata: PageMetadata? {
        PageMetadata(
            title: post.frontmatter.title,
            description: post.frontmatter.excerpt ?? "",
            ogType: .article,
            canonicalURL: "/blog/\(post.slug)"
        )
    }

    var contentTheme: ContentTheme { .default }
    var path: String { "/blog/\(post.slug)" }

    var body: some View {
        Main {
            Article {
                Heading(1) { post.frontmatter.title }
                    .font(size: .fourXL)
                    .font(weight: .bold)
                    .font(wrap: .balance)
                RichText(markdown: post.content)
                    .margin(top: 8)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}

extension BlogPostPage: StaticPage {
    static func instances() async throws -> [Self] {
        try await ContentStore.posts()
            .filter { $0.frontmatter.published }
            .map { BlogPostPage(post: $0) }
    }
}
