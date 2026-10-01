// swift-tools-version: 5.8
import PackageDescription

#if TUIST
    import ProjectDescription

    let dependencySettings = Settings.settings(base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
        "MACOSX_DEPLOYMENT_TARGET": "12.0"
    ])
    let dependencyTargets = ["DeviceKit", "Kingfisher", "PhoneNumberKit", "_LottieStub"]

    let packageSettings = PackageSettings(
        // Share Kingfisher's cache and downloader across WrapKit and its consumers.
        // Synthesized resource bundles do not inherit targetSettings in Tuist.
        // Keep resources in frameworks to avoid deployment targets rejected by Xcode 27.
        productTypes: [
            "DeviceKit": .framework,
            "Kingfisher": .framework,
            "PhoneNumberKit": .framework
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
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", exact: "4.0.1"),
        .package(url: "https://github.com/devicekit/DeviceKit", exact: "5.5.0"),
    ]
)
