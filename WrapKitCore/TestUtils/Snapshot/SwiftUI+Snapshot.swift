#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot(for configuration: SUISnapshotConfiguration) -> UIImage {
        let view = build(configuration: configuration)
//#if canImport(UIKit)
//        return UIHostingController(rootView: self).snapshot(for: .iPhone(style: configuration.colorScheme.style))
//#else
        return view.snapshot()
//#endif
    }
}

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
//        ZStack {
//            self
//        }
        self
        .frame(width: configuration.size.width, height: configuration.size.height)
//        .safeAreaPadding(configuration.safeAreaInsets)
        .contentMargins(.all, configuration.layoutMargins, for: .automatic)
        .colorScheme(configuration.colorScheme)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    func snapshot() -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
//        renderer.colorMode = .linear
        if #available(iOS 26.0, *) {
            renderer.allowedDynamicRange = .standard
        }
        renderer.render { size, contextClosure in
            if #available(iOS 26.0, *), let context = CGContext(width: Int(SUISnapshotConfiguration.sizePx.width), height: Int(SUISnapshotConfiguration.sizePx.height)) {
                contextClosure(context)
            }
        }

        return renderer.uiImage ?? UIImage()
    }
}

#endif
