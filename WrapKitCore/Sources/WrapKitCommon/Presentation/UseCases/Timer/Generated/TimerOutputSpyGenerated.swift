// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif

public final class TimerOutputSpy: TimerOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(timerInput: TimerInput, secondsRemaining: Int?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayTimerInput: [TimerInput] = []
    private(set) var capturedDisplaySecondsRemaining: [Int?] = []


    // MARK: - TimerOutput methods
    public func display(timerInput: TimerInput, secondsRemaining: Int?) {
        capturedDisplayTimerInput.append(timerInput)
        capturedDisplaySecondsRemaining.append(secondsRemaining)
        messages.append(.display(timerInput: timerInput, secondsRemaining: secondsRemaining))
    }

    // MARK: - Properties
}
