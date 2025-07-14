import ProjectDescription
import ProjectDescriptionHelpers

let projectSettings = Settings.settings(
    base: [
        "OTHER_LDFLAGS": "-all_load",
        "PRODUCT_NAME": .string(wrapKitMac.name),
        "CURRENT_PROJECT_VERSION": "0",
        "MARKETING_VERSION": "4.4.1",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "CODE_SIGN_STYLE": "Automatic",
        "GENERATE_INFOPLIST_FILE": "NO",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "SWIFT_VERSION": "5.0",
        "TARGETED_DEVICE_FAMILY": .array(["1", "2"]),
        "LD_RUNPATH_SEARCH_PATHS[config=Debug]": "$(inherited) @executable_path/Frameworks",
        "LD_RUNPATH_SEARCH_PATHS[config=Release]": "$(inherited) @executable_path/Frameworks",
        "ENABLE_TESTING_SEARCH_PATHS": "YES",
        "LAUNCHSCREEN_NAME": "LaunchScreen"
    ]
)

let project = Project(
    name: wrapKitMac.name,
    settings: projectSettings,
    targets: [
        .target(
            name: wrapKitMac.name,
            destinations: .all,
            product: .app,
            bundleId: wrapKitMac.bundleId,
            deploymentTargets: .all,
            infoPlist: "Sources/Info.plist",
            sources: [.glob("Sources/**", excluding: ["**/Project.swift", "**/*Tests.swift"])],
            resources: ["Sources/Assets.xcassets"],
         scripts: [Scripts.swiftlint],
            dependencies: [
               // .project(target: wrapKit.name, path: wrapKit.path),
            ],
            settings: projectSettings
        )
    ],
    resourceSynthesizers: []
)
