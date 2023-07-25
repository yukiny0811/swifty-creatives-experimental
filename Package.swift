// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCreativesExperimental",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftyCreativesExperimental",
            targets: ["SwiftyCreatives"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.11.0"),
        .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftyCreatives",
            dependencies: [
                "FontVertexBuilder",
                "CommonEntity",
                "SCSound",
                .product(name: "Algorithms", package: "swift-algorithms")
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
        ),
        .testTarget(
            name: "SwiftyCreativesTests",
            dependencies: [
                "SwiftyCreatives",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
