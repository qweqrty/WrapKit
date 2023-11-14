// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WrapKit",
    products: [
        .library(
            name: "WrapKit",
            type: .static,
            targets: ["WrapKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: ["WrapKit"],
            path: "Tests"
        ),
    ]
)
