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
        let projectDir = URL(fileURLWithPath: name)

        guard !FileManager.default.fileExists(atPath: projectDir.path) else {
            throw CLIError.directoryExists(name)
        }

        let scaffold = ProjectScaffolder(template: template)

        try await noora.progressStep(
            message: "Creating \(name) (\(template.rawValue) template)…"
        ) { _ in
            try scaffold.write(to: projectDir, projectName: name)
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
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)

        switch template {
        case .default:
            try writeDefault(to: directory, name: projectName)
        case .static:
            try writeStatic(to: directory, name: projectName)
        case .minimal:
            try writeMinimal(to: directory, name: projectName)
        }

        try writeAgentsMD(to: directory, name: projectName)
    }

    // MARK: - Default template

    private func writeDefault(to dir: URL, name: String) throws {
        try writePackageSwift(to: dir, name: name)
        try writeGitignore(to: dir)
        try mkdir(dir.appendingPathComponent("Sources/\(name)"))
        try mkdir(dir.appendingPathComponent("Public"))
        try mkdir(dir.appendingPathComponent("Content"))

        let appSwift = """
        import Score

        @main
        struct \(name)App: Application {
            var metadata: SiteMetadata {
                SiteMetadata(title: "\(name)", baseURL: "http://localhost:8080")
            }

            @RouteBuilder
            var routes: some RouteCollection {
                Page(path: "/", page: HomePage())
            }
        }

        struct HomePage: Page {
            var body: some View {
                Main {
                    VStack {
                        Heading(1) { "Welcome to \(name)" }
                        Text { "Built with Score." }
                    }
                }
            }
        }
        """
        try write(appSwift, to: dir.appendingPathComponent("Sources/\(name)/App.swift"))
    }

    // MARK: - Static template

    private func writeStatic(to dir: URL, name: String) throws {
        try writePackageSwift(to: dir, name: name)
        try writeGitignore(to: dir)
        try mkdir(dir.appendingPathComponent("Sources/\(name)"))
        try mkdir(dir.appendingPathComponent("Public"))
        try mkdir(dir.appendingPathComponent("Content"))

        let appSwift = """
        import Score

        @main
        struct \(name)App: Application {
            var metadata: SiteMetadata {
                SiteMetadata(title: "\(name)", baseURL: "https://example.com")
            }

            @RouteBuilder
            var routes: some RouteCollection {
                Page(path: "/", page: HomePage())
                Page(path: "/about", page: AboutPage())
            }
        }

        struct HomePage: StaticPage {
            static let path = "/"
            static func instances() -> [HomePage] { [HomePage()] }

            var body: some View {
                Main {
                    Heading(1) { "Home" }
                }
            }
        }

        struct AboutPage: StaticPage {
            static let path = "/about"
            static func instances() -> [AboutPage] { [AboutPage()] }

            var body: some View {
                Main {
                    Heading(1) { "About" }
                }
            }
        }
        """
        try write(appSwift, to: dir.appendingPathComponent("Sources/\(name)/App.swift"))
    }

    // MARK: - Minimal template

    private func writeMinimal(to dir: URL, name: String) throws {
        try writePackageSwift(to: dir, name: name)
        try writeGitignore(to: dir)
        try mkdir(dir.appendingPathComponent("Sources/\(name)"))

        let appSwift = """
        import Score

        @main
        struct \(name)App: Application {
            var metadata: SiteMetadata {
                SiteMetadata(title: "\(name)", baseURL: "http://localhost:8080")
            }

            @RouteBuilder
            var routes: some RouteCollection {
                Page(path: "/", page: MinimalPage())
            }
        }

        struct MinimalPage: Page {
            var body: some View {
                Text { "Hello, Score." }
            }
        }
        """
        try write(appSwift, to: dir.appendingPathComponent("Sources/\(name)/App.swift"))
    }

    // MARK: - Shared helpers

    private func writePackageSwift(to dir: URL, name: String) throws {
        let pkg = """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "\(name)",
            platforms: [.macOS(.v15)],
            dependencies: [
                .package(url: "https://github.com/mac95sb/score.git", branch: "main"),
            ],
            targets: [
                .executableTarget(
                    name: "\(name)",
                    dependencies: [
                        .product(name: "Score", package: "score"),
                    ]
                ),
            ]
        )
        """
        try write(pkg, to: dir.appendingPathComponent("Package.swift"))
    }

    private func writeGitignore(to dir: URL) throws {
        let gitignore = """
        .build/
        .score/build/
        .score/dev/
        .score/cache/
        *.o
        *.d
        """
        try write(gitignore, to: dir.appendingPathComponent(".gitignore"))
    }

    private func writeAgentsMD(to dir: URL, name: String) throws {
        let content = """
        # \(name)

        A Score web application.

        ## Development

        ```bash
        score dev       # start dev server with hot-reload on :8080
        score build     # production build to .score/build/
        score preview   # serve the build output locally on :4173
        ```

        ## Commands

        ```bash
        score generate page <Name>       # scaffold a new page
        score generate component <Name>  # scaffold a reusable component
        score generate record <Name>     # scaffold a database record
        score lint                       # lint Score views
        score routes                     # list all registered routes
        ```

        ## Project structure

        ```
        Sources/\(name)/
          App.swift       # Application entry point and route table
        Content/          # Markdown content files
        Public/           # Static assets copied verbatim to build output
        ```
        """
        try write(content, to: dir.appendingPathComponent("AGENTS.md"))
    }

    private func mkdir(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func write(_ content: String, to url: URL) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
