// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "WrapKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
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
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.3"),
        .package(url: "https://github.com/airbnb/lottie-spm", from: "4.5.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.12.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.0"),
        .package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                "Kingfisher",
                "PhoneNumberKit",
                "DeviceKit",
		"CryptoSwift",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "WrapKitCore/Sources"
        ),
        .target(
            name: "WrapKitGame",
            dependencies: [
                "WrapKit",
                .product(name: "Lottie", package: "lottie-spm")
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
                "PhoneNumberKit",
                "DeviceKit",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
