// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Score",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "Score", targets: ["Score"]),
        .library(name: "ScoreCore", targets: ["ScoreCore"]),
        .library(name: "ScoreHTTP", targets: ["ScoreHTTP"]),
        .library(name: "ScoreRouter", targets: ["ScoreRouter"]),
        .library(name: "ScoreData", targets: ["ScoreData"]),
        .library(name: "ScoreSSG", targets: ["ScoreSSG"]),
        .library(name: "ScoreBuild", targets: ["ScoreBuild"]),
        .library(name: "ScorePackaging", targets: ["ScorePackaging"]),
        .executable(name: "score", targets: ["ScoreCLI"]),
    ],
    dependencies: [
        // Apple / swift-server packages
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.27.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.32.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.22.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.5.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.5.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.6.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        // MARK: - System library (SQLite3 on Linux)
        .systemLibrary(
            name: "CSQLite",
            pkgConfig: "sqlite3",
            providers: [
                .brew(["sqlite"]),
                .apt(["libsqlite3-dev"]),
            ]
        ),

        // MARK: - ScoreCore
        .target(
            name: "ScoreCore",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),

        // MARK: - ScoreHTTP
        .target(
            name: "ScoreHTTP",
            dependencies: [
                "ScoreCore",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOExtras", package: "swift-nio-extras"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),

        // MARK: - ScoreRouter
        .target(
            name: "ScoreRouter",
            dependencies: [
                "ScoreCore",
                "ScoreHTTP",
            ]
        ),

        // MARK: - ScoreData
        .target(
            name: "ScoreData",
            dependencies: [
                "ScoreCore",
                "CSQLite",
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),

        // MARK: - ScoreSSG
        .target(
            name: "ScoreSSG",
            dependencies: [
                "ScoreCore",
                "ScoreHTTP",
                "ScoreRouter",
                "ScoreData",
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),

        // MARK: - ScoreBuild
        .target(
            name: "ScoreBuild",
            dependencies: [
                "ScoreCore",
                "ScoreSSG",
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),

        // MARK: - ScorePackaging
        .target(
            name: "ScorePackaging"
        ),

        // MARK: - Score (umbrella)
        .target(
            name: "Score",
            dependencies: [
                "ScoreCore",
                "ScoreHTTP",
                "ScoreRouter",
                "ScoreData",
                "ScoreSSG",
                "ScoreBuild",
            ]
        ),

        // MARK: - ScoreCLI (executable)
        .executableTarget(
            name: "ScoreCLI",
            dependencies: [
                "Score",
                "ScorePackaging",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),

        // MARK: - Test Targets
        .testTarget(
            name: "ScoreCoreTests",
            dependencies: ["ScoreCore"]
        ),
        .testTarget(
            name: "ScoreHTTPTests",
            dependencies: ["ScoreHTTP"]
        ),
        .testTarget(
            name: "ScoreRouterTests",
            dependencies: ["ScoreRouter", "ScoreHTTP"]
        ),
        .testTarget(
            name: "ScoreDataTests",
            dependencies: ["ScoreData"]
        ),
        .testTarget(
            name: "ScoreSSGTests",
            dependencies: ["ScoreSSG"]
        ),
        .testTarget(
            name: "ScoreBuildTests",
            dependencies: ["ScoreBuild"]
        ),
        .testTarget(
            name: "ScorePackagingTests",
            dependencies: ["ScorePackaging"]
        ),
        .testTarget(
            name: "ScoreIntegrationTests",
            dependencies: ["Score"]
        ),
    ]
)
