import ProjectDescription

public func bundleId(for targetName: String) -> String {
    "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)"
}

extension Path {
    public static func modulesRelative(_ path: String) -> ProjectDescription.Path {
        .relativeToRoot("\(path)")
    }
}

public let swiftUIApp = Project(name: "SwiftUIApp", path: .modulesRelative("SwiftUIApp"))

// MARK: - Features
public let wrapKit = Project(name: "WrapKit", path: .modulesRelative("WrapKitCore"))

// Scripts
public enum Scripts {
    public static let swiftlint = ProjectDescription.TargetScript.pre(
        path: .relativeToRoot("Scripts/swiftlint.sh"),
        arguments: [],
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )
}

// Helpers
public struct Project: Sendable{
    public let name: String
    public let path: Path
    public var bundleId: String { "${PRODUCT_BUNDLE_IDENTIFIER}.\(name)" }
    
    public var moduleName: String { name }
}

public extension ProjectDescription.Destinations {
    static let all: Set<Destination> = [.iPhone, .iPad, .mac, .macCatalyst, .appleWatch, .appleTv, .appleVision, .appleVisionWithiPadDesign]
}

public extension ProjectDescription.DeploymentTargets {
    // Deployment targets with calculated risk assesments
    static let all: ProjectDescription.DeploymentTargets = .multiplatform(
        iOS: "14.0",
        macOS: "11.0",
        watchOS: "6.0",
        tvOS: "13.0",
        visionOS: "1.0"
    )
}
