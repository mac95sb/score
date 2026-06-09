import Foundation

/// The asset manifest written to `.score/build/asset-manifest.json`.
///
/// The manifest records every fingerprinted asset path and the list of
/// pre-rendered page routes so the development server and CDN deploy scripts
/// can efficiently serve or invalidate them.
public struct AssetManifest: Codable, Sendable {
    /// Map from logical name to fingerprinted filename.
    ///
    /// For example: `["styles.css": "styles.abc123de.css"]`
    public var assets: [String: String]

    /// All pre-rendered page URL paths (e.g. `["/", "/blog", "/blog/hello-world"]`).
    public var pages: [String]

    /// Whether this app includes server-rendered routes that require a running binary.
    public var requiresServer: Bool

    /// ISO-8601 timestamp when this manifest was produced.
    public var builtAt: Date

    public init(
        assets: [String: String] = [:],
        pages: [String] = [],
        requiresServer: Bool = false
    ) {
        self.assets = assets
        self.pages = pages
        self.requiresServer = requiresServer
        self.builtAt = .now
    }
}

// MARK: - ManifestWriter

/// Writes and reads the asset manifest to/from a directory.
public struct ManifestWriter: Sendable {
    public init() {}

    // MARK: - Write

    /// Encode `manifest` as pretty-printed JSON and write it to
    /// `<directory>/asset-manifest.json`.
    public func write(_ manifest: AssetManifest, to directory: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(manifest)
        let url = directory.appendingPathComponent("asset-manifest.json")
        try data.write(to: url, options: .atomic)
    }

    // MARK: - Read

    /// Load and decode the manifest from `<directory>/asset-manifest.json`.
    public func read(from directory: URL) throws -> AssetManifest {
        let url = directory.appendingPathComponent("asset-manifest.json")
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AssetManifest.self, from: data)
    }
}
