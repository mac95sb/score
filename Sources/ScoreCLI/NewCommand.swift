import ArgumentParser
import Foundation
import Noora

/// `score new <name>` — scaffold a new Score project.
///
/// Creates a ready-to-run project with the chosen template in a new directory
/// named after the project.
struct NewCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "new",
        abstract: "Create a new Score project from a template."
    )

    @Argument(help: "Name of the new project.")
    var name: String

    @Option(name: .shortAndLong, help: "Template to use: default, static, minimal.")
    var template: ProjectTemplate = .default

    @Flag(name: .long, help: "Skip `swift package resolve` after scaffolding.")
    var skipResolve: Bool = false

    mutating func run() async throws {
        let noora = Noora()
        try validateName(name)
        let projectDir = URL(fileURLWithPath: name)

        guard !FileManager.default.fileExists(atPath: projectDir.path) else {
            throw CLIError.directoryExists(name)
        }

        let scaffold = ProjectScaffolder(template: template)
        let projectName = name

        try await noora.progressStep(
            message: "Creating \(name) (\(template.rawValue) template)…"
        ) { _ in
            try scaffold.write(to: projectDir, projectName: projectName)
        }

        if !skipResolve {
            try await noora.progressStep(message: "Resolving dependencies…") { _ in
                let p = Process()
                p.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
                p.arguments = ["package", "resolve"]
                p.currentDirectoryURL = projectDir
                try p.run()
                p.waitUntilExit()
            }
        }

        noora.success(.alert("Created \(name)/", takeaways: [
            "cd \(name)",
            "score dev",
        ]))
    }
}

// MARK: - ProjectTemplate

enum ProjectTemplate: String, ExpressibleByArgument, CaseIterable {
    case `default`
    case `static`
    case minimal
}

// MARK: - ProjectScaffolder

struct ProjectScaffolder: Sendable {
    let template: ProjectTemplate

    func write(to directory: URL, projectName: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Shared files
        try writePackageSwift(to: directory, name: projectName)
        try writeGitignore(to: directory)
        try writeAgentsMD(to: directory, name: projectName, template: template)
        try writeFavicon(to: directory)

        switch template {
        case .default:  try writeDefault(to: directory, name: projectName)
        case .static:   try writeStatic(to: directory, name: projectName)
        case .minimal:  try writeMinimal(to: directory, name: projectName)
        }
    }

    // MARK: - Default template (hybrid: pages + API routes + SQLite)

    private func writeDefault(to dir: URL, name: String) throws {
        try mkdir(dir, "Sources/Models")
        try mkdir(dir, "Sources/Views/Pages")
        try mkdir(dir, "Sources/Views/Pages/Blog")
        try mkdir(dir, "Sources/Views/Components")
        try mkdir(dir, "Sources/Controllers")
        try mkdir(dir, "Content/posts")
        try mkdir(dir, "Public")

        try write(defaultApplication(name), to: dir, "Sources/Application.swift")
        try write(defaultPostModel, to: dir, "Sources/Models/Post.swift")
        try write(defaultAuthorModel, to: dir, "Sources/Models/Author.swift")
        try write(defaultHomePage(name), to: dir, "Sources/Views/Pages/HomePage.swift")
        try write(defaultBlogIndexPage, to: dir, "Sources/Views/Pages/Blog/BlogIndexPage.swift")
        try write(defaultBlogPostPage, to: dir, "Sources/Views/Pages/Blog/BlogPostPage.swift")
        try write(defaultSiteNavigation(name), to: dir, "Sources/Views/Components/SiteNavigation.swift")
        try write(defaultArticleCard, to: dir, "Sources/Views/Components/ArticleCard.swift")
        try write(defaultSiteFooter(name), to: dir, "Sources/Views/Components/SiteFooter.swift")
        try write(defaultContentThemes(name), to: dir, "Sources/Views/ContentThemes.swift")
        try write(defaultPostsController, to: dir, "Sources/Controllers/PostsController.swift")
        try write(helloWorldPost(name), to: dir, "Content/posts/hello-world.md")
    }

    // MARK: - Static template (static site + Markdown content)

    private func writeStatic(to dir: URL, name: String) throws {
        try mkdir(dir, "Sources/Views/Pages")
        try mkdir(dir, "Sources/Views/Pages/Blog")
        try mkdir(dir, "Sources/Views/Components")
        try mkdir(dir, "Content/posts")
        try mkdir(dir, "Public")

        try write(staticApplication(name), to: dir, "Sources/Application.swift")
        try write(staticHomePage(name), to: dir, "Sources/Views/Pages/HomePage.swift")
        try write(staticAboutPage, to: dir, "Sources/Views/Pages/AboutPage.swift")
        try write(staticBlogPostPage, to: dir, "Sources/Views/Pages/Blog/BlogPostPage.swift")
        try write(staticSiteNavigation(name), to: dir, "Sources/Views/Components/SiteNavigation.swift")
        try write(helloWorldPost(name), to: dir, "Content/posts/hello-world.md")
    }

    // MARK: - Minimal template (single-page hello world)

    private func writeMinimal(to dir: URL, name: String) throws {
        try mkdir(dir, "Sources")
        try mkdir(dir, "Public")
        try write(minimalApplication(name), to: dir, "Sources/Application.swift")
    }

    // MARK: - Default template sources

    private func defaultApplication(_ name: String) -> String { """
        import Score

        @main
        struct \(name): Application {
            var metadata: SiteMetadata {
                SiteMetadata(
                    siteName: "\(name)",
                    titleSeparator: " — ",
                    description: "A site built with Score.",
                    baseURL: "https://example.com"
                )
            }

            var theme: SiteTheme { .default }

            var routes: some RouteCollection {
                PostsController()
            }

            var database: some DatabaseConfig {
                SQLiteDatabase(path: ".score/db.sqlite")
            }
        }
        """ }

    private var defaultPostModel: String { """
        import Score

        struct Post: Record {
            var id: UUID = UUID()
            var title: String
            var slug: String
            var excerpt: String
            var body: String
            var published: Bool = false
            var createdAt: Date = .now
            var updatedAt: Date = .now
        }
        """ }

    private var defaultAuthorModel: String { """
        import Score

        struct Author: Record {
            var id: UUID = UUID()
            var name: String
            var email: String
            var bio: String = ""
            var createdAt: Date = .now
            var updatedAt: Date = .now
        }
        """ }

    private func defaultHomePage(_ name: String) -> String { """
        import Score

        struct HomePage: Page {
            var metadata: PageMetadata? {
                PageMetadata(
                    title: "Home",
                    description: "Welcome to \(name)."
                )
            }

            var body: some View {
                Main {
                    Section {
                        Heading(1) { "Welcome to \(name)" }
                            .font(size: .fourXL, weight: .bold, wrap: .balance)
                        Text { "A site built with Score." }
                            .font(size: .xl, color: .muted)
                            .margin(top: 4)
                        Link(to: "/blog") {
                            Button(.primary) { "Read the blog" }
                        }
                        .margin(top: 8)
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                    .padding(16, at: .desktop)
                }
            }
        }
        """ }

    private var defaultBlogIndexPage: String { """
        import Score

        struct BlogIndexPage: Page {
            let posts: [Post]

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
        """ }

    private var defaultBlogPostPage: String { """
        import Score

        struct BlogPostPage: Page {
            let post: Post

            var metadata: PageMetadata? {
                PageMetadata(
                    title: post.title,
                    description: post.excerpt,
                    ogType: .article,
                    canonicalURL: "/blog/\\(post.slug)"
                )
            }

            var contentTheme: ContentTheme { .article }

            var body: some View {
                Main {
                    Article {
                        Heading(1) { post.title }
                            .font(size: .fourXL, weight: .bold, wrap: .balance)
                        Text { post.excerpt }
                            .font(size: .lg, color: .muted)
                            .margin(top: 4)
                        Divider().margin(y: 8)
                        Text { post.body }
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                    .padding(12, at: .desktop)
                }
            }
        }
        """ }

    private func defaultSiteNavigation(_ name: String) -> String { """
        import Score

        struct SiteNavigation: View {
            var body: some View {
                Nav(label: "Main navigation") {
                    HStack {
                        Link(to: "/") { "\(name)" }
                            .font(weight: .semibold)
                        Spacer()
                        HStack {
                            NavLink(to: "/") { "Home" }
                            NavLink(to: "/blog") { "Blog" }
                        }
                        .flex(gap: 6)
                    }
                    .flex(align: .center)
                    .padding(x: 6, y: 4)
                    .frame(maxWidth: .px(1200))
                    .margin(x: .auto)
                }
                .border(color: .muted.opacity(0.15), edge: .bottom)
                .background(color: .surface)
                .position(.sticky, top: 0)
                .position(zIndex: 10)
            }
        }
        """ }

    private var defaultArticleCard: String { """
        import Score

        struct ArticleCard: View {
            let post: Post

            var body: some View {
                Link(to: "/blog/\\(post.slug)") {
                    VStack {
                        Heading(3) { post.title }
                            .font(size: .xl, weight: .semibold)
                        Text { post.excerpt }
                            .font(size: .sm, color: .muted)
                            .margin(top: 2)
                    }
                    .padding(6)
                    .border(color: .muted.opacity(0.2), radius: .lg)
                    .background(color: .surface)
                    .on(.hover) {
                        $0.shadow(.md)
                          .translate(y: .px(-2))
                    }
                    .animate(.all, duration: 150.ms)
                }
            }
        }
        """ }

    private func defaultSiteFooter(_ name: String) -> String { """
        import Score

        struct SiteFooter: View {
            var body: some View {
                Footer {
                    HStack {
                        Text { "© 2026 \(name). Built with " }
                            .font(size: .sm, color: .muted)
                        Link(to: "https://github.com/mac95sb/score") { "Score" }
                            .font(size: .sm, color: .primary)
                        Text { "." }
                            .font(size: .sm, color: .muted)
                    }
                    .flex(justify: .center)
                    .padding(8)
                }
                .border(color: .muted.opacity(0.15), edge: .top)
            }
        }
        """ }

    private func defaultContentThemes(_ name: String) -> String { """
        import Score

        extension ContentTheme {
            /// A customised content theme for blog posts.
            static var article: ContentTheme {
                ContentTheme(
                    heading: { level, v in
                        let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : level == 3 ? .twoXL : .xl
                        return v.erased().font(size: size, weight: .bold).margin(y: .rem(1))
                    },
                    paragraph: { v in
                        v.erased().font(size: .lg, leading: .relaxed).margin(y: .rem(0.75))
                    },
                    code: { v in
                        v.erased().font(family: .systemMono).padding(.px(2), .px(6)).border(radius: .sm).background(color: .surface)
                    },
                    blockquote: { v in
                        v.erased().border(color: .primary, width: 4, edge: .left).padding(left: 4).margin(y: .rem(1))
                    },
                    list: { _, v in v.erased().margin(y: .rem(0.75)).padding(left: 6) },
                    listItem: { v in v },
                    table: { v in v.erased().margin(y: .rem(1)) },
                    link: { v in v.erased().font(color: .primary, decoration: .underline) },
                    image: { v in v.erased().border(radius: .lg).margin(y: .rem(1.5)) },
                    divider: { v in v.erased().margin(y: .rem(2)) },
                    strong: { v in v.erased().font(weight: .semibold) },
                    emphasis: { v in v.erased().font(style: .italic) },
                    strikethrough: { v in v.erased().font(decoration: .lineThrough) }
                )
            }
        }
        """ }

    private var defaultPostsController: String { """
        import Score

        struct PostsController: RouteCollection {
            var routes: [Route] {
                RouteGroup("/blog") {
                    Page("/") { req in
                        let posts = try await db.query(Post.self)
                            .filter(\\.published == true)
                            .orderBy(\\.createdAt, .descending)
                            .all()
                        return BlogIndexPage(posts: posts)
                    }
                    Page("/:slug") { req in
                        guard let post = try await db.query(Post.self)
                            .filter(\\.slug == req.pathParameters["slug"]!)
                            .first()
                        else { throw HTTPError.notFound }
                        return BlogPostPage(post: post)
                    }
                }
                RouteGroup(api: "/posts") {
                    GET("/") { req in
                        let posts = try await db.query(Post.self)
                            .filter(\\.published == true)
                            .orderBy(\\.createdAt, .descending)
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
        """ }

    // MARK: - Static template sources

    private func staticApplication(_ name: String) -> String { """
        import Score

        @main
        struct \(name): Application {
            var metadata: SiteMetadata {
                SiteMetadata(
                    siteName: "\(name)",
                    titleSeparator: " — ",
                    description: "A static site built with Score.",
                    baseURL: "https://example.com"
                )
            }

            var theme: SiteTheme { .default }

            var routes: some RouteCollection {
                Page("/") { HomePage() }
                Page("/about") { AboutPage() }
                BlogPostPage.self
            }
        }
        """ }

    private func staticHomePage(_ name: String) -> String { """
        import Score

        struct HomePage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "Home", description: "Welcome to \(name).")
            }

            var body: some View {
                Main {
                    Section {
                        Heading(1) { "Welcome to \(name)" }
                            .font(size: .fourXL, weight: .bold, wrap: .balance)
                        Text { "A static site built with Score." }
                            .font(size: .xl, color: .muted)
                            .margin(top: 4)
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                    .padding(16, at: .desktop)
                }
            }
        }
        """ }

    private var staticAboutPage: String { """
        import Score

        struct AboutPage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "About", description: "About this site.")
            }

            var body: some View {
                Main {
                    Section {
                        Heading(1) { "About" }
                            .font(size: .threeXL, weight: .bold)
                        Text { "Learn more about this site." }
                            .font(size: .lg, color: .muted)
                            .margin(top: 4)
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }
        """ }

    private var staticBlogPostPage: String { """
        import Score

        struct BlogPostPage: Page {
            let post: ContentPost

            var metadata: PageMetadata? {
                PageMetadata(
                    title: post.frontmatter.title,
                    description: post.frontmatter.excerpt ?? "",
                    ogType: .article,
                    canonicalURL: "/blog/\\(post.slug)"
                )
            }

            var contentTheme: ContentTheme { .default }
            var path: String { "/blog/\\(post.slug)" }

            var body: some View {
                Main {
                    Article {
                        Heading(1) { post.frontmatter.title }
                            .font(size: .fourXL, weight: .bold, wrap: .balance)
                        RichText(markdown: post.content)
                            .margin(top: 8)
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }

        extension BlogPostPage: StaticPage {
            static func instances() async throws -> [Self] {
                try await ContentStore.posts()
                    .filter { $0.frontmatter.published }
                    .map { BlogPostPage(post: $0) }
            }
        }
        """ }

    private func staticSiteNavigation(_ name: String) -> String { """
        import Score

        struct SiteNavigation: View {
            var body: some View {
                Nav(label: "Main navigation") {
                    HStack {
                        Link(to: "/") { "\(name)" }
                            .font(weight: .semibold)
                        Spacer()
                        HStack {
                            NavLink(to: "/") { "Home" }
                            NavLink(to: "/blog") { "Blog" }
                            NavLink(to: "/about") { "About" }
                        }
                        .flex(gap: 6)
                    }
                    .flex(align: .center)
                    .padding(x: 6, y: 4)
                    .frame(maxWidth: .px(1200))
                    .margin(x: .auto)
                }
                .border(color: .muted.opacity(0.15), edge: .bottom)
                .background(color: .surface)
                .position(.sticky, top: 0)
                .position(zIndex: 10)
            }
        }
        """ }

    // MARK: - Minimal template sources

    private func minimalApplication(_ name: String) -> String { """
        import Score

        @main
        struct \(name): Application {
            var metadata: SiteMetadata {
                SiteMetadata(siteName: "\(name)", baseURL: "https://example.com")
            }

            var routes: some RouteCollection {
                Page("/") { WelcomePage() }
            }
        }

        struct WelcomePage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "Welcome", description: "A Score site.")
            }

            var body: some View {
                Main {
                    Section {
                        Heading(1) { "Hello from \(name)" }
                            .font(size: .fourXL, weight: .bold)
                        Text { "Edit Sources/Application.swift to get started." }
                            .font(size: .lg, color: .muted)
                            .margin(top: 4)
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }
        """ }

    // MARK: - Shared content

    private func helloWorldPost(_ name: String) -> String { """
        ---
        title: Hello World
        excerpt: My first post on \(name).
        date: 2026-01-15
        tags: [score, swift]
        published: true
        ---

        Welcome to \(name)! This is your first blog post.

        ## Getting started

        Edit this file at `Content/posts/hello-world.md` or create new posts in the same directory.

        Run `score dev` to start the development server with live reload.
        """ }

    private let faviconSVG: String = """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
          <rect width="32" height="32" rx="8" fill="#6366F1"/>
          <text x="16" y="22" font-size="18" text-anchor="middle" fill="white" font-family="system-ui">S</text>
        </svg>
        """

    // MARK: - Shared file writers

    private func writePackageSwift(to dir: URL, name: String) throws {
        let pkg = """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "\(name)",
            platforms: [.macOS(.v15)],
            dependencies: [
                .package(url: "https://github.com/mac95sb/score", branch: "main"),
            ],
            targets: [
                .executableTarget(
                    name: "\(name)",
                    dependencies: [
                        .product(name: "Score", package: "score"),
                    ],
                    path: "Sources"
                ),
            ]
        )
        """
        try write(pkg, to: dir, "Package.swift")
    }

    private func writeGitignore(to dir: URL) throws {
        try write("""
        .score/
        .build/
        *.o
        *.d
        """, to: dir, ".gitignore")
    }

    private func writeAgentsMD(to dir: URL, name: String, template: ProjectTemplate) throws {
        let structure: String
        switch template {
        case .default:
            structure = """
                - `Sources/Models/` — Record-conforming data models
                - `Sources/Views/Pages/` — Page views rendered by routes
                - `Sources/Views/Components/` — Reusable view components
                - `Sources/Controllers/` — RouteCollection controllers (pages + API)
                - `Sources/Application.swift` — App entry point and configuration
                - `Content/posts/` — Markdown content files with YAML frontmatter
                - `Public/` — Static assets copied verbatim to the build output
                """
        case .static:
            structure = """
                - `Sources/Views/Pages/` — Page views
                - `Sources/Views/Components/` — Reusable components
                - `Sources/Application.swift` — App entry point
                - `Content/posts/` — Markdown content
                - `Public/` — Static assets
                """
        case .minimal:
            structure = """
                - `Sources/Application.swift` — App entry point and page views
                - `Public/` — Static assets
                """
        }
        try write("""
        # \(name)

        A Score web application.

        ## Project structure

        \(structure)

        ## Running locally

        ```bash
        score dev
        ```

        ## Building for production

        ```bash
        score build
        ```
        """, to: dir, "AGENTS.md")
    }

    private func writeFavicon(to dir: URL) throws {
        try mkdir(dir, "Public")
        try write(faviconSVG, to: dir, "Public/favicon.svg")
    }

    // MARK: - Utilities

    private func mkdir(_ base: URL, _ path: String) throws {
        try FileManager.default.createDirectory(
            at: base.appendingPathComponent(path),
            withIntermediateDirectories: true
        )
    }

    private func write(_ content: String, to base: URL, _ path: String) throws {
        let url = base.appendingPathComponent(path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
