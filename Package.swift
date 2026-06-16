// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Thumbcraft",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Thumbcraft", targets: ["Thumbcraft"])
    ],
    targets: [
        .executableTarget(
            name: "Thumbcraft",
            path: "Sources/Thumbcraft"
        )
    ]
)
