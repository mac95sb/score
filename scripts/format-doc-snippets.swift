#!/usr/bin/env swift
import Foundation

// Format Swift code blocks embedded in DocC .md and .tutorial files.
//
// For each ```swift ... ``` block, the script:
//  1. Pipes the block to `swift format`
//  2. Replaces the original block if formatting succeeds
//  3. Leaves blocks unchanged if swift-format reports a parse error
//     (most commonly: incomplete snippets that aren't standalone declarations)

let swiftBlock = try NSRegularExpression(
    pattern: #"(```swift\n)(.*?)(```)"#,
    options: [.dotMatchesLineSeparators]
)

struct ScriptError: Error, CustomStringConvertible {
    let description: String
}

func scriptURL() -> URL {
    let argumentPath = CommandLine.arguments[0]
    let url = URL(fileURLWithPath: argumentPath)
    let absoluteURL: URL

    if url.path.hasPrefix("/") {
        absoluteURL = url
    } else {
        absoluteURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(argumentPath)
    }

    if FileManager.default.fileExists(atPath: absoluteURL.path) {
        return absoluteURL.standardizedFileURL
    }

    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("scripts/format-doc-snippets.swift")
        .standardizedFileURL
}

func formatSnippet(_ code: String, config: URL) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [
        "swift",
        "format",
        "--configuration",
        config.path,
        "-",
    ]

    let inputPipe = Pipe()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    let readGroup = DispatchGroup()
    var outputData = Data()

    readGroup.enter()
    DispatchQueue.global().async {
        outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        readGroup.leave()
    }

    readGroup.enter()
    DispatchQueue.global().async {
        _ = errorPipe.fileHandleForReading.readDataToEndOfFile()
        readGroup.leave()
    }

    do {
        try process.run()
        if let data = code.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        inputPipe.fileHandleForWriting.closeFile()
        process.waitUntilExit()
        readGroup.wait()
    } catch {
        return nil
    }

    guard process.terminationStatus == 0 else {
        return nil
    }

    return String(data: outputData, encoding: .utf8)
}

func displayPath(for path: URL, relativeTo repo: URL) -> String {
    let filePath = path.standardizedFileURL.path
    let repoPath = repo.standardizedFileURL.path

    if filePath == repoPath {
        return "."
    }

    let prefix = repoPath + "/"
    if filePath.hasPrefix(prefix) {
        return String(filePath.dropFirst(prefix.count))
    }

    return filePath
}

func processFile(at path: URL, config: URL, repo: URL, dryRun: Bool) throws -> Bool {
    let original = try String(contentsOf: path, encoding: .utf8)
    let originalNSString = original as NSString
    let fullRange = NSRange(location: 0, length: originalNSString.length)
    let matches = swiftBlock.matches(in: original, range: fullRange)

    var changed = false
    var result = ""
    var currentLocation = 0

    for match in matches {
        guard match.numberOfRanges == 4 else {
            continue
        }

        let matchRange = match.range(at: 0)
        let fenceOpen = originalNSString.substring(with: match.range(at: 1))
        let code = originalNSString.substring(with: match.range(at: 2))
        let fenceClose = originalNSString.substring(with: match.range(at: 3))

        let prefixRange = NSRange(
            location: currentLocation,
            length: matchRange.location - currentLocation
        )
        result += originalNSString.substring(with: prefixRange)

        if let formatted = formatSnippet(code, config: config), formatted != code {
            result += fenceOpen + formatted + fenceClose
            changed = true
        } else {
            result += originalNSString.substring(with: matchRange)
        }

        currentLocation = matchRange.location + matchRange.length
    }

    let suffixRange = NSRange(
        location: currentLocation,
        length: originalNSString.length - currentLocation
    )
    result += originalNSString.substring(with: suffixRange)

    if changed {
        let displayPath = displayPath(for: path, relativeTo: repo)

        if dryRun {
            print("  would update: \(displayPath)")
        } else {
            try result.write(to: path, atomically: true, encoding: .utf8)
            print("  updated: \(displayPath)")
        }
    }

    return changed
}

func docFiles(in docc: URL) throws -> [URL] {
    guard
        let enumerator = FileManager.default.enumerator(
            at: docc,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
    else {
        throw ScriptError(description: "Could not enumerate \(docc.path)")
    }

    var files: [URL] = []

    for case let file as URL in enumerator {
        let values = try file.resourceValues(forKeys: [.isRegularFileKey])
        guard values.isRegularFile == true else {
            continue
        }

        if file.pathExtension == "md" || file.pathExtension == "tutorial" {
            files.append(file)
        }
    }

    return files.sorted { $0.path < $1.path }
}

func main() throws {
    let script = scriptURL()
    let repo = script.deletingLastPathComponent().deletingLastPathComponent()
    let config = repo.appendingPathComponent(".swift-format")
    let docc = repo.appendingPathComponent("Documentation.docc")
    let dryRun = CommandLine.arguments.contains("--dry-run")

    var anyChanged = false

    for file in try docFiles(in: docc) {
        if try processFile(at: file, config: config, repo: repo, dryRun: dryRun) {
            anyChanged = true
        }
    }

    if !anyChanged {
        print("All Swift code blocks already match .swift-format rules.")
    }
}

do {
    try main()
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
