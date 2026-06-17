// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KitchenSink",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "KitchenSink",
            dependencies: [
                .product(name: "Score", package: "score"),
            ],
            path: "Sources"
        ),
    ]
)
