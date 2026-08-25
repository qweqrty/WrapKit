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
        .package(url: "https://github.com/airbnb/lottie-spm", exact: "4.5.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.12.0"),
    ]
)
