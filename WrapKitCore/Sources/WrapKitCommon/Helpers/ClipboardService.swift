import Foundation

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public protocol ClipboardService {
    func copy(_ string: String)
}

public final class SystemClipboardService: ClipboardService {
    public init() {}

    public func copy(_ string: String) {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        UIPasteboard.general.string = string
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #else
        _ = string
        #endif
    }
}
