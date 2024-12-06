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
            type: .dynamic,
            targets: ["WrapKit"]),
        .library(
            name: "WrapKitTestUtils",
            type: .dynamic,
            targets: ["WrapKitTestUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.0"),
        .package(url: "https://github.com/funky-monkey/IsoCountryCodes", from: "1.0.2"),
        .package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "IsoCountryCodes", package: "IsoCountryCodes"),
                .product(name: "DeviceKit", package: "DeviceKit")
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
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "IsoCountryCodes", package: "IsoCountryCodes"),
                .product(name: "DeviceKit", package: "DeviceKit")
                
            ],
            path: "WrapKitCore/Tests"
        ),
    ]
)
