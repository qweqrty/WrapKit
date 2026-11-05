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
            resources: ["Sources/Resources/PrivacyInfo.xcprivacy"],
            scripts: [Scripts.swiftlint],
            dependencies: [
                .external(name: "Kingfisher"),
                .external(name: "PhoneNumberKit"),
                .external(name: "DeviceKit"),
                .external(name: "Lottie", condition: .when([.ios, .macos, .tvos, .visionos, .catalyst]))
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
            infoPlist: .extendingDefault(with: ["UILaunchScreen": .dictionary([:])]),
            sources: ["TestHost/**"],
            dependencies: [.target(name: wrapKit.name)]
        ),
        .target(
            name: "WrapKitUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: bundleId(for: "WrapKitUITests"),
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["UITests/**"],
            dependencies: [
                .target(name: "WrapKitTestHost"),
                .xctest
            ]
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
                .project(target: wrapKitGame.name, path: wrapKitGame.path),
                .xctest
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "WrapKitUITests",
            shared: true,
            buildAction: .buildAction(targets: [.target("WrapKitTestHost")]),
            testAction: .targets([.testableTarget(target: .target("WrapKitUITests"))])
        )
    ]
)
