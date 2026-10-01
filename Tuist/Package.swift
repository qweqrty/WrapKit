// swift-tools-version: 5.8
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Share Kingfisher's cache and downloader across WrapKit and its consumers.
        productTypes: [
            "Kingfisher": .framework
        ]
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
