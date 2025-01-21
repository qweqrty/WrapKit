import SwiftUI

enum UserInterfaceStyle {
    case light
    case dark
    case unspecified
}

extension UserInterfaceStyle {
    /// Returns the current user interface style in a platform-agnostic way
    static var current: UserInterfaceStyle {
        #if canImport(UIKit)
        // iOS and tvOS
        if #available(iOS 13.0, tvOS 13.0, *) {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first {
                switch window.traitCollection.userInterfaceStyle {
                case .dark: return .dark
                case .light: return .light
                default: return .unspecified
                }
            }
        } else {
            // iOS 12 and earlier fallback
            if UIScreen.main.brightness < 0.5 {
                return .dark
            } else {
                return .light
            }
        }
        return .unspecified
        #elseif canImport(AppKit)
        // macOS
        if NSApp.effectiveAppearance.name == .darkAqua {
            return .dark
        } else if NSApp.effectiveAppearance.name == .aqua {
            return .light
        } else {
            return .unspecified
        }
        #elseif canImport(WatchKit)
        // watchOS
        if #available(watchOS 6.0, *) {
            if let isDarkMode = WKExtension.shared().rootInterfaceController?
                .traitCollection.userInterfaceStyle == .dark {
                return isDarkMode ? .dark : .light
            }
        }
        return .unspecified
        #else
        // Unsupported platforms
        return .unspecified
        #endif
    }
}

