// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Thumby",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Thumby", targets: ["Thumby"])
    ],
    targets: [
        .executableTarget(
            name: "Thumby",
            path: "Sources/Thumby"
        )
    ]
)
