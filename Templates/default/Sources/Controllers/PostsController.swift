import Score

struct PostsController: RouteCollection {
    var routes: [Route] {
        RouteGroup("/blog") {
            Page("/") { req in
                let posts = try await ContentStore.posts()
                    .filter { $0.frontmatter.published }
                    .sorted { $0.frontmatter.date > $1.frontmatter.date }
                return BlogIndexPage(posts: posts)
            }

            Page("/:slug") { req in
                guard let post = try await ContentStore.posts()
                    .first(where: { $0.slug == req.pathParameters["slug"]! })
                else { throw HTTPError.notFound }
                let likeCount = try await db.query(PostLike.self)
                    .filter(\.slug == post.slug)
                    .count()
                return BlogPostPage(post: post, likeCount: likeCount)
            }
        }

        RouteGroup(api: "/posts") {
            GET("/") { req in
                let posts = try await ContentStore.posts()
                    .filter { $0.frontmatter.published }
                    .sorted { $0.frontmatter.date > $1.frontmatter.date }
                return Response.json(posts)
            }

            GET("/:slug") { req in
                guard let post = try await ContentStore.posts()
                    .first(where: { $0.slug == req.pathParameters["slug"]! })
                else { throw HTTPError.notFound }
                return Response.json(post)
            }
        }
    }
}
