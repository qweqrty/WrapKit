import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: wrapKitGame.name,
    targets: [
        .target(
            name: wrapKitGame.name,
            destinations: .all,
            product: .framework,
            bundleId: wrapKitGame.bundleId,
            deploymentTargets: .all,
            sources: [.glob("Sources/**", excluding: ["**/Project.swift", "**/*Tests.swift"])],
            scripts: [Scripts.swiftlint],
            dependencies: [
                .project(target: wrapKit.name, path: wrapKit.path),
                .external(name: "Kingfisher"),
                .external(name: "DeviceKit")
            ]
        ),
    ]
)
