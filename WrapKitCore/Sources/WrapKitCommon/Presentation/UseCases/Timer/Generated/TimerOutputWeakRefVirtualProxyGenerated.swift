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

extension TimerOutput {
    public var weakReferenced: any TimerOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TimerOutput where T: TimerOutput {

    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        object?.display(timerInput: timerInput, secondsRemaining: secondsRemaining)
    }

}
#endif
