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

    @Option(name: .shortAndLong, help: "Template to use: default, static, kitchen-sink.")
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
                p.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
                p.arguments = ["swift", "package", "resolve"]
                p.currentDirectoryURL = projectDir
                try p.run()
                p.waitUntilExit()
            }
        }

        noora.success(
            .alert(
                "Created \(name)/",
                takeaways: [
                    "cd \(name)",
                    "score dev",
                ]))
    }
}
