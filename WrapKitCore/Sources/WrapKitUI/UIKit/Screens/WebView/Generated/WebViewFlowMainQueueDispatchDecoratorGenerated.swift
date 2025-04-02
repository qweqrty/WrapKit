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

extension WebViewFlow {
    public var mainQueueDispatched: any WebViewFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: WebViewFlow where T: WebViewFlow {

    public func navigateToWebView(title: String?, url: URL, style: WebViewStyle, navigationPolicy: WebViewNavigationPolicy?) {
        dispatch { [weak self] in
            self?.decoratee.navigateToWebView(title: title, url: url, style: style, navigationPolicy: navigationPolicy)
        }
    }
    public func navigateBack() {
        dispatch { [weak self] in
            self?.decoratee.navigateBack()
        }
    }

}
#endif
