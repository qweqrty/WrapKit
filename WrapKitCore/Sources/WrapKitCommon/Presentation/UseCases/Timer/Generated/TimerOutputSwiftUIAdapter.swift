// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Foundation)
import Foundation
#endif
public class TimerOutputSwiftUIAdapter: ObservableObject, TimerOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayTimerInputSecondsRemainingState: DisplayTimerInputSecondsRemainingState? = nil
    public struct DisplayTimerInputSecondsRemainingState {
        public let timerInput: TimerInput
        public let secondsRemaining: Int?
    }
    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        displayTimerInputSecondsRemainingState = .init(
            timerInput: timerInput, 
            secondsRemaining: secondsRemaining
        )
    }
}
