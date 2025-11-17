// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension SegmentedControlOutput {
    public var weakReferenced: any SegmentedControlOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: SegmentedControlOutput where T: SegmentedControlOutput {

    public func display(appearence: SegmentedControlAppearance) {
        object?.display(appearence: appearence)
    }
    public func display(segments: [SegmentControlModel]) {
        object?.display(segments: segments)
    }

}
#endif
