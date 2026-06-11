import Score

struct BlogPostPage: Page {
    let post: ContentPost
    let likeCount: Int

    var metadata: PageMetadata? {
        PageMetadata(
            title: post.frontmatter.title,
            description: post.frontmatter.excerpt ?? "",
            ogType: .article,
            canonicalURL: "/blog/\(post.slug)"
        )
    }

    var contentTheme: ContentTheme { .article }

    var body: some View {
        Main {
            Article {
                Heading(1) { post.frontmatter.title }
                    .font(size: .fourXL, weight: .bold, wrap: .balance)
                if let excerpt = post.frontmatter.excerpt {
                    Text { excerpt }
                        .font(size: .lg, color: .muted)
                        .margin(top: 4)
                }
                Divider()
                    .margin(y: 8)
                RichText(markdown: post.content)
                LikeButton(slug: post.slug, count: likeCount)
                    .margin(top: 8)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
            .padding(12, at: .desktop)
        }
    }
}
