// swift-tools-version: 5.8
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
            name: "WrapKit",
            targets: ["WrapKit"]),
        .library(
            name: "WrapKitTestUtils",
            targets: ["WrapKitTestUtils"]),
        .library(
            name: "WrapKitDynamic",
            type: .dynamic,
            targets: ["WrapKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.0"),
        .package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                "Kingfisher",
                .product(name: "PhoneNumberKit-Dynamic", package: "PhoneNumberKit"),
                "DeviceKit"
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
                "Kingfisher",
                .product(name: "PhoneNumberKit-Dynamic", package: "PhoneNumberKit"),
                "DeviceKit"
                
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
