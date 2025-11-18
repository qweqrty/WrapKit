#if canImport(UIKit)
import UIKit

public extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

public extension UIView {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, rootView: self).snapshot()
    }
}

public struct SnapshotConfiguration {
    public static let size = CGSize(width: 1170 / UIScreen.main.scale, height: 2532 / UIScreen.main.scale)
    
    public let size: CGSize
    public let safeAreaInsets: UIEdgeInsets
    public let layoutMargins: UIEdgeInsets
    public let traitCollection: UITraitCollection
    
    public init(size: CGSize, safeAreaInsets: UIEdgeInsets, layoutMargins: UIEdgeInsets, traitCollection: UITraitCollection) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.layoutMargins = layoutMargins
        self.traitCollection = traitCollection
    }
    
    public static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        let forceTouch = UITraitCollection(forceTouchCapability: .unavailable)
        let layoutDirection = UITraitCollection(layoutDirection: .leftToRight)
        let contentSizeCategory = UITraitCollection(preferredContentSizeCategory: contentSize)
        let userInterfaceIdiom = UITraitCollection(userInterfaceIdiom: .phone)
        let horizontalSizeClass = UITraitCollection(horizontalSizeClass: .compact)
        let verticalSizeClass = UITraitCollection(verticalSizeClass: .regular)
        let displayScale = UITraitCollection(displayScale: 3.0)
        let accessibilityContrast = UITraitCollection(accessibilityContrast: .normal)
        let displayGamut = UITraitCollection(displayGamut: .P3)
        let userInterfaceStyle = UITraitCollection(userInterfaceStyle: style)
        
        let traitCollection = UITraitCollection(traitsFrom: [
            forceTouch,
            layoutDirection,
            contentSizeCategory,
            userInterfaceIdiom,
            horizontalSizeClass,
            verticalSizeClass,
            displayScale,
            accessibilityContrast,
            displayGamut,
            userInterfaceStyle
        ])
        
        return SnapshotConfiguration(
            size: Self.size,
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: traitCollection
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    convenience init(configuration: SnapshotConfiguration, rootView: UIView) {
        let viewController = UIViewController()
        viewController.view.addSubview(rootView)
        self.init(configuration: configuration, root: viewController)
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }
    
    public func snapshot() -> UIImage {
        return self.asImage(scale: traitCollection.displayScale)
    }
}

extension UIView {
    func asImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat(for: traitCollection)
        format.scale = scale // This ensures the correct resolution (1x, 2x, 3x, etc.)
        format.preferredRange = .extended // .standard // disable HDR
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { action in
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB() // Default sRGB color space (IEC61966-2.1)
            action.cgContext.setFillColorSpace(colorSpace)
            layer.render(in: action.cgContext)
        }
    }
}
#endif
