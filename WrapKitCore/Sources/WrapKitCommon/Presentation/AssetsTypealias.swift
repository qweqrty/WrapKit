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

#endif

public enum ImageEnum: HashableWithReflection {
    case asset(Image?)
    case data(Data?)
    case url(URL?, URL? = nil) // Light, Dark
    case urlString(String?, String? = nil) // Light, Dark
}
