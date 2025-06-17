// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Palette",
    platforms: [
        .macCatalyst(.v13),
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "Palette",
            targets: ["Palette"]
        ),
    ],
    targets: [
        .target(name: "Palette", path: "Sources"),
    ]
)
