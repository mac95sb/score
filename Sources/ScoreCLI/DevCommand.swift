import ArgumentParser
import Foundation
import Logging
import Noora

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
        let noora = Noora()
        noora.info(.alert(
            "score dev",
            takeaways: ["http://\(host):\(port)", "Press Ctrl-C to stop"]
        ))

        let built = try await buildPackage(configuration: "debug", verbose: verbose)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()
        let serverBox = ServerProcessBox()

        let cmd = self
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await cmd.runServer(binaryURL: binaryURL, box: serverBox)
            }

            if !cmd.noHotReload {
                group.addTask {
                    await cmd.watchForChanges(box: serverBox)
                }
            }

            try await group.next()
            group.cancelAll()
            serverBox.terminate()
        }
    }

    // MARK: - Server

    /// Launch the app binary and relaunch it whenever the watcher terminates
    /// it after a successful rebuild.
    private func runServer(binaryURL: URL, box: ServerProcessBox) async throws {
        while !Task.isCancelled {
            let process = Process()
            process.executableURL = binaryURL
            process.arguments = ["--host", host, "--port", "\(port)", "--dev"]
            process.environment = ProcessInfo.processInfo.environment
                .merging(["SCORE_DEV_RELOAD": "1"]) { _, new in new }
            try process.run()
            box.set(process)

            let status = await waitForExit(process)
            let restartRequested = box.consumeRestartFlag()
            if Task.isCancelled { break }
            if restartRequested {
                Noora().passthrough("↻  Restarting server…")
                continue
            }
            Noora().warning(.alert("Server exited with status \(status)"))
            break
        }
    }

    private func waitForExit(_ process: Process) async -> Int32 {
        // One-shot guard: the termination handler and the not-running check
        // below can race when the process exits immediately after launch.
        final class Once: @unchecked Sendable {
            private let lock = NSLock()
            private var fired = false
            func tryFire() -> Bool {
                lock.lock()
                defer { lock.unlock() }
                if fired { return false }
                fired = true
                return true
            }
        }
        let once = Once()
        return await withCheckedContinuation { continuation in
            process.terminationHandler = { proc in
                if once.tryFire() {
                    continuation.resume(returning: proc.terminationStatus)
                }
            }
            if !process.isRunning, once.tryFire() {
                continuation.resume(returning: process.terminationStatus)
            }
        }
    }

    // MARK: - File watcher

    private func watchForChanges(box: ServerProcessBox) async {
        // All paths that should trigger a rebuild when modified.
        // Localizable.xcstrings is a single file so we check it directly.
        let directories = [
            URL(fileURLWithPath: "Sources"),
            URL(fileURLWithPath: "Content"),
            URL(fileURLWithPath: "Public"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }

        let singleFiles = [
            URL(fileURLWithPath: "Localizable.xcstrings"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }

        var lastDates: [URL: Date] = [:]

        while !Task.isCancelled {
            var changed = pollChanges(in: directories, lastDates: &lastDates)
            changed += pollFiles(singleFiles, lastDates: &lastDates)
            if !changed.isEmpty {
                let noora = Noora()
                for url in changed {
                    noora.passthrough("↻  \(url.lastPathComponent)")
                }
                if let built = try? await buildPackage(configuration: "debug", verbose: verbose), built {
                    noora.success(.alert("Rebuilt — reload your browser"))
                    box.requestRestart()
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

    private func pollFiles(
        _ files: [URL],
        lastDates: inout [URL: Date]
    ) -> [URL] {
        var changed: [URL] = []
        for fileURL in files {
            guard let attrs = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                  let modDate = attrs.contentModificationDate else { continue }
            if let last = lastDates[fileURL], modDate > last {
                lastDates[fileURL] = modDate
                changed.append(fileURL)
            } else if lastDates[fileURL] == nil {
                lastDates[fileURL] = modDate
            }
        }
        return changed
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
        let noora = Noora()
        let start = Date()

        let built = try await buildPackage(configuration: "release", verbose: verbose)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()
        var args = ["--build-only", "--output", output]
        if noMinify { args.append("--no-minify") }
        if noFingerprint { args.append("--no-fingerprint") }

        let process = Process()
        process.executableURL = binaryURL
        process.arguments = args
        try process.run()
        process.waitUntilExit()

        let elapsed = String(format: "%.2f", Date().timeIntervalSince(start))
        if process.terminationStatus == 0 {
            noora.success(.alert("Built in \(elapsed)s", takeaways: ["\(output)"]))
        } else {
            throw CLIError.buildFailed
        }
    }
}

// MARK: - ServerProcessBox

/// Holds the currently-running app server process so the file watcher can
/// terminate it for a restart after a successful rebuild.
///
/// A lock-guarded class rather than an actor because `Process` is not
/// `Sendable` and never escapes — only `terminate()` is called on it from
/// another task.
final class ServerProcessBox: @unchecked Sendable {
    private let lock = NSLock()
    private var process: Process?
    private var restartRequested = false

    func set(_ process: Process) {
        lock.lock()
        defer { lock.unlock() }
        self.process = process
    }

    /// Terminate the running server so `runServer` relaunches the rebuilt binary.
    func requestRestart() {
        lock.lock()
        restartRequested = true
        let running = process
        lock.unlock()
        running?.terminate()
    }

    /// Returns whether the last exit was watcher-requested, resetting the flag.
    func consumeRestartFlag() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let value = restartRequested
        restartRequested = false
        return value
    }

    func terminate() {
        lock.lock()
        let running = process
        process = nil
        lock.unlock()
        running?.terminate()
    }
}
