#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot(for configuration: SUISnapshotConfiguration, useUIKit: Bool = false) -> UIImage {
        let view = self.build(configuration: configuration)
#if canImport(UIKit)
        guard useUIKit else { return view.snapshot() }
        let viewController = UIHostingController(rootView: view.ignoresSafeArea(.all))
        viewController.view.backgroundColor = .clear
        return viewController.snapshot(for: .iPhone(style: configuration.colorScheme.style))
#else
        return view.snapshot()
#endif
    }
}
//let maxSize = CGSize(width: 0.0, height: 0.0)
//            config.size = hostingController.sizeThatFits(in: maxSize)

public struct SUISnapshotConfiguration {
    public static let size = CGSize(width: 1170 / UIScreen.main.scale, height: 2532 / UIScreen.main.scale)
    public static let sizePx = CGSize(width: 1170, height: 2532)
    
    public let size: CGSize
    public let safeAreaInsets: EdgeInsets
    public let layoutMargins: EdgeInsets
    public let colorScheme: ColorScheme
    
    public init(size: CGSize, safeAreaInsets: EdgeInsets, layoutMargins: EdgeInsets, colorScheme: ColorScheme) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.layoutMargins = layoutMargins
        self.colorScheme = colorScheme
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
    @ViewBuilder
    func build(configuration: SUISnapshotConfiguration) -> some View {
        self
            .frame(width: configuration.size.width, height: configuration.size.height)
//            .safeAreaPadding(configuration.safeAreaInsets)
            .contentMargins(.all, configuration.layoutMargins, for: .automatic)
            .colorScheme(configuration.colorScheme)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot() -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
        if #available(iOS 26.0, *) {
            renderer.allowedDynamicRange = .standard
        }
        renderer.proposedSize = .init(SUISnapshotConfiguration.size)
        
        renderer.render { size, contextClosure in
//            if #available(iOS 26.0, *), let context = CGContext(width: Int(SUISnapshotConfiguration.sizePx.width), height: Int(SUISnapshotConfiguration.sizePx.height)) {
//                context.setShouldAntialias(true)
//                context.setAllowsAntialiasing(true)
//                context.interpolationQuality = .high
//                let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB() // Default sRGB color space (IEC61966-2.1)
//                context.setFillColorSpace(colorSpace)
//                contextClosure(context)
//            }
        }
        return renderer.uiImage ?? UIImage()
    }
}

#endif
