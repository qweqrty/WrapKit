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
            name: "WrapKit",
            type: .static,
            targets: ["WrapKit"]),
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
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
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
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
