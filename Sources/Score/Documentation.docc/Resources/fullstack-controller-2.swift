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

        RouteGroup(api: "/posts") {
            GET("/",       handle: list)
            POST("/",      handle: create)
            DELETE("/:id", handle: destroy)
        }
    }

    func list(_ req: Request) async throws -> Response {
        let posts = try await db.query(Post.self)
            .filter(\.published == true)
            .orderBy(\.createdAt, .descending)
            .all()
        return try Response.json(posts)
    }

    func create(_ req: Request) async throws -> Response {
        struct CreatePost: Codable { var title: String; var body: String }
        let input = try await req.decode(CreatePost.self)
        let post = try await db.insert(Post(title: input.title, body: input.body))
        return try Response.json(post, status: .created)
    }

    func destroy(_ req: Request) async throws -> Response {
        let id: UUID = try req.pathParameter("id")
        try await db.delete(Post.self, id: id)
        return Response.noContent()
    }
}
