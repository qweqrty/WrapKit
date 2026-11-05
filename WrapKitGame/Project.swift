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
            resources: ["Sources/Resources/PrivacyInfo.xcprivacy"],
            scripts: [Scripts.swiftlint],
            dependencies: [
                .project(target: wrapKit.name, path: wrapKit.path),
                .external(name: "Kingfisher")
            ]
        ),
    ]
)
