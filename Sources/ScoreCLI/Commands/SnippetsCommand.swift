import ArgumentParser
import Foundation
import Noora

// MARK: - SnippetsCommand

/// Install editor code snippets for all `score generate` types.
///
/// Running `score snippets` without flags writes a `.vscode/score.code-snippets`
/// file into the current directory (VS Code picks it up automatically) and
/// installs `.codesnippet` plists into Xcode's user snippet directory.
///
/// ```
/// score snippets                    # install for both VS Code and Xcode
/// score snippets --editor vscode    # VS Code only
/// score snippets --editor xcode     # Xcode only
/// score snippets --path ./my-app    # write VS Code snippets to a specific directory
/// ```
///
/// Snippets trigger on the `score-` prefix (e.g. `score-page`, `score-component`).
/// After installing for Xcode, restart Xcode for the snippets to appear.
struct SnippetsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "snippets",
        abstract: "Install editor snippets for Score generator types (VS Code and Xcode)."
    )

    enum Editor: String, ExpressibleByArgument, CaseIterable {
        case vscode, xcode

        var description: String {
            switch self {
            case .vscode: return "VS Code"
            case .xcode: return "Xcode"
            }
        }
    }

    @Option(name: .long, help: "Editor to target: vscode or xcode. Installs for both by default.")
    var editor: Editor?

    @Option(name: .long, help: "Directory to write VS Code snippets into (default: current directory).")
    var path: String = "."

    mutating func run() throws {
        let ui = Noora()
        let targets: [Editor] = editor.map { [$0] } ?? Editor.allCases
        for target in targets {
            switch target {
            case .vscode:
                try installVSCode(at: path, ui: ui)
            case .xcode:
                try installXcode(ui: ui)
            }
        }
    }

    // MARK: - VS Code

    private func installVSCode(at directoryPath: String, ui: Noora) throws {
        let dir = URL(fileURLWithPath: directoryPath).appendingPathComponent(".vscode")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dest = dir.appendingPathComponent("score.code-snippets")
        try vsCodeSnippetsJSON.write(to: dest, atomically: true, encoding: .utf8)
        ui.success("Wrote \(dest.path)")
        ui.info("VS Code picks up the file automatically — type 'score-' to trigger completions.")
    }

    // MARK: - Xcode

    private func installXcode(ui: Noora) throws {
        let xcodePath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Developer/Xcode/UserData/CodeSnippets")
        try FileManager.default.createDirectory(at: xcodePath, withIntermediateDirectories: true)
        for (filename, content) in xcodeSnippets {
            let dest = xcodePath.appendingPathComponent(filename)
            try content.write(to: dest, atomically: true, encoding: .utf8)
        }
        ui.success("Wrote \(xcodeSnippets.count) snippets to \(xcodePath.path)")
        ui.info("Restart Xcode for snippets to appear — type 'score-' in the editor.")
    }

    // MARK: - VS Code payload

    private var vsCodeSnippetsJSON: String {
        """
        {
          "Score Page": {
            "scope": "swift",
            "prefix": "score-page",
            "description": "Score Page struct conforming to Page",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}: Page {",
              "\\tvar metadata: PageMetadata? {",
              "\\t\\tPageMetadata(title: \\"${2:${1:Name}}\\")",
              "\\t}",
              "",
              "\\tvar body: some View {",
              "\\t\\tMain {",
              "\\t\\t\\tHeading(1) { \\"${2:${1:Name}}\\" }",
              "\\t\\t\\t$0",
              "\\t\\t}",
              "\\t}",
              "}"
            ]
          },
          "Score Static Page": {
            "scope": "swift",
            "prefix": "score-static-page",
            "description": "Score StaticPage with instances() for build-time generation",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}: Page {",
              "\\tvar metadata: PageMetadata? {",
              "\\t\\tPageMetadata(title: \\"${2:${1:Name}}\\")",
              "\\t}",
              "",
              "\\tvar body: some View {",
              "\\t\\tMain {",
              "\\t\\t\\t$0",
              "\\t\\t}",
              "\\t}",
              "}",
              "",
              "extension ${1:Name}: StaticPage {",
              "\\tstatic func instances() async throws -> [Self] {",
              "\\t\\t[]",
              "\\t}",
              "}"
            ]
          },
          "Score Component": {
            "scope": "swift",
            "prefix": "score-component",
            "description": "Score View component struct",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}: View {",
              "\\tvar body: some View {",
              "\\t\\tStack {",
              "\\t\\t\\t$0",
              "\\t\\t}",
              "\\t}",
              "}"
            ]
          },
          "Score Record": {
            "scope": "swift",
            "prefix": "score-record",
            "description": "Score database Record conformance",
            "body": [
              "import Score",
              "import Foundation",
              "",
              "struct ${1:Name}: Record {",
              "\\tstatic let tableName = \\"${2:${1/(.*)/${1:/downcase}/}s}\\"",
              "",
              "\\tvar id: UUID",
              "\\tvar createdAt: Date",
              "\\tvar updatedAt: Date",
              "",
              "\\t${0:// Add your properties here}",
              "",
              "\\tinit() {",
              "\\t\\tself.id = UUID()",
              "\\t\\tself.createdAt = .now",
              "\\t\\tself.updatedAt = .now",
              "\\t}",
              "}"
            ]
          },
          "Score Controller": {
            "scope": "swift",
            "prefix": "score-controller",
            "description": "Score RouteCollection controller grouping page and API routes",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}Controller: RouteCollection {",
              "\\tvar routes: [Route] {",
              "\\t\\tRouteGroup(\\"/${2:path}\\") {",
              "\\t\\t\\tPage(\\"/\\") { req in",
              "\\t\\t\\t\\t$0",
              "\\t\\t\\t}",
              "\\t\\t}",
              "\\t}",
              "}"
            ]
          },
          "Score Middleware": {
            "scope": "swift",
            "prefix": "score-middleware",
            "description": "Score Middleware that runs on matched routes",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}Middleware: Middleware {",
              "\\tfunc handle(",
              "\\t\\t_ request: Request,",
              "\\t\\tnext: @Sendable (Request) async throws -> Response",
              "\\t) async throws -> Response {",
              "\\t\\t${0:// Pre-processing}",
              "\\t\\tlet response = try await next(request)",
              "\\t\\t// Post-processing",
              "\\t\\treturn response",
              "\\t}",
              "}"
            ]
          },
          "Score Action": {
            "scope": "swift",
            "prefix": "score-action",
            "description": "Score server Action with input payload",
            "body": [
              "import Score",
              "",
              "struct ${1:Name}Input: Codable, Sendable {",
              "\\t${2:// Add input fields here}",
              "}",
              "",
              "struct ${1:Name}Action {",
              "\\tstatic func run(_ input: ${1:Name}Input, context: RequestContext) async throws -> Response {",
              "\\t\\t${0:try Response.json(input)}",
              "\\t}",
              "}"
            ]
          }
        }
        """
    }

    // MARK: - Xcode payloads

    private var xcodeSnippets: [(filename: String, content: String)] {
        [
            xcodeSnippet(
                id: "score-page",
                title: "Score Page",
                summary: "Score Page struct conforming to Page",
                prefix: "score-page",
                body: """
                    import Score

                    struct <#Name#>: Page {
                        var metadata: PageMetadata? {
                            PageMetadata(title: "<#Title#>")
                        }

                        var body: some View {
                            Main {
                                Heading(1) { "<#Title#>" }
                                <#content#>
                            }
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-static-page",
                title: "Score Static Page",
                summary: "Score StaticPage with instances() for build-time generation",
                prefix: "score-static-page",
                body: """
                    import Score

                    struct <#Name#>: Page {
                        var metadata: PageMetadata? {
                            PageMetadata(title: "<#Title#>")
                        }

                        var body: some View {
                            Main {
                                <#content#>
                            }
                        }
                    }

                    extension <#Name#>: StaticPage {
                        static func instances() async throws -> [Self] {
                            []
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-component",
                title: "Score Component",
                summary: "Score View component struct",
                prefix: "score-component",
                body: """
                    import Score

                    struct <#Name#>: View {
                        var body: some View {
                            Stack {
                                <#content#>
                            }
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-record",
                title: "Score Record",
                summary: "Score database Record conformance",
                prefix: "score-record",
                body: """
                    import Score
                    import Foundation

                    struct <#Name#>: Record {
                        static let tableName = "<#tablename#>"

                        var id: UUID
                        var createdAt: Date
                        var updatedAt: Date

                        <#// Add your properties here#>

                        init() {
                            self.id = UUID()
                            self.createdAt = .now
                            self.updatedAt = .now
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-controller",
                title: "Score Controller",
                summary: "Score RouteCollection controller grouping page and API routes",
                prefix: "score-controller",
                body: """
                    import Score

                    struct <#Name#>Controller: RouteCollection {
                        var routes: [Route] {
                            RouteGroup("/<#path#>") {
                                Page("/") { req in
                                    <#return Page()#>
                                }
                            }
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-middleware",
                title: "Score Middleware",
                summary: "Score Middleware that runs on matched routes",
                prefix: "score-middleware",
                body: """
                    import Score

                    struct <#Name#>Middleware: Middleware {
                        func handle(
                            _ request: Request,
                            next: @Sendable (Request) async throws -> Response
                        ) async throws -> Response {
                            <#// Pre-processing#>
                            let response = try await next(request)
                            // Post-processing
                            return response
                        }
                    }
                    """
            ),
            xcodeSnippet(
                id: "score-action",
                title: "Score Action",
                summary: "Score server Action with input payload",
                prefix: "score-action",
                body: """
                    import Score

                    struct <#Name#>Input: Codable, Sendable {
                        <#// Add input fields here#>
                    }

                    struct <#Name#>Action {
                        static func run(_ input: <#Name#>Input, context: RequestContext) async throws -> Response {
                            <#try Response.json(input)#>
                        }
                    }
                    """
            ),
        ]
    }

    private func xcodeSnippet(
        id: String,
        title: String,
        summary: String,
        prefix: String,
        body: String
    ) -> (filename: String, content: String) {
        let escaped = body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<#", with: "&lt;#")
            .replacingOccurrences(of: "#>", with: "#&gt;")
        let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
            \t<key>IDECodeSnippetCompletionPrefix</key>
            \t<string>\(prefix)</string>
            \t<key>IDECodeSnippetCompletionScopes</key>
            \t<array>
            \t\t<string>TopLevel</string>
            \t</array>
            \t<key>IDECodeSnippetContents</key>
            \t<string>\(escaped)</string>
            \t<key>IDECodeSnippetIdentifier</key>
            \t<string>\(id)</string>
            \t<key>IDECodeSnippetLanguage</key>
            \t<string>Xcode.SourceCodeLanguage.Swift</string>
            \t<key>IDECodeSnippetSummary</key>
            \t<string>\(summary)</string>
            \t<key>IDECodeSnippetTitle</key>
            \t<string>\(title)</string>
            \t<key>IDECodeSnippetUserSnippet</key>
            \t<true/>
            \t<key>IDECodeSnippetVersion</key>
            \t<integer>2</integer>
            </dict>
            </plist>
            """
        return (filename: "\(id).codesnippet", content: plist)
    }
}
