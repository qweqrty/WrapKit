#if canImport(UIKit)
import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Values shared by the UIKit and SwiftUI snapshot renderers.
///
/// Keep these independent from the simulator's user settings so a snapshot has the same physical
/// size and environment locally and on CI.
public enum SnapshotRenderDefaults {
    public static let scale: CGFloat = 3
    public static let pixelSize = CGSize(width: 1170, height: 2532)
    public static let size = CGSize(
        width: pixelSize.width / scale,
        height: pixelSize.height / scale
    )
    public static let localeIdentifier = "en_US"
    public static let contentSizeCategory: UIContentSizeCategory = .medium
}

#if os(iOS)
public enum SnapshotAppearance: CaseIterable, Hashable {
    case light
    case dark
}

/// Maps only CI-supported simulator runtimes to committed snapshot origin names.
/// An unknown runtime must fail instead of silently reusing a visually incompatible baseline.
public enum SnapshotRuntime {
    public static func baselinePrefix(for version: OperatingSystemVersion) -> String? {
        switch (version.majorVersion, version.minorVersion) {
        case (18, 5):
            return "iOS18.5"
        case (26, 2):
            return "iOS26"
        default:
            return nil
        }
    }

    public static var currentBaselinePrefix: String? {
        baselinePrefix(for: ProcessInfo.processInfo.operatingSystemVersion)
    }
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
#endif
