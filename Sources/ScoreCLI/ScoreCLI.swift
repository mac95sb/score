import ArgumentParser
import Foundation

/// The `score` command-line tool.
///
/// Entry point for all Score developer tooling: local development server,
/// static-site builds, project scaffolding, and code generation.
@main
struct ScoreCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "score",
        abstract: "Score — Swift-first full-stack web framework",
        version: "0.1.0",
        subcommands: [
            DevCommand.self,
            BuildCommand.self,
            NewCommand.self,
            PreviewCommand.self,
            RoutesCommand.self,
            ManifestCommand.self,
            LintCommand.self,
            TranslationsCommand.self,
            GenerateCommand.self,
        ],
        defaultSubcommand: nil
    )
}
