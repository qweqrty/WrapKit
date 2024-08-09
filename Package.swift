// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WrapKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "WrapKitStatic",
            type: .static,
            targets: ["WrapKit"]),
        .library(
            name: "WrapKitDynamic",
            type: .dynamic,
            targets: ["WrapKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher", condition: .when(platforms: [.iOS]))
            ],
            path: "WrapKitCore/Sources"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: [
                "WrapKit",
                .product(name: "Kingfisher", package: "Kingfisher", condition: .when(platforms: [.iOS]))
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
