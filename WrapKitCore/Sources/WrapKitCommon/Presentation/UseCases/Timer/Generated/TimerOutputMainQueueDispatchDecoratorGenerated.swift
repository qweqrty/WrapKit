// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

extension TimerOutput {
    public var weakReferenced: any TimerOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: TimerOutput where T: TimerOutput {

    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        dispatch { [weak self] in
            self?.decoratee.display(timerInput: timerInput, secondsRemaining: secondsRemaining)
        }
    }

}

extension WeakRefVirtualProxy: TimerOutput where T: TimerOutput {

    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        object?.display(timerInput: timerInput, secondsRemaining: secondsRemaining)
    }

}
#endif
