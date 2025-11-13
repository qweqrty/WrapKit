// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
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
    public var mainQueueDispatched: any SegmentedControlOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: SegmentedControlOutput where T: SegmentedControlOutput {

    public func display(appearence: SegmentedControlAppearance) {
        dispatch { [weak self] in
            self?.decoratee.display(appearence: appearence)
        }
    }
    public func display(segments: [SegmentControlModel]) {
        dispatch { [weak self] in
            self?.decoratee.display(segments: segments)
        }
    }

}
#endif
