import ArgumentParser
import Foundation
import Noora

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
        try await Noora().progressStep(
            message: "Compiling (debug)",
            successMessage: nil,
            errorMessage: "Build failed",
            showSpinner: true
        ) { _ in
            guard try await buildPackage(configuration: "debug", verbose: false) else {
                throw CLIError.buildFailed
            }
        }

        let binaryURL = try locateExecutable()
        var args = ["--list-routes"]
        if json { args.append("--format=json") }
        if showMiddleware { args.append("--show-middleware") }

        let pipe = Pipe()
        let process = Process()
        process.executableURL = binaryURL
        process.arguments = args
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        // Route-table data (possibly JSON) — written to stdout verbatim by design.
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        print(output.trimmingCharacters(in: .newlines))
    }
}
