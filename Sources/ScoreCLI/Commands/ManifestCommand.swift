import ArgumentParser
import Foundation

/// `score manifest` — generate or update the committed API route manifest.
///
/// Score writes a machine-readable record of every registered route to
/// `.score/api-manifest.json`. Committing this file gives you a diff-visible
/// audit trail of every breaking API change:
///
/// ```bash
/// score manifest            # write/update .score/api-manifest.json
/// score manifest --diff     # show what changed since the last generation
/// ```
///
/// The manifest format:
///
/// ```json
/// {
///   "generated": "2025-06-11T08:00:00Z",
///   "routes": [
///     { "method": "GET",  "path": "/api/v1/posts" },
///     { "method": "POST", "path": "/api/v1/posts" }
///   ]
/// }
/// ```
struct ManifestCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "manifest",
        abstract: "Generate or update the API route manifest (.score/api-manifest.json)."
    )

    @Flag(name: .long, help: "Show what changed since the last manifest was generated.")
    var diff: Bool = false

    mutating func run() async throws {
        let built = try await buildPackage(configuration: "debug", verbose: false)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()
        let rawJSON = try captureOutput(binary: binaryURL, arguments: ["--list-routes", "--format=json"])

        // Wrap in the manifest envelope.
        let routes = parseRouteList(rawJSON)
        let manifest = buildManifest(routes: routes)

        let manifestDir = URL(fileURLWithPath: ".score")
        try FileManager.default.createDirectory(at: manifestDir, withIntermediateDirectories: true)
        let manifestURL = manifestDir.appendingPathComponent("api-manifest.json")

        if diff {
            showDiff(existing: manifestURL, proposed: manifest)
        }

        try manifest.write(to: manifestURL, atomically: true, encoding: .utf8)
        print("Manifest written to .score/api-manifest.json (\(routes.count) route(s))")
    }

    // MARK: - Helpers

    private func parseRouteList(_ json: String) -> [[String: String]] {
        guard
            let data = json.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data),
            let array = obj as? [[String: String]]
        else { return [] }
        return array
    }

    private func buildManifest(routes: [[String: String]]) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        let timestamp = iso.string(from: Date())

        var lines = [
            "{",
            "  \"generated\": \"\(timestamp)\",",
            "  \"routes\": [",
        ]

        for (index, route) in routes.enumerated() {
            let method = route["method"] ?? "GET"
            let path   = route["path"]   ?? "/"
            let comma  = index < routes.count - 1 ? "," : ""
            lines.append("    { \"method\": \"\(method)\", \"path\": \"\(path)\" }\(comma)")
        }

        lines += ["  ]", "}"]
        return lines.joined(separator: "\n") + "\n"
    }

    private func showDiff(existing url: URL, proposed: String) {
        guard let old = try? String(contentsOf: url, encoding: .utf8) else {
            print("No existing manifest — generating from scratch.")
            return
        }

        let oldLines = old.components(separatedBy: "\n")
        let newLines = proposed.components(separatedBy: "\n")

        // Simple line diff: mark removals (-) and additions (+)
        let removed = Set(oldLines).subtracting(Set(newLines))
        let added   = Set(newLines).subtracting(Set(oldLines))

        if removed.isEmpty && added.isEmpty {
            print("No changes to API routes.")
            return
        }

        print("--- .score/api-manifest.json (existing)")
        print("+++ .score/api-manifest.json (updated)")
        for line in removed.sorted() where !line.isEmpty { print("- \(line)") }
        for line in added.sorted()   where !line.isEmpty { print("+ \(line)") }
    }
}
