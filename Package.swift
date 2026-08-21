// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "WrapKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
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
                .product(
                    name: "Lottie",
                    package: "lottie-spm",
                    condition: .when(
                        platforms: [.iOS, .macOS, .tvOS, .visionOS, .macCatalyst]
                    )
                ),
            ],
            path: "WrapKitCore/Sources"
        ),
        .target(
            name: "WrapKitGame",
            dependencies: [
                "WrapKit",
                .product(
                    name: "Lottie",
                    package: "lottie-spm",
                    condition: .when(
                        platforms: [.iOS, .macOS, .tvOS, .visionOS, .macCatalyst]
                    )
                ),
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
                .product(
                    name: "Lottie",
                    package: "lottie-spm",
                    condition: .when(
                        platforms: [.iOS, .macOS, .tvOS, .visionOS, .macCatalyst]
                    )
                )
            ],
            path: "WrapKitCore/Tests",
            resources: [.process("Resources")]
        ),
    ]
)
