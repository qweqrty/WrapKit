// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
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

extension StackViewOutput {
    public var weakReferenced: any StackViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: StackViewOutput where T: StackViewOutput {

    public func display(model: StackViewPresentableModel) {
        object?.display(model: model)
    }
    public func display(spacing: CGFloat?) {
        object?.display(spacing: spacing)
    }
    public func display(axis: StackViewAxis) {
        object?.display(axis: axis)
    }
    public func display(distribution: StackViewDistribution) {
        object?.display(distribution: distribution)
    }
    public func display(alignment: StackViewAlignment) {
        object?.display(alignment: alignment)
    }
    public func display(layoutMargins: EdgeInsets) {
        object?.display(layoutMargins: layoutMargins)
    }

}
#endif
