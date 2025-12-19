// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class TimerOutputSpy: TimerOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayTimerInput(timerInput: TimerInput, secondsRemaining: Int?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayTimerInput: [TimerInput] = []
    public private(set) var capturedDisplaySecondsRemaining: [Int?] = []


    // MARK: - TimerOutput methods
    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        capturedDisplayTimerInput.append(timerInput)
        capturedDisplaySecondsRemaining.append(secondsRemaining)
        messages.append(.displayTimerInput(timerInput: timerInput, secondsRemaining: secondsRemaining))
    }

    // MARK: - Properties
}
