import ArgumentParser
import Foundation
import Logging
import Noora
import ScorePackaging

/// `score dev` — start the development server with hot-reload.
///
/// Compiles the app in debug mode, starts the NIO server on `localhost`,
/// watches source files for changes, and pushes reload events to the browser
/// via a Server-Sent Events endpoint (`/__score/dev`).
struct DevCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dev",
        abstract: "Start the development server with hot-reload."
    )

    @Option(name: .shortAndLong, help: "Port to listen on.")
    var port: Int = 8080

    @Option(name: .shortAndLong, help: "Host to bind to.")
    var host: String = "localhost"

    @Flag(name: .long, help: "Disable hot-reload.")
    var noHotReload: Bool = false

    @Flag(name: .long, help: "Verbose compiler and server output.")
    var verbose: Bool = false

    mutating func run() async throws {
        let ui = Noora()
        ui.info(.alert(
            "score dev → http://\(host):\(port)",
            takeaways: ["Press Ctrl-C to stop"]
        ))

        regenerateEmbeddedKits()

        // Initial build
        let verbose = self.verbose
        try await ui.progressStep(
            message: "Compiling (debug)",
            successMessage: "Compiled",
            errorMessage: "Build failed",
            showSpinner: !verbose
        ) { _ in
            guard try await buildPackage(configuration: "debug", verbose: verbose) else {
                throw CLIError.buildFailed
            }
        }

        let binaryURL = try locateExecutable()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.runServer(binaryURL: binaryURL)
            }

            if !self.noHotReload {
                group.addTask {
                    await self.watchForChanges(binaryURL: binaryURL)
                }
            }

            // Cancel everything on first task completion
            try await group.next()
            group.cancelAll()
        }
    }

    // MARK: - Server

    private func runServer(binaryURL: URL) async throws {
        let process = Process()
        process.executableURL = binaryURL
        process.arguments = ["--host", host, "--port", "\(port)", "--dev"]
        process.environment = ProcessInfo.processInfo.environment
            .merging(["SCORE_DEV_RELOAD": "1"]) { _, new in new }
        try process.run()
        process.waitUntilExit()
        Noora().warning(.alert("Server exited with status \(process.terminationStatus)"))
    }

    // MARK: - File watcher

    private func watchForChanges(binaryURL: URL) async {
        let directories = [
            URL(fileURLWithPath: "Sources"),
            URL(fileURLWithPath: "Content"),
            URL(fileURLWithPath: "Public"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }

        var lastModDates: [URL: Date] = [:]

        while !Task.isCancelled {
            let changed = pollChanges(in: directories, lastDates: &lastModDates)
            if !changed.isEmpty {
                let ui = Noora()
                let files = changed.map(\.lastPathComponent).joined(separator: ", ")
                regenerateEmbeddedKits()
                let verbose = self.verbose
                _ = try? await ui.progressStep(
                    message: "Rebuilding (\(files))",
                    successMessage: "Rebuilt — reload your browser",
                    errorMessage: "Rebuild failed",
                    showSpinner: !verbose
                ) { _ in
                    guard try await buildPackage(configuration: "debug", verbose: verbose) else {
                        throw CLIError.buildFailed
                    }
                }
            }
            try? await Task.sleep(for: .milliseconds(500))
        }
    }

    private func pollChanges(
        in directories: [URL],
        lastDates: inout [URL: Date]
    ) -> [URL] {
        var changed: [URL] = []
        let fm = FileManager.default

        for dir in directories {
            guard let enumerator = fm.enumerator(
                at: dir,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { continue }

            while let fileURL = enumerator.nextObject() as? URL {
                guard let attrs = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                      let modDate = attrs.contentModificationDate else { continue }

                if let last = lastDates[fileURL], modDate > last {
                    lastDates[fileURL] = modDate
                    changed.append(fileURL)
                } else if lastDates[fileURL] == nil {
                    lastDates[fileURL] = modDate
                }
            }
        }
        return changed
    }
}

// MARK: - Embedded kit regeneration

/// Regenerate any `score package swiftui` kit targets before compiling, so
/// exported models and endpoints always match the application's current API.
func regenerateEmbeddedKits() {
    let regenerated = KitRegenerator.regenerateEmbeddedKits()
    if !regenerated.isEmpty {
        Noora().info(.alert(
            "Regenerated \(regenerated.joined(separator: ", ")) (Records + API endpoints)"
        ))
    }
}

// MARK: - BuildCommand

/// `score build` — generate a static site from all `StaticPage` routes.
///
/// Compiles the app in release mode, renders every ``StaticPage`` route to
/// HTML, collects and fingerprints CSS, copies the `Public/` directory, and
/// writes an `asset-manifest.json`.
struct BuildCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the site to .score/build/."
    )

    @Flag(name: .long, help: "Skip minification (faster but larger output).")
    var noMinify: Bool = false

    @Flag(name: .long, help: "Skip asset fingerprinting.")
    var noFingerprint: Bool = false

    @Flag(name: .long, help: "Verbose compiler output.")
    var verbose: Bool = false

    @Option(name: .long, help: "Output directory (default: .score/build).")
    var output: String = ".score/build"

    mutating func run() async throws {
        let ui = Noora()
        let start = Date()

        regenerateEmbeddedKits()

        let verbose = self.verbose
        try await ui.progressStep(
            message: "Compiling (release)",
            successMessage: "Compiled",
            errorMessage: "Build failed",
            showSpinner: !verbose
        ) { _ in
            guard try await buildPackage(configuration: "release", verbose: verbose) else {
                throw CLIError.buildFailed
            }
        }

        let binaryURL = try locateExecutable()
        var args = ["--build-only", "--output", output]
        if noMinify { args.append("--no-minify") }
        if noFingerprint { args.append("--no-fingerprint") }

        let arguments = args
        try await ui.progressStep(
            message: "Generating static site",
            successMessage: "Static site generated",
            errorMessage: "Static generation failed",
            showSpinner: true
        ) { _ in
            let process = Process()
            process.executableURL = binaryURL
            process.arguments = arguments
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { throw CLIError.buildFailed }
        }

        let elapsed = String(format: "%.2f", Date().timeIntervalSince(start))
        ui.success(.alert("Built in \(elapsed)s → \(output)"))
    }
}
