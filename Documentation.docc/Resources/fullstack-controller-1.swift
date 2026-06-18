import Score

struct PostsController: RouteCollection {
    var routes: [Route] {
        RouteGroup("/posts") {
            Page("/") { _ in
                let posts = try await db.query(Post.self)
                    .filter(\.published == true)
                    .orderBy(\.createdAt, .descending)
                    .all()
                return PostsIndexPage(posts: posts)
            }

            Page("/:id") { req in
                let id: UUID = try req.pathParameter("id")
                guard let post = try await db.find(Post.self, id: id)
                else { throw HTTPError.notFound }
                return PostDetailPage(post: post)
            }
        }
    }
}
