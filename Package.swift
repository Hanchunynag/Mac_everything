// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MacEverything",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacEverything", targets: ["MacEverything"])
    ],
    targets: [
        .executableTarget(name: "MacEverything"),
        .testTarget(
            name: "MacEverythingTests",
            dependencies: ["MacEverything"]
        )
    ]
)
