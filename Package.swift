// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WrapKit",
    products: [
        .library(
            name: "WrapKitStatic",
            type: .static,
            targets: ["WrapKit"])
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [],
            path: "WrapKitCore/Sources"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: ["WrapKit"],
            path: "WrapKitCore/Tests"
        ),
    ]
)
