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

extension TimerOutput {
    public var mainQueueDispatched: any TimerOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TimerOutput where T: TimerOutput {

    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        dispatch { [weak self] in
            self?.decoratee.display(timerInput: timerInput, secondsRemaining: secondsRemaining)
        }
    }

}
#endif
