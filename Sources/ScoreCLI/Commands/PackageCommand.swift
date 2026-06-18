import ArgumentParser
import Foundation
import Noora
import ScorePackaging

/// `score package <platform>` — wrap your Score app in a native shell, or
/// export your data layer for native Swift clients.
///
/// ```
/// score package windows                      # WebView2 shell (C# / .NET 8)
/// score package android                      # WebView shell (Kotlin / Gradle)
/// score package linux                        # WebKitGTK shell (C / make)
/// score package swiftui                      # Records + API client Swift package
/// score package windows --url https://myapp.com   # remote mode, nothing bundled
/// ```
struct PackageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "package",
        abstract: "Package your Score app for native platforms.",
        subcommands: [
            WindowsPackageCommand.self,
            AndroidPackageCommand.self,
            LinuxPackageCommand.self,
            SwiftUIPackageCommand.self,
        ]
    )
}

// MARK: - Shared WebView options

struct WebViewPackageOptions: ParsableArguments {
    @Option(name: .long, help: "App name (default: current directory name).")
    var name: String?

    @Option(name: .long, help: "Reverse-DNS identifier (default: com.example.<name>).")
    var identifier: String?

    @Option(name: .long, help: "App version string.")
    var appVersion: String = "1.0.0"

    @Option(name: .long, help: "Load a deployed server URL instead of bundling the static export.")
    var url: String?

    @Option(name: .long, help: "Static export directory to bundle (default: .score/build).")
    var source: String = ".score/build"

    @Option(name: .long, help: "Output directory (default: dist/<platform>).")
    var output: String?

    @Option(name: .long, help: "Initial window width (desktop platforms).")
    var width: Int = 1024

    @Option(name: .long, help: "Initial window height (desktop platforms).")
    var height: Int = 768

    @Option(name: .long, help: "Container CLI for generated container builds (container, docker, podman).")
    var containerTool: String = "container"

    func makeConfig() throws -> PackagingConfig {
        let appName =
            name
            ?? FileManager.default.currentDirectoryPath.split(separator: "/").last.map(String.init)
            ?? "ScoreApp"
        let appSource: AppSource = url.map { .remote(url: $0) } ?? .staticExport(path: source)
        return try PackagingConfig(
            appName: appName,
            identifier: identifier,
            version: appVersion,
            source: appSource,
            windowWidth: width,
            windowHeight: height,
            containerTool: containerTool
        )
    }
}

// MARK: - Platform subcommands

private func runPackager(
    _ packager: some WebViewPackager,
    options: WebViewPackageOptions
) async throws {
    let ui = Noora()
    let config = try options.makeConfig()
    let outputPath = options.output ?? "dist/\(packager.platform.rawValue)"
    let platformName = packager.platform.rawValue

    let result = try await ui.progressStep(
        message: "Packaging \(config.appName) for \(platformName)",
        successMessage: nil,
        errorMessage: "Packaging failed",
        showSpinner: true
    ) { _ in
        try packager.package(config: config, into: URL(fileURLWithPath: outputPath))
    }

    ui.success(
        .alert(
            "Packaged \(config.appName) for \(platformName) → \(outputPath)",
            takeaways: result.filesWritten.map { "\($0)" }
        ))
    ui.info(.alert("\(result.nextSteps)"))
}

struct WindowsPackageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "windows",
        abstract: "Generate a Windows WebView2 shell (C# / .NET 8)."
    )

    @OptionGroup var options: WebViewPackageOptions

    mutating func run() async throws {
        try await runPackager(WindowsPackager(), options: options)
    }
}

struct AndroidPackageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "android",
        abstract: "Generate an Android WebView shell (Kotlin / Gradle)."
    )

    @OptionGroup var options: WebViewPackageOptions

    mutating func run() async throws {
        try await runPackager(AndroidPackager(), options: options)
    }
}

struct LinuxPackageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "linux",
        abstract: "Generate a Linux WebKitGTK shell (C / make)."
    )

    @OptionGroup var options: WebViewPackageOptions

    mutating func run() async throws {
        try await runPackager(LinuxPackager(), options: options)
    }
}

// MARK: - SwiftUI kit export

struct SwiftUIPackageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftui",
        abstract: "Export Records and API endpoints as a library target for SwiftUI apps.",
        discussion: """
            By default the kit is generated as a library target inside this \
            package (Sources/<KitName>) and added to Package.swift, so SwiftUI \
            apps depend on your app's repository and `import <KitName>` directly. \
            `score dev` and `score build` regenerate the kit automatically, so it \
            can never drift from your records and routes.

            Pass --standalone to instead export a detached Swift package to dist/.
            """
    )

    @Option(name: .long, help: "Name of the generated module (default: <AppName>Kit).")
    var kitName: String?

    @Option(name: .long, help: "Directory scanned for Records and controllers.")
    var sources: String = "Sources"

    @Flag(name: .long, help: "Export a detached Swift package instead of an in-package target.")
    var standalone: Bool = false

    @Option(name: .long, help: "Output directory for --standalone (default: dist/<KitName>).")
    var output: String?

    @Option(name: .long, help: "Base URL used in the generated README example.")
    var baseUrl: String = "https://example.com/api/v1"

    mutating func run() async throws {
        let appName =
            FileManager.default.currentDirectoryPath
            .split(separator: "/").last.map(String.init) ?? "App"
        let resolvedKitName =
            kitName
            ?? PackagingConfig.lowercasedAlphanumeric(appName, fallback: "app").capitalized + "Kit"

        if standalone {
            try await runStandalone(kitName: resolvedKitName)
        } else {
            try await runEmbedded(kitName: resolvedKitName)
        }
    }

    private func runEmbedded(kitName: String) async throws {
        let ui = Noora()
        let exporter = SwiftUIKitExporter(
            options: .init(
                kitName: kitName,
                sourcesDirectory: sources,
                excludedDirectories: [kitName],
                exampleBaseURL: baseUrl
            ))
        let targetPath = "\(sources)/\(kitName)"

        let result = try await ui.progressStep(
            message: "Exporting \(kitName)",
            successMessage: nil,
            errorMessage: "Export failed",
            showSpinner: true
        ) { _ in
            try exporter.exportTarget(into: URL(fileURLWithPath: targetPath))
        }

        let manifestURL = URL(fileURLWithPath: "Package.swift")
        let manifestChanged = try PackageManifestPatcher.addLibraryTarget(
            named: kitName,
            toManifestAt: manifestURL
        )

        var takeaways = result.filesWritten.map { "\(targetPath)/\($0)" }
        if manifestChanged {
            takeaways.append("Package.swift — added library product and target '\(kitName)'")
        }
        ui.success(
            .alert(
                "Exported \(result.recordNames.count) record(s), \(result.controllerNames.count) controller(s), \(result.endpointCount) endpoint(s) → \(targetPath)",
                takeaways: takeaways.map { "\($0)" }
            ))
        ui.info(
            .alert(
                "The kit regenerates automatically on every `score dev` and `score build`",
                takeaways: [
                    "Depend on this repository from your SwiftUI app and `import \(kitName)`",
                    "Add iOS to your Package.swift platforms (e.g. .iOS(.v16)) so the kit resolves for iOS clients",
                ]
            ))
    }

    private func runStandalone(kitName: String) async throws {
        let ui = Noora()
        let exporter = SwiftUIKitExporter(
            options: .init(
                kitName: kitName,
                sourcesDirectory: sources,
                excludedDirectories: [kitName],
                exampleBaseURL: baseUrl
            ))
        let outputPath = output ?? "dist/\(kitName)"

        let result = try await ui.progressStep(
            message: "Exporting \(kitName) (standalone)",
            successMessage: nil,
            errorMessage: "Export failed",
            showSpinner: true
        ) { _ in
            try exporter.export(into: URL(fileURLWithPath: outputPath))
        }

        ui.success(
            .alert(
                "Exported \(result.recordNames.count) record(s), \(result.controllerNames.count) controller(s), \(result.endpointCount) endpoint(s) → \(outputPath)",
                takeaways: result.filesWritten.map { "\($0)" }
            ))
        ui.info(
            .alert(
                "Add the package to your SwiftUI app: Xcode ▸ File ▸ Add Package Dependencies… ▸ Add Local… ▸ \(outputPath)",
                takeaways: [
                    "Standalone exports are snapshots — re-run after changing records or controllers",
                    "Prefer the default in-package mode to avoid drift",
                ]
            ))
    }
}
