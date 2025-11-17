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

extension CommonToastOutput {
    public var weakReferenced: any CommonToastOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: CommonToastOutput where T: CommonToastOutput {

    public func display(_ toast: CommonToast) {
        object?.display(toast)
    }
    public func hide() {
        object?.hide()
    }

}
#endif
