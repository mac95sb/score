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
        let ui = Noora()
        let projectDir = URL(fileURLWithPath: name)

        guard !FileManager.default.fileExists(atPath: projectDir.path) else {
            throw CLIError.directoryExists(name)
        }

        let name = self.name
        let template = self.template
        try await ui.progressStep(
            message: "Scaffolding \(name) (\(template.rawValue) template)",
            successMessage: "Scaffolded \(name)/",
            errorMessage: "Scaffolding failed",
            showSpinner: true
        ) { _ in
            let scaffold = ProjectScaffolder(template: template)
            try scaffold.write(to: projectDir, projectName: name)
        }

        if !skipResolve {
            try await ui.progressStep(
                message: "Resolving dependencies",
                successMessage: "Dependencies resolved",
                errorMessage: "Dependency resolution failed",
                showSpinner: true
            ) { _ in
                let p = Process()
                p.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
                p.arguments = ["package", "resolve"]
                p.currentDirectoryURL = projectDir
                try p.run()
                p.waitUntilExit()
            }
        }

        ui.success(.alert(
            "Created \(name)/",
            takeaways: ["cd \(name)", "score dev"]
        ))
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
    }

    // MARK: - Default template

    private func writeDefault(to dir: URL, name: String) throws {
        try writePackageSwift(to: dir, name: name)
        try writeGitignore(to: dir)
        try writeMakefile(to: dir, name: name)
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
        try writeMakefile(to: dir, name: name)
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
        try writeMakefile(to: dir, name: name)
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

    private func writeMakefile(to dir: URL, name: String) throws {
        let makefile = """
        # Common tasks for \(name). Run `make help` for a summary.
        CONTAINER ?= container

        dev: ## Start the dev server with hot-reload
        \tscore dev

        build: ## Build the static site to .score/build/
        \tscore build

        preview: ## Serve the static build locally
        \tscore preview

        test: ## Run the test suite
        \tswift test

        lint: ## Lint Score views
        \tscore lint

        routes: ## Print the route table
        \tscore routes

        package-windows: build ## Package as a Windows WebView2 app
        \tscore package windows --container-tool $(CONTAINER)

        package-android: build ## Package as an Android WebView app
        \tscore package android

        package-linux: build ## Package as a Linux WebKitGTK app
        \tscore package linux --container-tool $(CONTAINER)

        package-swiftui: ## Export Records + API client for SwiftUI apps
        \tscore package swiftui

        clean: ## Remove build artifacts
        \trm -rf .build .score/build dist

        help: ## Show this help
        \t@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  %-18s %s\\n", $$1, $$2}'

        .PHONY: dev build preview test lint routes package-windows package-android package-linux package-swiftui clean help
        """
        try write(makefile, to: dir.appendingPathComponent("Makefile"))
    }

    private func writeGitignore(to dir: URL) throws {
        let gitignore = """
        .build/
        .score/build/
        .score/dev/
        .score/cache/
        dist/
        *.o
        *.d
        """
        try write(gitignore, to: dir.appendingPathComponent(".gitignore"))
    }

    private func mkdir(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func write(_ content: String, to url: URL) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
