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
        let displayGamut = UITraitCollection(displayGamut: .SRGB) // was P3
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
        if rootView is UIWindow {
            rootView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                rootView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                rootView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                rootView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                rootView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])
        }
        self.init(configuration: configuration, root: viewController)
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }
    
    public func snapshot() -> UIImage {
        let image: UIImage
        if #available(iOS 26, *) {
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first {
                windowScene = scene
            }
            makeKeyAndVisible()
            layoutIfNeeded()
            if containsGlassEffect() {
                RunLoop.current.run(until: Date().addingTimeInterval(0.6))
            }
            removeAllLayerAnimations()
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            let format = UIGraphicsImageRendererFormat(for: traitCollection)
            format.scale = traitCollection.displayScale
            format.preferredRange = .extended
            format.opaque = false
            image = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: true)
            }
        } else {
            image = asImage(scale: traitCollection.displayScale)
        }

        rootViewController = nil
        isHidden = true
        resignKey()
        windowScene = nil
        RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        return image
    }

    private func containsGlassEffect() -> Bool {
        func walk(_ v: UIView) -> Bool {
            if v is UIVisualEffectView { return true }
            for s in v.subviews where walk(s) { return true }
            return false
        }
        return walk(self)
    }

    private func removeAllLayerAnimations() {
        func walkLayer(_ layer: CALayer) {
            layer.removeAllAnimations()
            layer.sublayers?.forEach(walkLayer)
        }
        func walkView(_ view: UIView) {
            walkLayer(view.layer)
            view.subviews.forEach(walkView)
        }
        walkView(self)
    }
}

extension UIView {
    func asImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat(for: traitCollection)
        format.scale = scale // This ensures the correct resolution (1x, 2x, 3x, etc.)
        format.preferredRange =  .extended // UIKit not passing with standart
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { context in
            let colorSpace = CGColorSpaceCreateDeviceRGB() // Default sRGB color space (IEC61966-2.1)
            context.cgContext.setFillColorSpace(colorSpace)
            layer.render(in: context.cgContext)
        }
    }
}
#endif
