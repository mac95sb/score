import Score

struct LikesController: RouteCollection {
    var routes: [Route] {
        RouteGroup(api: "/likes") {
            GET("/:slug") { req in
                let slug: String = try req.pathParameter("slug")
                let count = try await db.query(PostLike.self)
                    .filter(\.slug == slug)
                    .count()
                return try Response.json(LikeResponse(slug: slug, count: count))
            }

            POST("/:slug") { req in
                let slug: String = try req.pathParameter("slug")
                _ = try await db.insert(PostLike(slug: slug))
                let count = try await db.query(PostLike.self)
                    .filter(\.slug == slug)
                    .count()
                return try Response.json(LikeResponse(slug: slug, count: count))
            }
        }
    }
}

private struct LikeResponse: Encodable {
    let slug: String
    let count: Int
}
