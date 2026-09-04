#if os(iOS) && canImport(SwiftUI)
import UIKit

public protocol SwiftUISnapshotSource {
    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage
}
#endif
