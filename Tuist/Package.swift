// swift-tools-version: 5.8
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [
            :
        ]
    )
#endif

let package = Package(
    name: "WrapKit",
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm", from: "4.5.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.1"),
        .package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0")
    ]
)
