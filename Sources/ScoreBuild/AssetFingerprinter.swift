import Foundation
import Crypto

/// Adds a SHA-256 content-hash fingerprint to asset filenames for long-term
/// HTTP caching.
///
/// The fingerprint is the first 8 hexadecimal characters of the SHA-256 digest
/// of the file's content, inserted before the file extension:
///
/// `styles.css` → `styles.abc123de.css`
///
/// ```swift
/// let fp = AssetFingerprinter()
/// let (name, hash) = fp.fingerprint(content: cssData, originalFilename: "styles.css")
/// // name == "styles.a1b2c3d4.css"
/// ```
public struct AssetFingerprinter: Sendable {
    public init() {}

    // MARK: - Core

    /// Compute the fingerprinted filename and the full SHA-256 hex digest.
    ///
    /// - Parameters:
    ///   - content: The raw bytes of the asset.
    ///   - originalFilename: The original filename (with extension).
    /// - Returns: A tuple of the fingerprinted filename and the full lowercase hex digest.
    public func fingerprint(
        content: Data,
        originalFilename: String
    ) -> (fingerprintedName: String, fullHash: String) {
        let digest = SHA256.hash(data: content)
        let hexDigest = digest.map { String(format: "%02x", $0) }.joined()
        let shortHash = String(hexDigest.prefix(8))
        let fingerprintedName = insertHash(shortHash, into: originalFilename)
        return (fingerprintedName, hexDigest)
    }

    // MARK: - File operations

    /// Copy the file at `source` to `directory`, inserting a content-hash
    /// fingerprint into the destination filename.
    ///
    /// - Returns: The fingerprinted filename (not the full path).
    @discardableResult
    public func copyWithFingerprint(from source: URL, to directory: URL) throws -> String {
        let data = try Data(contentsOf: source)
        let (fingerprintedName, _) = fingerprint(content: data, originalFilename: source.lastPathComponent)
        let destination = directory.appendingPathComponent(fingerprintedName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: source, to: destination)
        return fingerprintedName
    }

    /// Write `content` to `directory` using a fingerprinted filename derived
    /// from `originalFilename`.
    ///
    /// - Returns: The fingerprinted filename written to disk.
    @discardableResult
    public func writeWithFingerprint(
        content: Data,
        originalFilename: String,
        to directory: URL
    ) throws -> String {
        let (fingerprintedName, _) = fingerprint(content: content, originalFilename: originalFilename)
        let destination = directory.appendingPathComponent(fingerprintedName)
        try content.write(to: destination, options: .atomic)
        return fingerprintedName
    }

    // MARK: - Private

    private func insertHash(_ hash: String, into filename: String) -> String {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension
        let base = url.deletingPathExtension().lastPathComponent
        if ext.isEmpty {
            return "\(base).\(hash)"
        }
        return "\(base).\(hash).\(ext)"
    }
}
