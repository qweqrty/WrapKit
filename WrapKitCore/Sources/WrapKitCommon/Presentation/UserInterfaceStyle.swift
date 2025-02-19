import SwiftUI

public enum UserInterfaceStyle {
    case light
    case dark
    case unspecified
}

extension UserInterfaceStyle {
    /// Returns the current user interface style in a platform-agnostic way
    public static var current: UserInterfaceStyle {
        if #available(macOS 11.0, *) {
#if canImport(UIKit)
            // iOS and tvOS
            if #available(iOS 13.0, tvOS 13.0, *) {
                // Get the first active window
                if let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    
                    switch window.traitCollection.userInterfaceStyle {
                    case .dark: return .dark
                    case .light: return .light
                    default: return .unspecified
                    }
                }
            } else {
                // iOS 12 and earlier fallback (using screen brightness)
                if UIScreen.main.brightness < 0.5 {
                    return .dark
                } else {
                    return .light
                }
            }
            return .unspecified
            
#elseif canImport(AppKit)
            // macOS
            if #available(macOS 10.14, *) {
                let appearance = NSAppearance.currentDrawing().bestMatch(from: [.darkAqua, .aqua])
                switch appearance {
                case .darkAqua: return .dark
                case .aqua: return .light
                default: return .unspecified
                }
            } else {
                return .light // macOS before Mojave only had light mode
            }
            
#elseif canImport(WatchKit)
            // watchOS
            if #available(watchOS 6.0, *) {
                // No direct API; fallback heuristic:
                if WKInterfaceDevice.current().screenScale < 1.5 {
                    return .dark // Older watches with OLED screens likely use dark mode by default
                } else {
                    return .light
                }
            }
            return .unspecified
            
#else
            // Unsupported platforms
            return .unspecified
#endif
        } else {
            return .unspecified
        }
    }
}
