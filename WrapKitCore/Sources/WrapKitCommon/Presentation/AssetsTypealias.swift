#if canImport(SwiftUI)
import SwiftUI
#endif

#if os(macOS)
import AppKit
public typealias Image = NSImage
public typealias Color = NSColor
public typealias Font = NSFont

@available(macOS 10.15, *)
public typealias SwiftUIColor = SwiftUI.Color
@available(macOS 10.15, *)
public typealias SwiftUIImage = SwiftUI.Image
@available(macOS 10.15, *)
public typealias SwiftUIFont = SwiftUI.Font

#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias Image = UIImage
public typealias Color = UIColor
public typealias Font = UIFont

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias SwiftUIColor = SwiftUI.Color
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias SwiftUIImage = SwiftUI.Image
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias SwiftUIFont = SwiftUI.Font

public extension Color {
    static func dynamicColor(light: Color, dark: Color) -> Color {
    guard #available(iOS 13.0, *) else { return light }
    return UIColor { traits in
      traits.userInterfaceStyle == .dark ? dark : light
    }
  }
}
#endif

public enum ImageEnum: HashableWithReflection {
    case asset(Image?)
    case data(Data?)
    case url(URL?, URL? = nil) // Light, Dark
    case urlString(String?, String? = nil) // Light, Dark
}

public extension IndexPath {
    var unifiedIndex: Int {
        #if os(macOS)
        return self.item
        #else
        return self.row
        #endif
    }
}

public enum FontFactory {
    public static func italic(size: CGFloat) -> Font {
        #if os(iOS)
        return UIFont.italicSystemFont(ofSize: size)
        #elseif os(macOS)
        let systemFont = NSFont.systemFont(ofSize: size)
        return NSFontManager.shared.convert(systemFont, toHaveTrait: .italicFontMask)
        #endif
    }

    public static func bold(size: CGFloat) -> Font {
        #if os(iOS)
        return UIFont.boldSystemFont(ofSize: size)
        #elseif os(macOS)
        let systemFont = NSFont.systemFont(ofSize: size)
        return NSFontManager.shared.convert(systemFont, toHaveTrait: .boldFontMask)
        #endif
    }

    public static func system(size: CGFloat, weight: CGFloat) -> Font {
        #if os(iOS)
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: weight))
        #elseif os(macOS)
        return NSFont.systemFont(ofSize: size)
        #endif
    }
}

public enum ImageFactory {
    public static func systemImage(named name: String) -> Image? {
        #if canImport(UIKit)
        return UIImage(systemName: name)
        #elseif canImport(AppKit)
        NSImage(systemSymbolName: name, accessibilityDescription: nil)
        #endif
    }
}
