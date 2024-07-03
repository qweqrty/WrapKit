// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WrapKit",
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
        .package(url: "https://github.com/joomcode/BottomSheet", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [.product(name: "BottomSheet", package: "BottomSheet")],
            path: "WrapKitCore/Sources"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: ["WrapKit", .product(name: "BottomSheet", package: "BottomSheet")],
            path: "WrapKitCore/Tests"
        ),
    ]
)
