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
                .external(name: "Lottie"),
                .external(name: "PhoneNumberKit"),
                .external(name: "DeviceKit")
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
                .xctest,
                .target(name: wrapKit.name),
            ]
        ),
        .target(
            name: "\(wrapKit.name)Tests",
            destinations: .all,
            product: .unitTests,
            bundleId: "\(wrapKit.bundleId)Tests",
            deploymentTargets: .all,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: wrapKit.name),
                .target(name: wrapKitTestUtils.name),
                .xctest
            ]
        )
    ]
)
