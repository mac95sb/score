import Score

struct PostsIndexPage: Page {
    let posts: [Post]

    var metadata: PageMetadata? {
        PageMetadata(title: "Posts", description: "All published posts.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Posts" }
                    .font(size: .fourXL, weight: .bold)
                VStack {
                    for post in posts {
                        Article {
                            Heading(2) { post.title }
                                .font(size: .twoXL, weight: .semibold)
                            Text { post.body }
                                .font(color: .muted)
                                .margin(top: 2)
                            Link(to: "/posts/\(post.id)") { "Read more →" }
                                .margin(top: 3)
                                .display(.block)
                        }
                        .padding(6)
                        .border(radius: .lg)
                        .margin(bottom: 4)
                    }
                }
                .margin(top: 8)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
