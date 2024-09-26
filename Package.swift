// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WrapKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "WrapKit",
            type: .dynamic,
            targets: ["WrapKit"]),
        .library(
            name: "WrapKitTestUtils",
            type: .dynamic,
            targets: ["WrapKitTestUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/joomcode/BottomSheet", from: "2.0.5"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                .product(name: "BottomSheet", package: "BottomSheet", condition: .when(platforms: [.iOS])),
                .product(name: "Kingfisher", package: "Kingfisher", condition: .when(platforms: [.iOS])),
            ],
            path: "WrapKitCore/Sources"
        ),
        .target(
            name: "WrapKitTestUtils",
            dependencies: [],
            path: "WrapKitCore/TestUtils", 
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: [
                "WrapKit",
                "WrapKitTestUtils",
                .product(name: "BottomSheet", package: "BottomSheet", condition: .when(platforms: [.iOS])),
                .product(name: "Kingfisher", package: "Kingfisher", condition: .when(platforms: [.iOS])),
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
