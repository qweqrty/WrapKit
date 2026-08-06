import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: wrapKit.name,
    targets: [
        .target(
            name: wrapKit.name,
            destinations: .all,
            product: .framework,
            bundleId: wrapKit.bundleId,
            deploymentTargets: .all,
            sources: [.glob("Sources/**", excluding: ["**/Project.swift", "**/*Tests.swift"])],
            scripts: [Scripts.swiftlint],
            dependencies: [
                .external(name: "Kingfisher"),
                .external(name: "Lottie")
            ]
        ),
        .target(
            name: wrapKitTestUtils.name,
            destinations: .all,
            product: .framework,
            bundleId: wrapKitTestUtils.bundleId,
            deploymentTargets: .all,
            sources: [.glob("TestUtils/**", excluding: ["**/Project.swift", "**/*Tests.swift"])],
            scripts: [Scripts.swiftlint],
            dependencies: [
                .target(name: wrapKit.name),
                .xctest
            ]
        ),
        .target(
            name: "WrapKitTestHost",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: bundleId(for: "WrapKitTestHost"),
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["TestHost/**"],
            dependencies: []
        ),
        .target(
            name: "\(wrapKit.name)Tests",
            destinations: .all,
            product: .unitTests,
            bundleId: "\(wrapKit.bundleId)Tests",
            deploymentTargets: .all,
            sources: ["Tests/**"],
            resources: ["Tests/Resources/**"],
            dependencies: [
                .target(name: wrapKitTestUtils.name),
                .target(name: "WrapKitTestHost"),
                .xctest
            ]
        )
    ]
)
