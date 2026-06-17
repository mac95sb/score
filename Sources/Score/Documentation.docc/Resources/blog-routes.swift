var routes: some RouteCollection {
    Page("/") { HomePage() }
    Page("/blog") { _ in
        let posts = try await ContentStore.posts()
            .filter { $0.frontmatter.published }
        return BlogIndexPage(posts: posts)
    }
    BlogPostPage.self
}
