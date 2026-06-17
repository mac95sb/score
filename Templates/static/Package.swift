// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "__NAME__",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "__NAME__",
            dependencies: [
                .product(name: "Score", package: "score"),
            ],
            path: "Sources"
        ),
    ]
)
