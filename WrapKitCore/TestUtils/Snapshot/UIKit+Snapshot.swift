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
    public static let size = CGSize(width: 390, height: 844)
    
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
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        let viewController = UIViewController()
        viewController.view.addSubview(rootView)
        self.rootViewController = viewController
        self.isHidden = false
        rootView.layoutMargins = configuration.layoutMargins
    }
    
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }
    
    public func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
#endif
