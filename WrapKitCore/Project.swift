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
        )
    ]
)
