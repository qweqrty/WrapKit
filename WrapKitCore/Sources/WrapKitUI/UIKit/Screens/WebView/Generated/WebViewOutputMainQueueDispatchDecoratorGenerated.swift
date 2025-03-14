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

extension WebViewOutput {
    public var mainQueueDispatched: any WebViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: WebViewOutput where T: WebViewOutput {

    public func display(url: URL) {
        dispatch { [weak self] in
            self?.decoratee.display(url: url)
        }
    }
    public func display(refreshModel: WebViewStyle.Refresh) {
        dispatch { [weak self] in
            self?.decoratee.display(refreshModel: refreshModel)
        }
    }
    public func display(backgroundColor: Color?) {
        dispatch { [weak self] in
            self?.decoratee.display(backgroundColor: backgroundColor)
        }
    }
    public func display(isProgressBarNeeded: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isProgressBarNeeded: isProgressBarNeeded)
        }
    }

}
#endif
