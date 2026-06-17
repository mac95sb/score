import Foundation
import Score

struct PostsController: RouteCollection {
    var routes: [Route] {
        RouteGroup("/blog") {
            Page("/") { req in
                let posts = try await ContentStore.posts()
                    .filter { $0.frontmatter.published }
                    .sorted { ($0.frontmatter.date ?? .distantPast) > ($1.frontmatter.date ?? .distantPast) }
                return BlogIndexPage(posts: posts)
            }

            Page("/:slug") { req in
                let slug: String = try req.pathParameter("slug")
                guard
                    let post = try await ContentStore.posts()
                        .first(where: { $0.slug == slug })
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
                    .sorted { ($0.frontmatter.date ?? .distantPast) > ($1.frontmatter.date ?? .distantPast) }
                return try Response.json(posts.map(PostResponse.init))
            }

            GET("/:slug") { req in
                let slug: String = try req.pathParameter("slug")
                guard
                    let post = try await ContentStore.posts()
                        .first(where: { $0.slug == slug })
                else { throw HTTPError.notFound }
                return try Response.json(PostResponse(post))
            }
        }
    }
}

private struct PostResponse: Encodable {
    let slug: String
    let title: String
    let excerpt: String?
    let published: Bool

    init(_ post: ContentPost) {
        self.slug = post.slug
        self.title = post.frontmatter.title
        self.excerpt = post.frontmatter.excerpt
        self.published = post.frontmatter.published
    }
}
