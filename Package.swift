// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCreativesExperimental",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftyCreativesExperimental",
            targets: ["SwiftyCreatives"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/yukiny0811/SimpleSimdSwift", exact: "1.0.1"),
        .package(url: "https://github.com/yukiny0811/FontVertexBuilder", exact: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftyCreatives",
            dependencies: [
                "FontVertexBuilder",
                "SimpleSimdSwift",
                "SCSound"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SCSound"
        )
    ]
)
