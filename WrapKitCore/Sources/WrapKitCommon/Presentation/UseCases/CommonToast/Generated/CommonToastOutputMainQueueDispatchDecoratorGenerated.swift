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

extension CommonToastOutput {
    public var mainQueueDispatched: any CommonToastOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: CommonToastOutput where T: CommonToastOutput {

    public func display(_ toast: CommonToast) {
        dispatch { [weak self] in
            self?.decoratee.display(toast)
        }
    }

}
#endif
