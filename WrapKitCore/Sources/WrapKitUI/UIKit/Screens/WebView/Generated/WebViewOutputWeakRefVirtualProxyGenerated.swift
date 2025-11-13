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

extension WebViewOutput {
    public var weakReferenced: any WebViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: WebViewOutput where T: WebViewOutput {

    public func display(url: URL) {
        object?.display(url: url)
    }
    public func display(refreshModel: WebViewStyle.Refresh) {
        object?.display(refreshModel: refreshModel)
    }
    public func display(backgroundColor: Color?) {
        object?.display(backgroundColor: backgroundColor)
    }
    public func display(isProgressBarNeeded: Bool) {
        object?.display(isProgressBarNeeded: isProgressBarNeeded)
    }

}
#endif
