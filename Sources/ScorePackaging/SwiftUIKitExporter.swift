import Foundation

// MARK: - SwiftUIKitExporter

/// Exports a Score application's data layer for native Swift clients.
///
/// The exporter scans the project's Swift sources for ``Record`` conformances
/// (models) and `RouteCollection` conformances (controllers) and generates a
/// standalone Swift package containing:
///
/// - A `Record` protocol mirror, so models compile without depending on Score.
/// - One public `Codable` struct per record, with a public memberwise initializer.
/// - A typed `Endpoint` per controller route, grouped under an `API` namespace.
/// - A `ScoreAPIClient` (URLSession-based, async/await) for calling those endpoints.
///
/// The generated package has zero dependencies and can be dropped into any
/// SwiftUI app via `File ▸ Add Package Dependencies…` or a local path.
public struct SwiftUIKitExporter: Sendable {

    public struct Options: Sendable {
        /// Name of the generated Swift module (and package, in standalone mode).
        public var kitName: String
        /// Directory scanned for `Record` and `RouteCollection` declarations.
        public var sourcesDirectory: String
        /// Top-level subdirectories of `sourcesDirectory` to skip while scanning.
        /// The kit's own directory is excluded automatically in embedded mode so
        /// previously generated models are never re-exported.
        public var excludedDirectories: Set<String>
        /// Base URL shown in the generated README usage example.
        public var exampleBaseURL: String

        public init(
            kitName: String,
            sourcesDirectory: String = "Sources",
            excludedDirectories: Set<String> = [],
            exampleBaseURL: String = "https://example.com/api/v1"
        ) {
            self.kitName = kitName
            self.sourcesDirectory = sourcesDirectory
            self.excludedDirectories = excludedDirectories
            self.exampleBaseURL = exampleBaseURL
        }
    }

    public struct ExportResult: Sendable {
        public let outputDirectory: URL
        public let recordNames: [String]
        public let controllerNames: [String]
        public let endpointCount: Int
        public let filesWritten: [String]
        /// Files whose content actually changed (identical rewrites are skipped).
        public let filesChanged: [String]
    }

    public let options: Options

    public init(options: Options) {
        self.options = options
    }

    // MARK: - Export

    /// Export a standalone Swift package (manifest, README, and sources) into
    /// `outputDirectory`. Suitable for handing the kit to a separate repository.
    public func export(into outputDirectory: URL) throws -> ExportResult {
        let (records, controllers) = try scanProject()

        let kit = options.kitName
        var writer = try ProjectWriter(root: outputDirectory)
        try writer.write(packageSwift(), to: "Package.swift")
        try writeKitSources(
            records: records,
            controllers: controllers,
            into: &writer,
            prefix: "Sources/\(kit)/"
        )
        try writer.write(readme(records: records, controllers: controllers), to: "README.md")

        return ExportResult(
            outputDirectory: outputDirectory,
            recordNames: records.map(\.name),
            controllerNames: controllers.map(\.name),
            endpointCount: controllers.reduce(0) { $0 + $1.endpoints.count },
            filesWritten: writer.written,
            filesChanged: writer.changed
        )
    }

    /// Export the kit sources directly into a target directory of the Score
    /// application's own package (e.g. `Sources/MyAppKit`), so the kit ships
    /// as a library product of the app package and is regenerated on every
    /// `score dev` / `score build` — eliminating drift between the app's API
    /// and what native clients import.
    public func exportTarget(into targetDirectory: URL) throws -> ExportResult {
        let (records, controllers) = try scanProject()

        var writer = try ProjectWriter(root: targetDirectory)
        try writeKitSources(records: records, controllers: controllers, into: &writer, prefix: "")

        // The Models directory is fully generated; drop files for records that
        // were renamed or deleted so they don't linger in the target.
        let modelsDir = targetDirectory.appendingPathComponent("Models")
        let expected = Set(records.map { "\($0.name).swift" })
        let fm = FileManager.default
        for file in (try? fm.contentsOfDirectory(atPath: modelsDir.path)) ?? [] {
            if !expected.contains(file) {
                try? fm.removeItem(at: modelsDir.appendingPathComponent(file))
            }
        }

        return ExportResult(
            outputDirectory: targetDirectory,
            recordNames: records.map(\.name),
            controllerNames: controllers.map(\.name),
            endpointCount: controllers.reduce(0) { $0 + $1.endpoints.count },
            filesWritten: writer.written,
            filesChanged: writer.changed
        )
    }

    private func writeKitSources(
        records: [RecordModel],
        controllers: [Controller],
        into writer: inout ProjectWriter,
        prefix: String
    ) throws {
        try writer.write(recordShim(), to: "\(prefix)ScoreRecord.swift")
        for record in records {
            try writer.write(modelSource(record), to: "\(prefix)Models/\(record.name).swift")
        }
        try writer.write(apiClientSource(), to: "\(prefix)ScoreAPIClient.swift")
        try writer.write(endpointsSource(controllers: controllers), to: "\(prefix)Endpoints.swift")
    }

    private func scanProject() throws -> ([RecordModel], [Controller]) {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: options.sourcesDirectory, isDirectory: &isDirectory),
            isDirectory.boolValue
        else {
            throw PackagingError.sourcesDirectoryMissing(options.sourcesDirectory)
        }

        var records: [RecordModel] = []
        var controllers: [Controller] = []
        for source in collectSwiftSources(in: options.sourcesDirectory) {
            records.append(contentsOf: parseRecords(in: source))
            controllers.append(contentsOf: parseControllers(in: source))
        }
        records.sort { $0.name < $1.name }
        controllers.sort { $0.name < $1.name }
        return (records, controllers)
    }

    // MARK: - Source discovery

    private func collectSwiftSources(in directory: String) -> [String] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: directory) else { return [] }
        var sources: [String] = []
        while let relative = enumerator.nextObject() as? String {
            guard relative.hasSuffix(".swift") else { continue }
            // Skip excluded top-level subdirectories (e.g. the generated kit itself).
            if let topLevel = relative.split(separator: "/").first,
                options.excludedDirectories.contains(String(topLevel))
            {
                continue
            }
            let path = (directory as NSString).appendingPathComponent(relative)
            if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
                sources.append(contents)
            }
        }
        return sources
    }

    // MARK: - Record parsing

    struct RecordProperty {
        let name: String
        let type: String
        let defaultValue: String?
    }

    struct RecordModel {
        let name: String
        let properties: [RecordProperty]
    }

    func parseRecords(in source: String) -> [RecordModel] {
        structDeclarations(conformingTo: "Record", in: source).map { declaration in
            RecordModel(
                name: declaration.name,
                properties: parseStoredProperties(in: declaration.body)
            )
        }
    }

    private func parseStoredProperties(in body: String) -> [RecordProperty] {
        // Matches `var name: Type` / `let name: Type = default` on a single line.
        let pattern = #"^(?:public\s+)?(?:var|let)\s+(\w+)\s*:\s*([\w\[\]\?\.<>,: ]+?)(?:\s*=\s*(.+?))?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        var properties: [RecordProperty] = []
        for rawLine in body.split(separator: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            // Skip comments, statics, computed properties, and methods.
            if line.isEmpty || line.hasPrefix("//") || line.hasPrefix("static")
                || line.hasPrefix("func") || line.contains("{")
            {
                continue
            }
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range) else { continue }

            func group(_ index: Int) -> String? {
                guard match.range(at: index).location != NSNotFound,
                    let r = Range(match.range(at: index), in: line)
                else { return nil }
                return String(line[r]).trimmingCharacters(in: .whitespaces)
            }

            guard let name = group(1), let type = group(2) else { continue }
            properties.append(RecordProperty(name: name, type: type, defaultValue: group(3)))
        }
        return properties
    }

    // MARK: - Controller parsing

    struct Endpoint {
        let method: String  // GET, POST, …
        let path: String  // /posts/:id
        let name: String  // list, show, …
        var pathParameters: [String] {
            path.split(separator: "/")
                .filter { $0.hasPrefix(":") }
                .map { String($0.dropFirst()) }
        }
    }

    struct Controller {
        let name: String
        let endpoints: [Endpoint]
        /// Namespace used in the generated `API` enum (`PostsController` → `Posts`).
        var namespace: String {
            name.hasSuffix("Controller") ? String(name.dropLast("Controller".count)) : name
        }
    }

    func parseControllers(in source: String) -> [Controller] {
        structDeclarations(conformingTo: "RouteCollection", in: source).compactMap { declaration in
            let endpoints = parseEndpoints(in: declaration.body)
            guard !endpoints.isEmpty else { return nil }
            return Controller(name: declaration.name, endpoints: endpoints)
        }
    }

    private func parseEndpoints(in body: String) -> [Endpoint] {
        let pattern = #"Route\s*\(\s*method:\s*\.(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\s*,\s*pathPattern:\s*"([^"]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsBody = body as NSString
        let matches = regex.matches(in: body, range: NSRange(location: 0, length: nsBody.length))

        var endpoints: [Endpoint] = []
        var usedNames: Set<String> = []
        for match in matches {
            let method = nsBody.substring(with: match.range(at: 1))
            let path = nsBody.substring(with: match.range(at: 2))

            // Look in the text following the match for a `handler:` label to name
            // the endpoint after (e.g. `handler: list` → `list`).
            let tailStart = match.range.location + match.range.length
            let tailLength = min(200, nsBody.length - tailStart)
            let tail = nsBody.substring(with: NSRange(location: tailStart, length: tailLength))
            let handlerName = firstCapture(#"handler:\s*([A-Za-z_]\w*)"#, in: tail)

            var name = handlerName ?? derivedEndpointName(method: method, path: path)
            var suffix = 2
            while usedNames.contains(name) {
                name = (handlerName ?? derivedEndpointName(method: method, path: path)) + "\(suffix)"
                suffix += 1
            }
            usedNames.insert(name)
            endpoints.append(Endpoint(method: method, path: path, name: name))
        }
        return endpoints
    }

    private func derivedEndpointName(method: String, path: String) -> String {
        var name = method.lowercased()
        for segment in path.split(separator: "/") {
            if segment.hasPrefix(":") {
                name += "By" + pascal(String(segment.dropFirst()))
            } else {
                name += pascal(String(segment))
            }
        }
        return name
    }

    private func pascal(_ value: String) -> String {
        value.split { !$0.isLetter && !$0.isNumber }
            .map { part in
                guard let first = part.first else { return "" }
                return first.uppercased() + part.dropFirst()
            }
            .joined()
    }

    // MARK: - Struct declaration extraction

    struct StructDeclaration {
        let name: String
        let body: String
    }

    /// Find `struct <Name>: …<Protocol>… { … }` declarations and return their
    /// names and brace-matched bodies.
    func structDeclarations(conformingTo protocolName: String, in source: String) -> [StructDeclaration] {
        let pattern = #"struct\s+(\w+)\s*:\s*([^\{]+)\{"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsSource = source as NSString
        let matches = regex.matches(in: source, range: NSRange(location: 0, length: nsSource.length))

        var declarations: [StructDeclaration] = []
        for match in matches {
            let conformances = nsSource.substring(with: match.range(at: 2))
            let conformsToProtocol =
                conformances
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .contains(protocolName)
            guard conformsToProtocol else { continue }

            let name = nsSource.substring(with: match.range(at: 1))
            let openBraceIndex = match.range.location + match.range.length - 1
            guard let body = braceMatchedBody(in: nsSource, openBraceIndex: openBraceIndex) else {
                continue
            }
            declarations.append(StructDeclaration(name: name, body: body))
        }
        return declarations
    }

    private func braceMatchedBody(in source: NSString, openBraceIndex: Int) -> String? {
        var depth = 0
        var index = openBraceIndex
        while index < source.length {
            let ch = source.character(at: index)
            if ch == 123 { depth += 1 }  // {
            if ch == 125 {  // }
                depth -= 1
                if depth == 0 {
                    let bodyRange = NSRange(
                        location: openBraceIndex + 1,
                        length: index - openBraceIndex - 1
                    )
                    return source.substring(with: bodyRange)
                }
            }
            index += 1
        }
        return nil
    }

    private func firstCapture(_ pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsText = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)),
            match.numberOfRanges > 1
        else { return nil }
        return nsText.substring(with: match.range(at: 1))
    }

    // MARK: - Generated sources

    private func packageSwift() -> String {
        """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "\(options.kitName)",
            platforms: [
                .iOS(.v16),
                .macOS(.v13),
                .watchOS(.v9),
                .tvOS(.v16),
            ],
            products: [
                .library(name: "\(options.kitName)", targets: ["\(options.kitName)"])
            ],
            targets: [
                .target(name: "\(options.kitName)")
            ]
        )
        """
    }

    /// Marker line used to recognise generated kit targets for auto-regeneration.
    public static let generatedMarker = "// Generated by `score package swiftui` — do not edit."

    private func recordShim() -> String {
        """
        \(Self.generatedMarker)

        import Foundation

        /// Client-side mirror of Score's `Record` protocol.
        ///
        /// Generated so exported models compile without depending on the
        /// Score framework.
        public protocol Record: Codable, Sendable, Identifiable where ID == UUID {
            var id: UUID { get set }
            var createdAt: Date { get set }
            var updatedAt: Date { get set }
        }
        """
    }

    private func modelSource(_ record: RecordModel) -> String {
        var lines: [String] = []
        lines.append("import Foundation")
        lines.append("")
        lines.append("/// Mirrors the `\(record.name)` record from the Score application.")
        lines.append("public struct \(record.name): Record {")
        for property in record.properties {
            lines.append("    public var \(property.name): \(property.type)")
        }
        lines.append("")

        // Memberwise initializer, preserving source defaults and providing
        // canonical defaults for the Record-required fields.
        var parameters: [String] = []
        for property in record.properties {
            var defaultValue = property.defaultValue
            if defaultValue == nil {
                switch property.name {
                case "id" where property.type == "UUID":
                    defaultValue = "UUID()"
                case "createdAt", "updatedAt":
                    if property.type == "Date" { defaultValue = "Date()" }
                default:
                    break
                }
            }
            if let defaultValue {
                parameters.append("\(property.name): \(property.type) = \(defaultValue)")
            } else {
                parameters.append("\(property.name): \(property.type)")
            }
        }
        lines.append("    public init(")
        lines.append("        " + parameters.joined(separator: ",\n        "))
        lines.append("    ) {")
        for property in record.properties {
            lines.append("        self.\(property.name) = \(property.name)")
        }
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func apiClientSource() -> String {
        """
        import Foundation
        #if canImport(FoundationNetworking)
        import FoundationNetworking
        #endif

        // MARK: - HTTPMethod

        public enum HTTPMethod: String, Sendable {
            case get = "GET"
            case post = "POST"
            case put = "PUT"
            case patch = "PATCH"
            case delete = "DELETE"
            case head = "HEAD"
            case options = "OPTIONS"
        }

        // MARK: - Endpoint

        /// A typed reference to a Score API route.
        public struct Endpoint: Sendable {
            public let method: HTTPMethod
            public let path: String

            public init(_ method: HTTPMethod, _ path: String) {
                self.method = method
                self.path = path
            }
        }

        // MARK: - ScoreAPIError

        public enum ScoreAPIError: Error {
            case invalidResponse
            case httpError(statusCode: Int, data: Data)
        }

        // MARK: - ScoreAPIClient

        /// An async/await HTTP client for your Score application's API routes.
        ///
        /// ```swift
        /// let client = ScoreAPIClient(baseURL: URL(string: "https://example.com/api/v1")!)
        /// let posts: [Post] = try await client.request(API.Posts.list)
        /// ```
        public struct ScoreAPIClient: Sendable {
            public let baseURL: URL
            public let session: URLSession

            public init(baseURL: URL, session: URLSession = .shared) {
                self.baseURL = baseURL
                self.session = session
            }

            // MARK: - Requests

            /// Perform the endpoint and decode the JSON response.
            public func request<T: Decodable>(
                _ endpoint: Endpoint,
                query: [String: String] = [:]
            ) async throws -> T {
                let data = try await send(endpoint, query: query)
                return try decoder().decode(T.self, from: data)
            }

            /// Perform the endpoint with a JSON body and decode the response.
            public func request<T: Decodable>(
                _ endpoint: Endpoint,
                body: some Encodable,
                query: [String: String] = [:]
            ) async throws -> T {
                let data = try await send(endpoint, body: body, query: query)
                return try decoder().decode(T.self, from: data)
            }

            /// Perform the endpoint and return the raw response body.
            public func send(
                _ endpoint: Endpoint,
                query: [String: String] = [:]
            ) async throws -> Data {
                try await perform(endpoint, bodyData: nil, query: query)
            }

            /// Perform the endpoint with a JSON body and return the raw response body.
            public func send(
                _ endpoint: Endpoint,
                body: some Encodable,
                query: [String: String] = [:]
            ) async throws -> Data {
                let bodyData = try encoder().encode(body)
                return try await perform(endpoint, bodyData: bodyData, query: query)
            }

            // MARK: - Internals

            private func perform(
                _ endpoint: Endpoint,
                bodyData: Data?,
                query: [String: String]
            ) async throws -> Data {
                let url = baseURL.appendingPathComponent(endpoint.path)
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if !query.isEmpty {
                    components?.queryItems = query
                        .sorted { $0.key < $1.key }
                        .map { URLQueryItem(name: $0.key, value: $0.value) }
                }
                guard let finalURL = components?.url else {
                    throw ScoreAPIError.invalidResponse
                }

                var request = URLRequest(url: finalURL)
                request.httpMethod = endpoint.method.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                if let bodyData {
                    request.httpBody = bodyData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }

                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw ScoreAPIError.invalidResponse
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw ScoreAPIError.httpError(statusCode: http.statusCode, data: data)
                }
                return data
            }

            private func encoder() -> JSONEncoder {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                return encoder
            }

            private func decoder() -> JSONDecoder {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }
        }
        """
    }

    private func endpointsSource(controllers: [Controller]) -> String {
        var lines: [String] = []
        lines.append("import Foundation")
        lines.append("")
        lines.append("/// Typed endpoints for every `RouteCollection` in the Score application.")
        lines.append("public enum API {")

        for (index, controller) in controllers.enumerated() {
            if index > 0 { lines.append("") }
            lines.append("    /// Endpoints from `\(controller.name)`.")
            lines.append("    public enum \(controller.namespace) {")
            for endpoint in controller.endpoints {
                let method = endpoint.method.lowercased()
                lines.append("        /// \(endpoint.method) \(endpoint.path)")
                let parameters = endpoint.pathParameters
                if parameters.isEmpty {
                    lines.append(
                        "        public static var \(endpoint.name): Endpoint { Endpoint(.\(method), \"\(endpoint.path)\") }"
                    )
                } else {
                    let parameterList = parameters.map { "\($0): String" }.joined(separator: ", ")
                    var interpolatedPath = endpoint.path
                    for parameter in parameters {
                        interpolatedPath = interpolatedPath.replacingOccurrences(
                            of: ":\(parameter)",
                            with: "\\(\(parameter))"
                        )
                    }
                    lines.append(
                        "        public static func \(endpoint.name)(\(parameterList)) -> Endpoint { Endpoint(.\(method), \"\(interpolatedPath)\") }"
                    )
                }
            }
            lines.append("    }")
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func readme(records: [RecordModel], controllers: [Controller]) -> String {
        let recordList =
            records.isEmpty
            ? "_(none found)_"
            : records.map { "- `\($0.name)`" }.joined(separator: "\n")
        let controllerList =
            controllers.isEmpty
            ? "_(none found)_"
            : controllers.map { "- `\($0.name)` (\($0.endpoints.count) endpoints)" }.joined(separator: "\n")

        return """
            # \(options.kitName)

            A Swift package generated by `score package swiftui`. It exposes your
            Score application's models and API endpoints to native SwiftUI apps,
            with no dependency on the Score framework.

            ## Exported records

            \(recordList)

            ## Exported controllers

            \(controllerList)

            ## Usage

            ```swift
            import \(options.kitName)

            let client = ScoreAPIClient(baseURL: URL(string: "\(options.exampleBaseURL)")!)
            // let posts: [Post] = try await client.request(API.Posts.list)
            ```

            The base URL should include your app's API prefix (Score defaults to
            `/api/v1`). Dates are encoded and decoded as ISO 8601.

            ## Regenerating

            This package is fully generated — do not edit by hand. Re-run
            `score package swiftui` in your Score project after changing records
            or controllers.
            """
    }
}
