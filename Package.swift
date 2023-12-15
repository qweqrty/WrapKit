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
    dependencies: [.package(url: "https://github.com/realm/realm-swift.git", from: "10.44.0")],
    targets: [
        .target(
            name: "WrapKit",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WrapKitTests",
            dependencies: ["WrapKit"],
            path: "Tests"
        ),
    ]
)
