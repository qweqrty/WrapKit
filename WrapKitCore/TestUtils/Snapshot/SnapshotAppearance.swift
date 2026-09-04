#if os(iOS)
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

public enum SnapshotAppearance: CaseIterable, Hashable {
    case light
    case dark
}

public extension SnapshotAppearance {
    var uiKitConfiguration: SnapshotConfiguration {
        .iPhone(style: userInterfaceStyle)
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

#if canImport(SwiftUI)
    @available(iOS 17.0, *)
    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
#endif
}
#endif
