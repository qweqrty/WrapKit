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

extension RefreshControlOutput {
    public var weakReferenced: any RefreshControlOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: RefreshControlOutput where T: RefreshControlOutput {

    public func display(model: RefreshControlPresentableModel?) {
        object?.display(model: model)
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        object?.display(style: style)
    }
    public func display(onRefresh: (() -> Void)?) {
        object?.display(onRefresh: onRefresh)
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        object?.display(appendingOnRefresh: appendingOnRefresh)
    }
    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }

    public var onRefresh: [(() -> Void)?]? {
        get { return object?.onRefresh }
        set { object?.onRefresh = newValue }
    }
}
#endif
