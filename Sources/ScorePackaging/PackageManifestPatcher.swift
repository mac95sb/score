import Foundation

/// Idempotently adds a generated kit as a library product and target to a
/// Score application's `Package.swift`.
///
/// The patcher is text-based: it inserts a `.library` product and a `.target`
/// entry if the manifest doesn't already mention the kit. When no `products:`
/// section exists (Score's scaffolded apps rely on the implicit executable
/// product), one is inserted after the package `name:` line.
///
/// - Note: Text-based, not AST — inserts by pattern matching brace depth.
///   False positives/negatives are possible on manifests that deviate from
///   Score's scaffolded structure.
public enum PackageManifestPatcher {

    /// Returns `true` when the manifest was modified, `false` when the kit
    /// was already declared.
    @discardableResult
    public static func addLibraryTarget(
        named kitName: String,
        toManifestAt manifestURL: URL
    ) throws -> Bool {
        guard let original = try? String(contentsOf: manifestURL, encoding: .utf8) else {
            throw PackagingError.manifestPatchFailed("Could not read \(manifestURL.path).")
        }
        guard !original.contains("\"\(kitName)\"") else { return false }

        var text = original
        let productEntry = "\n        .library(name: \"\(kitName)\", targets: [\"\(kitName)\"]),"
        let targetEntry = "\n        .target(name: \"\(kitName)\"),"

        guard let targetsRange = packageArgumentArrayRange(named: "targets", in: text) else {
            throw PackagingError.manifestPatchFailed(
                "No `targets:` section found in \(manifestURL.path).")
        }

        if let productsRange = packageArgumentArrayRange(named: "products", in: text) {
            // Insert into the later section first so the earlier range stays valid.
            if productsRange.lowerBound < targetsRange.lowerBound {
                text.insert(contentsOf: targetEntry, at: targetsRange.upperBound)
                text.insert(contentsOf: productEntry, at: productsRange.upperBound)
            } else {
                text.insert(contentsOf: productEntry, at: productsRange.upperBound)
                text.insert(contentsOf: targetEntry, at: targetsRange.upperBound)
            }
        } else {
            text.insert(contentsOf: targetEntry, at: targetsRange.upperBound)
            // Add a products section after the package name declaration.
            let namePattern = #"name:\s*"[^"]+",\s*\n"#
            guard let regex = try? NSRegularExpression(pattern: namePattern),
                let match = regex.firstMatch(
                    in: text,
                    range: NSRange(text.startIndex..., in: text)),
                let nameRange = Range(match.range, in: text)
            else {
                throw PackagingError.manifestPatchFailed(
                    "No package `name:` declaration found in \(manifestURL.path).")
            }
            let productsSection =
                "    products: [\n        .library(name: \"\(kitName)\", targets: [\"\(kitName)\"]),\n    ],\n"
            text.insert(contentsOf: productsSection, at: nameRange.upperBound)
        }

        try text.write(to: manifestURL, atomically: true, encoding: .utf8)
        return true
    }

    private static func packageArgumentArrayRange(
        named label: String,
        in text: String
    ) -> Range<String.Index>? {
        var index = text.startIndex
        var parenDepth = 0
        let labelPrefix = "\(label):"

        while index < text.endIndex {
            if parenDepth == 1, text[index...].hasPrefix(labelPrefix),
                let arrayStart = text[index...].firstIndex(of: "[")
            {
                return index..<text.index(after: arrayStart)
            }

            switch text[index] {
            case "(":
                parenDepth += 1
            case ")":
                parenDepth = max(0, parenDepth - 1)
            default:
                break
            }

            index = text.index(after: index)
        }

        return nil
    }
}
