// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension ProgressBarOutput {
    public var mainQueueDispatched: any ProgressBarOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension ProgressBarOutput {
    public var weakReferenced: any ProgressBarOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: ProgressBarOutput where T: ProgressBarOutput {

    public func display(model: ProgressBarPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(progress: CGFloat) {
        dispatch { [weak self] in
            self?.decoratee.display(progress: progress)
        }
    }
    public func display(style: ProgressBarStyle?) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }

}

extension WeakRefVirtualProxy: ProgressBarOutput where T: ProgressBarOutput {

    public func display(model: ProgressBarPresentableModel?) {
        object?.display(model: model)
    }
    public func display(progress: CGFloat) {
        object?.display(progress: progress)
    }
    public func display(style: ProgressBarStyle?) {
        object?.display(style: style)
    }

}

#endif
