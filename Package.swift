// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCreativesExperimental",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftyCreativesExperimental",
            targets: ["SwiftyCreatives"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftyCreatives",
            dependencies: [
                "FontVertexBuilder",
                "CommonEntity",
                "SCSound"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "iShapeTriangulation",
            dependencies: [
                "iGeometry"
            ]
        ),
        .target(
            name: "iGeometry"
        ),
        .target(
            name: "FontVertexBuilder",
            dependencies: [
                "iShapeTriangulation",
                "CommonEntity"
            ]
        ),
        .target(
            name: "CommonEntity"
        ),
        .target(
            name: "SCSound"
        )
    ]
)
