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
            name: "WrapKitRealm",
            type: .static,
            targets: ["WrapKitRealm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa", from: "10.14.0")
    ],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [],
            path: "WrapKitCore/Sources"
        ),
        .target(
            name: "WrapKitRealm",
            dependencies: [
                "WrapKit",
                .product(name: "Realm", package: "realm-cocoa"),
                .product(name: "RealmSwift", package: "realm-cocoa"),
            ],
            path: "WrapKitRealm/Sources"
        ),
        .testTarget(
            name: "WrapKitRealmTests",
            dependencies: ["WrapKit"],
            path: "WrapKitRealm/Tests"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: ["WrapKit"],
            path: "WrapKitCore/Tests"
        ),
    ]
)
