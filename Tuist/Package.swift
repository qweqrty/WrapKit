// swift-tools-version: 5.8
import PackageDescription

#if TUIST
    import ProjectDescription

    let dependencySettings = Settings.settings(base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
        "MACOSX_DEPLOYMENT_TARGET": "12.0"
    ])
    let dependencyTargets = ["Kingfisher", "_LottieStub"]

    let packageSettings = PackageSettings(
        // Synthesized resource bundles do not inherit targetSettings in Tuist.
        // Keep resources in frameworks to avoid deployment targets rejected by Xcode 27.
        productTypes: [
            "Kingfisher": .framework
        ],
        baseSettings: dependencySettings,
        targetSettings: Dictionary(uniqueKeysWithValues: dependencyTargets.map { ($0, dependencySettings) })
    )
#endif

let package = Package(
    name: "WrapKit",
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm", exact: "4.5.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.12.0"),
    ]
)
