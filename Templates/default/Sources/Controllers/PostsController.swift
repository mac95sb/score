import Score

struct PostsController: RouteCollection {
    var routes: some RouteCollection {
        RouteGroup("/blog") {
            Page("/") { req in
                let posts = try await db.query(Post.self)
                    .filter(\.published == true)
                    .orderBy(\.createdAt, .descending)
                    .all()
                return BlogIndexPage(posts: posts)
            }

            Page("/:slug") { req in
                guard let post = try await db.query(Post.self)
                    .filter(\.slug == req.pathParameters["slug"]!)
                    .first()
                else { throw HTTPError.notFound }
                return BlogPostPage(post: post)
            }
        }

        RouteGroup(api: "/posts") {
            GET("/") { req in
                let posts = try await db.query(Post.self)
                    .filter(\.published == true)
                    .orderBy(\.createdAt, .descending)
                    .all()
                return Response.json(posts)
            }

            GET("/:id") { req in
                guard let post = try await db.find(Post.self, id: req.pathParameter("id"))
                else { throw HTTPError.notFound }
                return Response.json(post)
            }
        }
    }
}
