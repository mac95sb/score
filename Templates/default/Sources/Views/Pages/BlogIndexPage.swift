import Score

struct BlogIndexPage: Page {
    let posts: [Post]

    var metadata: PageMetadata {
        PageMetadata(
            title: "Blog",
            description: "Articles and updates from __NAME__."
        )
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Blog" }
                    .font(size: .threeXL)
                    .font(weight: .bold)
                VStack {
                    for post in posts {
                        ArticleCard(post: post)
                    }
                }
                .flex(direction: .vertical)
                .flex(gap: 6)
                .margin(top: 8)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
