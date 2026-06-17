import Score

struct BlogIndexPage: Page {
    let posts: [ContentPost]

    var metadata: PageMetadata? {
        PageMetadata(title: "Blog", description: "Articles and updates.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Blog" }
                    .font(size: .threeXL, weight: .bold)
                VStack {
                    for post in posts {
                        ArticleCard(post: post)
                    }
                }
                .flex(direction: .vertical, gap: 6)
                .margin(top: 8)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
