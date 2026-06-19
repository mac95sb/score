import Foundation

// MARK: - ProjectScaffolder

/// The canonical Score package URL used in scaffolded `Package.swift` files.
/// Update this when the repository moves to its public home.
let scorePackageURL = "https://github.com/swiftscore/score"

struct ProjectScaffolder: Sendable {
    let template: ProjectTemplate
    let agentsMode: AgentsMode

    init(template: ProjectTemplate, agentsMode: AgentsMode = .default) {
        self.template = template
        self.agentsMode = agentsMode
    }

    func write(to directory: URL, projectName: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Shared files
        try writePackageSwift(to: directory, name: projectName)
        try writeGitignore(to: directory)
        try writeFavicon(to: directory)

        if agentsMode.writesAgents {
            try writeAgentsMD(to: directory, name: projectName, template: template)
        }
        if agentsMode.writesClaude {
            try writeClaudeMD(to: directory)
        }

        switch template {
        case .default: try writeDefault(to: directory, name: projectName)
        case .static: try writeStatic(to: directory, name: projectName)
        case .kitchenSink: try writeKitchenSink(to: directory, name: projectName)
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

        try writeLocalizableStrings(to: dir, appName: name)
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

        try writeLocalizableStrings(to: dir, appName: name)
        try write(staticApplication(name), to: dir, "Sources/Application.swift")
        try write(staticHomePage(name), to: dir, "Sources/Views/Pages/HomePage.swift")
        try write(staticAboutPage, to: dir, "Sources/Views/Pages/AboutPage.swift")
        try write(staticBlogPostPage, to: dir, "Sources/Views/Pages/Blog/BlogPostPage.swift")
        try write(staticSiteNavigation(name), to: dir, "Sources/Views/Components/SiteNavigation.swift")
        try write(staticContentTheme, to: dir, "Sources/Views/ContentThemes.swift")
        try write(helloWorldPost(name), to: dir, "Content/posts/hello-world.md")
    }

    // MARK: - Default template sources

    private func defaultApplication(_ name: String) -> String {
        """
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
        """
    }

    private var defaultPostModel: String {
        """
        import Foundation
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
        """
    }

    private var defaultAuthorModel: String {
        """
        import Foundation
        import Score

        struct Author: Record {
            var id: UUID = UUID()
            var name: String
            var email: String
            var bio: String = ""
            var createdAt: Date = .now
            var updatedAt: Date = .now
        }
        """
    }

    private func defaultHomePage(_ name: String) -> String {
        """
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
        """
    }

    private var defaultBlogIndexPage: String {
        """
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
        """
    }

    private var defaultBlogPostPage: String {
        """
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
        """
    }

    private func defaultSiteNavigation(_ name: String) -> String {
        """
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
        """
    }

    private var defaultArticleCard: String {
        """
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
        """
    }

    private func defaultSiteFooter(_ name: String) -> String {
        """
        import Score

        struct SiteFooter: View {
            var body: some View {
                Footer {
                    HStack {
                        Text { "© 2026 \(name). Built with " }
                            .font(size: .sm, color: .muted)
                        Link(to: "https://github.com/swiftscore/score") { "Score" }
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
        """
    }

    private func defaultContentThemes(_ name: String) -> String {
        """
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
        """
    }

    private var defaultPostsController: String {
        """
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
                        return try Response.json(posts)
                    }
                    GET("/:id") { req in
                        guard let post = try await db.find(Post.self, id: req.pathParameter("id"))
                        else { throw HTTPError.notFound }
                        return try Response.json(post)
                    }
                }
            }
        }
        """
    }

    // MARK: - Static template sources

    private func staticApplication(_ name: String) -> String {
        """
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
        """
    }

    private func staticHomePage(_ name: String) -> String {
        """
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
        """
    }

    private var staticAboutPage: String {
        """
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
        """
    }

    private var staticBlogPostPage: String {
        """
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

            var contentTheme: ContentTheme { .prose }
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
        """
    }

    private func staticSiteNavigation(_ name: String) -> String {
        """
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
        """
    }

    private var staticContentTheme: String {
        """
        import Score

        extension ContentTheme {
            /// Site-specific prose style. Customise any closure to override
            /// how that markdown element is rendered — other elements fall back
            /// to their default rendering.
            static let prose = ContentTheme(
                heading: { level, v in
                    let size: FontSize = level <= 2 ? .threeXL : .twoXL
                    return v.erased().font(size: size, weight: .bold).margin(top: 8, bottom: 2)
                },
                paragraph: { v in
                    v.erased().font(leading: .relaxed)
                },
                code: { v in
                    v.erased().font(family: .systemMono)
                        .padding(.px(2), .px(6))
                        .border(radius: .sm)
                        .background(color: .surface)
                },
                blockquote: { v in
                    v.erased()
                        .border(color: .accent, width: 4, edge: .left)
                        .padding(x: .rem(1.5), y: .rem(1))
                        .font(color: .muted, style: .italic)
                },
                link: { v in
                    v.erased().font(color: .primary, decoration: .underline)
                }
            )
        }
        """
    }

    // MARK: - Shared content

    private func helloWorldPost(_ name: String) -> String {
        """
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
        """
    }

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
                    .package(url: "\(scorePackageURL)", branch: "main"),
                ],
                targets: [
                    .executableTarget(
                        name: "\(name)",
                        dependencies: [
                            .product(name: "Score", package: "score"),
                        ],
                        path: "Sources",
                        resources: [
                            .process("Localizable.xcstrings"),
                        ]
                    ),
                ]
            )
            """
        try write(pkg, to: dir, "Package.swift")
    }

    private func writeGitignore(to dir: URL) throws {
        try write(
            """
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
                - `Sources/Application.swift` — `@main` entry point: metadata, theme, routes, database
                - `Sources/Models/` — `Record`-conforming data models (one file per model)
                - `Sources/Views/Pages/` — `Page` views rendered by routes
                - `Sources/Views/Components/` — Reusable `View` components
                - `Sources/Controllers/` — `RouteCollection` grouping related page and API routes
                - `Content/posts/` — Markdown files with YAML frontmatter (`published`, `title`, `excerpt`, `date`)
                - `Public/` — Static assets copied verbatim to build output
                """
        case .static:
            structure = """
                - `Sources/Application.swift` — `@main` entry point: metadata, theme, routes
                - `Sources/Views/Pages/` — `Page` / `StaticPage` views
                - `Sources/Views/Components/` — Reusable `View` components
                - `Content/posts/` — Markdown content with YAML frontmatter
                - `Public/` — Static assets
                """
        case .kitchenSink:
            structure = """
                - `Sources/Application.swift` — `@main` entry point
                - `Sources/Views/Pages/` — Demo pages for each Score feature area
                - `Sources/Views/Components/` — Shared navigation component
                - `Public/` — Static assets
                """
        }
        try write(
            """
            # \(name)

            A Score web application. Score is a Swift-first full-stack web framework.
            Documentation: https://swiftscore.github.io/score/documentation/score

            ## Project structure

            \(structure)

            ## Commands

            ```sh
            score dev              # development server with hot-reload on :8080
            score build            # production build → .score/build/
            score lint             # accessibility, semantic, and structure checks
            score lint --fix       # auto-fix fixable lint issues
            score generate page MyPage         # → Sources/Views/Pages/MyPage.swift
            score generate component MyCard    # → Sources/Views/Components/MyCard.swift
            score generate controller MyCtrl  # → Sources/Controllers/MyCtrl.swift
            score generate record MyModel     # → Sources/Models/MyModel.swift
            score routes           # print registered route table
            ```

            ## Score quick reference

            ### Layout elements

            | Element | Description |
            | ------- | ----------- |
            | `Stack` | Block flex container (vertical by default) |
            | `HStack` | Horizontal flex container |
            | `VStack` | Vertical flex container |
            | `ZStack` | Layered (position: relative) container |
            | `Grid(columns:)` | CSS grid container |
            | `Spacer` | Flexible-space filler |
            | `Divider` | Horizontal or vertical rule |
            | `ScrollView` | Scrollable container |

            ### Content elements

            `Heading(1…6)`, `Text`, `Text(inline: true)`, `Blockquote`,
            `Code`, `CodeBlock(language:)`, `RichText(markdown:)`,
            `Badge(.primary/.secondary/.success/.destructive/.neutral)`,
            `Abbreviation`, `Highlight`, `Subscript`, `Superscript`,
            `DateElement`, `NumberElement`, `TimeElement`

            ### Semantic elements

            `Main`, `Section`, `Article`, `Aside`, `Header`, `Footer`, `Nav`,
            `Details`, `Summary`

            ### Navigation elements

            `Link(to:)`, `NavLink(to:)` (adds `.active` when route matches),
            `Button(.primary/.secondary/.ghost/.outline/.destructive/.submit)`

            ### Form elements

            `Form(action:method:)`, `Fieldset`, `Legend`, `Label(for:)`,
            `Input(type:id:name:placeholder:)` — types: `.text .email .password .number
            .tel .url .search .textarea .checkbox .radio .file .hidden .date .select`,
            `Option(value:)`, `OptionGroup`

            ### Media and native

            `Image(src:alt:)`, `Audio(src:)`, `Video(src:)`,
            `Dialog(id:)`, `Popover(id:)`, `Progress(value:max:)`,
            `Meter(value:min:max:)`, `ThemeSelector`

            ### Lists and tables

            `List`, `ListItem`, `DescriptionList`, `Term`, `Description`
            `Table`, `TableHeader`, `TableBody`, `TableFooter`, `TableRow`, `TableCell`

            ### Key modifiers

            ```swift
            // Spacing
            .padding(4)                  // uniform
            .padding(x: 6, y: 2)        // axes
            .margin(x: .auto)           // centering
            .frame(maxWidth: .px(720))

            // Typography
            .font(size: .xl, weight: .semibold, color: .muted)
            // sizes: .xs .sm .base .lg .xl .twoXL .threeXL .fourXL .fiveXL .sixXL
            // weights: .thin .light .normal .medium .semibold .bold .extrabold .black

            // Visual
            .background(color: .surface)
            .border(color: .muted.opacity(0.2), width: 1, radius: .lg)
            .shadow(.md)
            .opacity(0.5)

            // Layout
            .flex(direction: .horizontal, gap: 4, justify: .between, align: .center)
            .grid(columns: 3, gap: 4)
            .display(.none)
            .overflow(.hidden)
            .position(.sticky, top: 0)
            .position(zIndex: 10)

            // Responsive (any modifier accepts `, at:`)
            .padding(4, at: .mobile)
            .padding(8, at: .desktop)

            // Hover / focus / active state
            .on(.hover) { $0.shadow(.lg).translate(y: .px(-2)) }

            // Animation
            .animate(.all, duration: 150.ms)
            ```

            ### State and interactivity

            ```swift
            @State var count: Int = 0          // reactive local state → re-renders on change
            @Binding var text: String          // two-way binding from parent
            @Action var submit: (Input) async throws -> Response  // server action
            ```

            ### Routing

            ```swift
            // In Application.swift
            var routes: some RouteCollection {
                Page("/") { HomePage() }
                Page("/blog/:slug") { req in BlogPostPage(slug: req.pathParameters["slug"]!) }
                PostsController()
            }

            // RouteCollection
            struct PostsController: RouteCollection {
                var routes: [Route] {
                    RouteGroup("/blog") {
                        Page("/") { req in BlogIndexPage() }
                    }
                    RouteGroup(api: "/posts") {
                        GET("/")  { req in try Response.json(posts) }
                        POST("/") { req in
                            let body = try req.decode(CreatePost.self)
                            return try Response.json(body)
                        }
                    }
                }
            }
            ```

            ### Data layer

            ```swift
            // Query
            let posts = try await db.query(Post.self)
                .filter(\\.published == true)
                .orderBy(\\.createdAt, .descending)
                .limit(10)
                .all()

            // CRUD
            let post = try await db.find(Post.self, id: id)
            try await db.insert(post)
            try await db.update(post)
            try await db.delete(Post.self, id: id)
            ```

            ### Theming

            ```swift
            var theme: SiteTheme { .default }

            // Preset + palette
            var theme: SiteTheme { .preset(.modern, palette: .violet) }

            // With component styles enabled
            var theme: SiteTheme {
                var t = SiteTheme.preset(.soft, palette: .indigo)
                t.components = .default
                return t
            }
            ```

            Presets: `.minimal` `.modern` `.soft` `.neoBrutalism`
            Palettes: `.slate` `.zinc` `.stone` `.rose` `.pink` `.fuchsia` `.violet`
            `.indigo` `.blue` `.sky` `.cyan` `.teal` `.green` `.lime` `.yellow` `.amber` `.orange` `.red`
            """,
            to: dir,
            "AGENTS.md"
        )
    }

    private func writeClaudeMD(to dir: URL) throws {
        try write(
            """
            # Claude guidance

            See `AGENTS.md` for full project structure, Score API reference, and build/run instructions.

            ## Working in this Score project

            - Pages go in `Sources/Views/Pages/`, shared components in `Sources/Views/Components/`
            - Data models go in `Sources/Models/`, route controllers in `Sources/Controllers/`
            - Keep `Application.swift` thin — only `metadata`, `theme`, `routes`, and `database`
            - Avoid raw `style`, `class`, or inline event attributes — use Score modifiers and `@State`/`@Action`
            - Run `score lint` before committing to catch accessibility and structure issues
            """,
            to: dir,
            "CLAUDE.md"
        )
    }

    // MARK: - Kitchen-sink template

    private func writeKitchenSink(to dir: URL, name: String) throws {
        try mkdir(dir, "Sources/Views/Pages")
        try mkdir(dir, "Sources/Views/Components")
        try mkdir(dir, "Public")

        try write(kitchenSinkApplication(name), to: dir, "Sources/Application.swift")
        try write(kitchenSinkHomePage(name), to: dir, "Sources/Views/Pages/HomePage.swift")
        try write(kitchenSinkElementsPage, to: dir, "Sources/Views/Pages/ElementsPage.swift")
        try write(kitchenSinkFormsPage, to: dir, "Sources/Views/Pages/FormsPage.swift")
        try write(kitchenSinkNavigation(name), to: dir, "Sources/Views/Components/SiteNavigation.swift")
    }

    private func kitchenSinkApplication(_ name: String) -> String {
        """
        import Score

        @main
        struct \(name): Application {
            var metadata: SiteMetadata {
                SiteMetadata(
                    siteName: "\(name)",
                    titleSeparator: " — ",
                    description: "A kitchen-sink demo of Score's elements and features.",
                    baseURL: "https://example.com"
                )
            }

            var theme: SiteTheme {
                var t = SiteTheme.default
                t.components = .default
                return t
            }

            var routes: some RouteCollection {
                Page("/")          { HomePage() }
                Page("/elements")  { ElementsPage() }
                Page("/forms")     { FormsPage() }
            }
        }
        """
    }

    private func kitchenSinkHomePage(_ name: String) -> String {
        """
        import Score

        struct HomePage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "Home", description: "Score kitchen-sink demo.")
            }

            var body: some View {
                Main {
                    Section(id: "hero") {
                        VStack {
                            Heading(1) { "Score Kitchen Sink" }
                                .font(size: .fiveXL, weight: .bold, wrap: .balance)
                            Text { "Every element, modifier, and layout primitive in one place." }
                                .font(size: .xl, color: .muted)
                                .margin(top: 4)
                            HStack {
                                Link(to: "/elements") { Button(.primary) { "Elements" } }
                                Link(to: "/forms")    { Button(.secondary) { "Forms" } }
                            }
                            .flex(gap: 4)
                            .margin(top: 8)
                        }
                        .flex(align: .center)
                        .padding(16)
                    }

                    Section(id: "layout") {
                        Heading(2) { "Layout" }
                            .font(size: .threeXL, weight: .semibold)
                            .margin(bottom: 6)

                        Grid(columns: 3) {
                            for label in ["HStack", "VStack", "Grid"] {
                                VStack {
                                    Text { label }
                                        .font(weight: .semibold)
                                    Text { "Flex / grid container" }
                                        .font(size: .sm, color: .muted)
                                }
                                .padding(6)
                                .border(radius: .lg)
                                .background(color: .secondary)
                            }
                        }
                        .flex(gap: 4)
                    }
                    .frame(maxWidth: .px(960))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }
        """
    }

    private var kitchenSinkElementsPage: String {
        """
        import Score

        struct ElementsPage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "Elements", description: "All Score elements.")
            }

            var body: some View {
                Main {
                    VStack {
                        Heading(1) { "Content Elements" }
                            .font(size: .fourXL, weight: .bold)

                        // Headings
                        VStack {
                            for level in 1...6 {
                                Heading(level) { "Heading \\(level)" }
                            }
                        }
                        .margin(top: 8)

                        // Text and inline
                        Text { "A block paragraph of body text with " }
                        Text(inline: true) { "an inline span" }
                        Blockquote { "A famous quote attributed to someone." }
                            .border(color: .primary, width: 4, edge: .left)
                            .padding(left: 4)
                            .margin(y: 4)

                        // Semantic containers
                        Article {
                            Heading(2) { "Article" }
                            Text { "Self-contained content unit." }
                        }
                        .padding(6)
                        .border(radius: .lg)
                        .background(color: .secondary)
                        .margin(top: 4)

                        // Badges and highlights
                        HStack {
                            Badge(.neutral) { "Neutral" }
                            Badge(.primary) { "Primary" }
                            Badge(.success) { "Success" }
                            Badge(.destructive) { "Destructive" }
                        }
                        .flex(gap: 2)
                        .margin(top: 4)

                        // Buttons
                        HStack {
                            Button(.primary)     { "Primary" }
                            Button(.secondary)   { "Secondary" }
                            Button(.ghost)       { "Ghost" }
                            Button(.outline)     { "Outline" }
                            Button(.destructive) { "Destructive" }
                        }
                        .flex(gap: 2)
                        .margin(top: 4)

                        // Navigation
                        HStack {
                            Link(to: "/") { "Home" }
                            NavLink(to: "/elements") { "Elements" }
                            NavLink(to: "/forms") { "Forms" }
                        }
                        .flex(gap: 4)
                        .margin(top: 4)

                        Divider().margin(y: 6)

                        // RichText
                        RichText(markdown: "## Markdown\\n\\nThis is rendered from **Markdown**. [Learn more](/elements).\\n\\n- Item one\\n- Item two\\n- Item three")
                    }
                    .frame(maxWidth: .px(720))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }
        """
    }

    private var kitchenSinkFormsPage: String {
        """
        import Score

        struct FormsPage: Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "Forms", description: "Score form elements.")
            }

            var body: some View {
                Main {
                    VStack {
                        Heading(1) { "Form Elements" }
                            .font(size: .fourXL, weight: .bold)

                        Form(action: "/submit", method: .post) {
                            Fieldset {
                                Legend { "Personal Details" }

                                Label(for: "name") { "Full name" }
                                Input(type: .text, id: "name", name: "name", placeholder: "Jane Smith")
                                    .frame(width: .full)
                                    .margin(top: 1, bottom: 4)

                                Label(for: "email") { "Email" }
                                Input(type: .email, id: "email", name: "email", placeholder: "jane@example.com")
                                    .frame(width: .full)
                                    .margin(top: 1, bottom: 4)

                                Label(for: "bio") { "Bio" }
                                Input(type: .textarea, id: "bio", name: "bio", placeholder: "Tell us about yourself…")
                                    .frame(width: .full, height: .px(120))
                                    .margin(top: 1)
                            }
                            .padding(6)
                            .border(radius: .lg)
                            .background(color: .secondary)

                            Button(.submit, type: .submit) { "Save" }
                                .margin(top: 6)
                        }
                    }
                    .frame(maxWidth: .px(560))
                    .margin(x: .auto)
                    .padding(8)
                }
            }
        }
        """
    }

    private func kitchenSinkNavigation(_ name: String) -> String {
        """
        import Score

        struct SiteNavigation: View {
            var body: some View {
                Nav(label: "Main navigation") {
                    HStack {
                        Link(to: "/") { "\\(name)" }
                            .font(weight: .semibold)
                        Spacer()
                        HStack {
                            NavLink(to: "/")         { "Home" }
                            NavLink(to: "/elements") { "Elements" }
                            NavLink(to: "/forms")    { "Forms" }
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
        """
    }

    private func writeFavicon(to dir: URL) throws {
        try mkdir(dir, "Public")
        try write(faviconSVG, to: dir, "Public/favicon.svg")
    }

    /// Write a `Localizable.xcstrings` file pre-seeded with the app name and
    /// a handful of common UI strings, translated into EN, ES, DE, RU, and ZH.
    private func writeLocalizableStrings(to dir: URL, appName: String) throws {
        let catalog = """
            {
              "sourceLanguage" : "en",
              "strings" : {
                "app.name" : {
                  "comment" : "The application name shown in the navigation and browser title.",
                  "localizations" : {
                    "de" : { "stringUnit" : { "state" : "translated", "value" : "\(appName)" } },
                    "en" : { "stringUnit" : { "state" : "new",        "value" : "\(appName)" } },
                    "es" : { "stringUnit" : { "state" : "translated", "value" : "\(appName)" } },
                    "ru" : { "stringUnit" : { "state" : "translated", "value" : "\(appName)" } },
                    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "\(appName)" } }
                  }
                },
                "nav.home" : {
                  "comment" : "Home link in the main navigation.",
                  "localizations" : {
                    "de" : { "stringUnit" : { "state" : "translated", "value" : "Startseite" } },
                    "en" : { "stringUnit" : { "state" : "new",        "value" : "Home" } },
                    "es" : { "stringUnit" : { "state" : "translated", "value" : "Inicio" } },
                    "ru" : { "stringUnit" : { "state" : "translated", "value" : "Главная" } },
                    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "首页" } }
                  }
                },
                "nav.blog" : {
                  "comment" : "Blog link in the main navigation.",
                  "localizations" : {
                    "de" : { "stringUnit" : { "state" : "translated", "value" : "Blog" } },
                    "en" : { "stringUnit" : { "state" : "new",        "value" : "Blog" } },
                    "es" : { "stringUnit" : { "state" : "translated", "value" : "Blog" } },
                    "ru" : { "stringUnit" : { "state" : "translated", "value" : "Блог" } },
                    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "博客" } }
                  }
                },
                "action.read_more" : {
                  "comment" : "Call-to-action label on article cards.",
                  "localizations" : {
                    "de" : { "stringUnit" : { "state" : "translated", "value" : "Weiterlesen" } },
                    "en" : { "stringUnit" : { "state" : "new",        "value" : "Read more" } },
                    "es" : { "stringUnit" : { "state" : "translated", "value" : "Leer más" } },
                    "ru" : { "stringUnit" : { "state" : "translated", "value" : "Читать далее" } },
                    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "阅读更多" } }
                  }
                },
                "footer.built_with" : {
                  "comment" : "Footer attribution text.",
                  "localizations" : {
                    "de" : { "stringUnit" : { "state" : "translated", "value" : "Erstellt mit Score." } },
                    "en" : { "stringUnit" : { "state" : "new",        "value" : "Built with Score." } },
                    "es" : { "stringUnit" : { "state" : "translated", "value" : "Creado con Score." } },
                    "ru" : { "stringUnit" : { "state" : "translated", "value" : "Создано на Score." } },
                    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "由 Score 构建。" } }
                  }
                }
              },
              "version" : "1.0"
            }
            """
        try write(catalog, to: dir, "Sources/Localizable.xcstrings")
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
