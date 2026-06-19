// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "WrapKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "WrapKit",
            targets: ["WrapKit"]),
        .library(
            name: "WrapKitGame",
            targets: ["WrapKitGame"]),
        .library(
            name: "WrapKitTestUtils",
            targets: ["WrapKitTestUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm", from: "4.5.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.12.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                "Kingfisher",
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "WrapKitCore/Sources"
        ),
        .target(
            name: "WrapKitGame",
            dependencies: [
                "WrapKit",
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "WrapKitGame/Sources"
        ),
        .target(
            name: "WrapKitTestUtils",
            dependencies: [
                "WrapKit",
            ],
            path: "WrapKitCore/TestUtils",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: [
                "WrapKit",
                "WrapKitTestUtils",
                "Kingfisher",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "WrapKitCore/Tests",
            resources: [.process("Resources")]
        ),
    ]
)
