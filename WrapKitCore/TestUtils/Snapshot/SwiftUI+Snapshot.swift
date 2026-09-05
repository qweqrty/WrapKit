#if canImport(SwiftUI)
import SwiftUI

public enum SwiftUISnapshotPrecision {
    /// Positive snapshots must reject every visible change. `strictImage` still normalizes both
    /// images and accepts only its bounded PNG/color-space quantization tolerance.
    public static let standard: Float = 1
    public static let fail: Float = 1
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot(for configuration: SUISnapshotConfiguration, background: Color? = nil, useUIKit: Bool = false) -> UIImage {
        let view = self.build(configuration: configuration, background: background)
#if canImport(UIKit)
        guard useUIKit else {
            return view.snapshot(size: configuration.size, scale: configuration.scale)
        }
        return view.inHostController()
            .snapshot(for: configuration.uiKitSnapshotConfiguration)
#else
        return view.snapshot(size: configuration.size, scale: configuration.scale)
#endif
    }
#if canImport(UIKit)
    func inHostController(forceRender: Bool = false) -> UIViewController {
        let viewController = UIHostingController(rootView: self.ignoresSafeArea(.all))
        viewController.view.backgroundColor = .clear
        if forceRender {
            viewController.forceRender()
        }
        return viewController
    }
#endif
}

extension UIHostingController {
  fileprivate func forceRender() {
    _render(seconds: 0)
  }
}

public struct SUISnapshotConfiguration {
    public static let size = SnapshotRenderDefaults.size
    public static let sizePx = SnapshotRenderDefaults.pixelSize
    public static let scale = SnapshotRenderDefaults.scale
    
    public let size: CGSize
    public let safeAreaInsets: EdgeInsets
    public let layoutMargins: EdgeInsets
    public let colorScheme: ColorScheme
    public let scale: CGFloat
    public let locale: Locale
    public let dynamicTypeSize: DynamicTypeSize
    public let layoutDirection: LayoutDirection
    
    public init(
        size: CGSize,
        safeAreaInsets: EdgeInsets,
        layoutMargins: EdgeInsets,
        colorScheme: ColorScheme,
        scale: CGFloat = Self.scale,
        locale: Locale = Locale(identifier: SnapshotRenderDefaults.localeIdentifier),
        dynamicTypeSize: DynamicTypeSize = .medium,
        layoutDirection: LayoutDirection = .leftToRight
    ) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.layoutMargins = layoutMargins
        self.colorScheme = colorScheme
        self.scale = scale
        self.locale = locale
        self.dynamicTypeSize = dynamicTypeSize
        self.layoutDirection = layoutDirection
    }
    
    public static func iPhone(style colorScheme: ColorScheme) -> SUISnapshotConfiguration {
        return SUISnapshotConfiguration(
            size: Self.size,
            safeAreaInsets: EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0),
            layoutMargins: EdgeInsets(top: 55, leading: 8, bottom: 42, trailing: 8),
            colorScheme: colorScheme
        )
    }
}

extension ColorScheme {
    #if canImport(UIKit)
    public var style: UIUserInterfaceStyle {
        switch self {
        case .light: .light
        case .dark: .dark
        default: .light
        }
    }
    #endif
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshotEnvironment(configuration: SUISnapshotConfiguration) -> some View {
        self
            .colorScheme(configuration.colorScheme)
            .environment(\.displayScale, configuration.scale)
            .environment(\.locale, configuration.locale)
            .environment(\.layoutDirection, configuration.layoutDirection)
            .dynamicTypeSize(configuration.dynamicTypeSize)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
    }

    @ViewBuilder
    func build(configuration: SUISnapshotConfiguration, background: Color? = nil) -> some View {
        snapshotEnvironment(configuration: configuration)
            .frame(width: configuration.size.width, height: configuration.size.height)
//            .safeAreaPadding(configuration.safeAreaInsets)
            .contentMargins(.all, configuration.layoutMargins, for: .automatic)
            .background(background ?? (configuration.colorScheme == .dark ? Color.black : Color.white))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot(
        size: CGSize = SUISnapshotConfiguration.size,
        scale: CGFloat = SUISnapshotConfiguration.scale
    ) -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {
            renderer.allowedDynamicRange = .high
        }
        renderer.proposedSize = .init(size)
        
        // Use UIGraphicsImageRenderer for proper anti-aliasing
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.preferredRange = .standard // SwftUI not passing with extended
        format.opaque = false
        
        let uiKitRenderer = UIGraphicsImageRenderer(size: size, format: format)
        return uiKitRenderer.image { context in
            // Flip the coordinate system to match ImageRenderer's top-left origin
            context.cgContext.translateBy(x: 0, y: size.height)
            context.cgContext.scaleBy(x: 1, y: -1)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB() // Default sRGB color space (IEC61966-2.1)
            context.cgContext.setFillColorSpace(colorSpace)
            
            renderer.render { size, render in
                render(context.cgContext)
            }
        }
//        return renderer.uiImage
    }
}

#if canImport(UIKit)
@available(iOS 17.0, *)
private extension SUISnapshotConfiguration {
    var uiKitSnapshotConfiguration: SnapshotConfiguration {
        let defaultConfiguration = SnapshotConfiguration.iPhone(
            style: colorScheme.style,
            contentSize: dynamicTypeSize.uiContentSizeCategory,
            displayScale: scale
        )
        return SnapshotConfiguration(
            size: size,
            safeAreaInsets: UIEdgeInsets(
                top: safeAreaInsets.top,
                left: safeAreaInsets.leading,
                bottom: safeAreaInsets.bottom,
                right: safeAreaInsets.trailing
            ),
            layoutMargins: UIEdgeInsets(
                top: layoutMargins.top,
                left: layoutMargins.leading,
                bottom: layoutMargins.bottom,
                right: layoutMargins.trailing
            ),
            traitCollection: defaultConfiguration.traitCollection
        )
    }
}

@available(iOS 17.0, *)
private extension DynamicTypeSize {
    var uiContentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        default: SnapshotRenderDefaults.contentSizeCategory
        }
    }
}
#endif

#endif
