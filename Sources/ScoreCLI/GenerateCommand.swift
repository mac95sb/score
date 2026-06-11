import ArgumentParser
import Foundation
import Noora

/// `score generate <type> <name>` — generate Score boilerplate code.
///
/// Scaffolds ready-to-use Score types into your project's `Sources/` directory.
///
/// ```
/// score generate page BlogIndexPage
/// score generate component ArticleCard
/// score generate action CreatePostAction
/// score generate record Post
/// ```
struct GenerateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate Score boilerplate (page, component, action, record).",
        aliases: ["g"]
    )

    @Argument(help: "Type to generate: page, component, action, record, middleware.")
    var type: GeneratorType

    @Argument(help: "Name of the generated type (PascalCase).")
    var name: String

    @Option(name: .shortAndLong, help: "Output directory.")
    var output: String?

    @Flag(name: .long, help: "Overwrite existing file.")
    var force: Bool = false

    mutating func run() async throws {
        let generator = CodeGenerator()
        let source = generator.generate(type: type, name: name)
        let filename = generator.filename(for: type, name: name)
        let outputDir = output.map { URL(fileURLWithPath: $0) }
            ?? defaultOutputDirectory(for: type)

        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let outputURL = outputDir.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: outputURL.path) && !force {
            throw CLIError.fileExists(outputURL.path)
        }

        try source.write(to: outputURL, atomically: true, encoding: .utf8)
        Noora().success(.alert("Generated \(outputURL.path)"))
    }

    private func defaultOutputDirectory(for type: GeneratorType) -> URL {
        let base = URL(fileURLWithPath: "Sources")
        switch type {
        case .page:       return base.appendingPathComponent("Pages")
        case .component:  return base.appendingPathComponent("Components")
        case .action:     return base.appendingPathComponent("Actions")
        case .record:     return base.appendingPathComponent("Models")
        case .middleware: return base.appendingPathComponent("Middleware")
        }
    }
}

// MARK: - GeneratorType

enum GeneratorType: String, ExpressibleByArgument, CaseIterable {
    case page
    case component
    case action
    case record
    case middleware
}

// MARK: - CodeGenerator

struct CodeGenerator: Sendable {
    func filename(for type: GeneratorType, name: String) -> String {
        "\(name).swift"
    }

    func generate(type: GeneratorType, name: String) -> String {
        switch type {
        case .page:       return generatePage(name)
        case .component:  return generateComponent(name)
        case .action:     return generateAction(name)
        case .record:     return generateRecord(name)
        case .middleware: return generateMiddleware(name)
        }
    }

    // MARK: - Templates

    private func generatePage(_ name: String) -> String {
        """
        import Score

        /// A page rendered at a fixed URL path.
        struct \(name): Page {
            var metadata: PageMetadata? {
                PageMetadata(title: "\(splitPascalCase(name))")
            }

            var body: some View {
                Main {
                    Heading(1) { "\(splitPascalCase(name))" }
                }
            }
        }
        """
    }

    private func generateComponent(_ name: String) -> String {
        """
        import Score

        /// A reusable Score component.
        struct \(name): View {
            var body: some View {
                Stack {
                    Text { "\(name)" }
                }
            }
        }
        """
    }

    private func generateAction(_ name: String) -> String {
        let inputName = name.hasSuffix("Action") ? String(name.dropLast(6)) + "Input" : name + "Input"
        return """
        import Score

        /// Input payload for ``\(name)``.
        struct \(inputName): Codable, Sendable {
            // Add your input fields here
        }

        /// A server action invoked from the browser.
        ///
        /// Call this action from any view by annotating a closure with `@Action`:
        ///
        /// ```swift
        /// @Action var perform: (\(inputName)) async throws -> Response
        /// ```
        struct \(name) {
            static func run(_ input: \(inputName), context: RequestContext) async throws -> Response {
                // TODO: Implement
                .ok(json: input)
            }
        }
        """
    }

    private func generateRecord(_ name: String) -> String {
        """
        import Score
        import Foundation

        /// A database-backed record.
        struct \(name): Record {
            static let tableName = "\(name.lowercased())s"

            var id: UUID
            var createdAt: Date
            var updatedAt: Date

            // Add your properties here

            init() {
                self.id = UUID()
                self.createdAt = .now
                self.updatedAt = .now
            }
        }
        """
    }

    private func generateMiddleware(_ name: String) -> String {
        """
        import Score

        /// A middleware that runs on every matched route.
        struct \(name): Middleware {
            func handle(_ request: Request, next: RequestHandler) async throws -> Response {
                // Pre-processing
                let response = try await next(request)
                // Post-processing
                return response
            }
        }
        """
    }

    // MARK: - Helper

    private func splitPascalCase(_ name: String) -> String {
        var result = ""
        for (i, ch) in name.enumerated() {
            if ch.isUppercase && i > 0 {
                result += " "
            }
            result.append(ch)
        }
        return result
    }
}
