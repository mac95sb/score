import ArgumentParser
import Foundation

/// `score routes` — print all registered routes in a tabular format.
///
/// Builds the app in debug mode and invokes it with `--list-routes` to obtain
/// the full route table, then prints a formatted summary.
struct RoutesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "routes",
        abstract: "List all registered routes."
    )

    @Flag(name: .long, help: "Output as JSON.")
    var json: Bool = false

    @Flag(name: .long, help: "Include middleware chain for each route.")
    var showMiddleware: Bool = false

    mutating func run() async throws {
        let built = try await buildPackage(configuration: "debug", verbose: false)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()
        var args = ["--list-routes"]
        if json { args.append("--format=json") }
        if showMiddleware { args.append("--show-middleware") }

        let output = try captureOutput(binary: binaryURL, arguments: args)
        print(output.trimmingCharacters(in: .newlines))
    }
}
