// swift-tools-version: 5.8
import PackageDescription

#if TUIST
    import ProjectDescription

    let dependencySettings = Settings.settings(base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0"
    ])

    let packageSettings = PackageSettings(
        // Synthesized resource bundles do not inherit targetSettings.
        productTypes: ["Kingfisher": .framework],
        baseSettings: dependencySettings,
        // Package deployment targets override base settings in generated targets.
        targetSettings: [
            "_LottieStub": dependencySettings,
            "Kingfisher": dependencySettings
        ]
    )
#endif

let package = Package(
    name: "WrapKit",
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm", exact: "4.5.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.12.0"),
    ]
)
