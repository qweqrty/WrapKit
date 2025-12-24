// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif

public final class LifeCycleViewOutputSpy: LifeCycleViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case viewDidLoad
        case viewWillAppear
        case viewWillDisappear
        case viewDidAppear
        case viewDidDisappear
        case viewDidLayoutSubviews
        case composedOutput(with: LifeCycleViewOutput)
        case withAnalyticsEventName(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedViewDidLoadCallCount = 0
    public private(set) var capturedViewWillAppearCallCount = 0
    public private(set) var capturedViewWillDisappearCallCount = 0
    public private(set) var capturedViewDidAppearCallCount = 0
    public private(set) var capturedViewDidDisappearCallCount = 0
    public private(set) var capturedViewDidLayoutSubviewsCallCount = 0
    public private(set) var capturedComposedOutput: [LifeCycleViewOutput] = []
    public private(set) var capturedWithAnalyticsEventName: [(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker)] = []


    // MARK: - LifeCycleViewOutput methods
    public func viewDidLoad() {
        capturedViewDidLoadCallCount += 1
        messages.append(.viewDidLoad)
    }
    public func viewWillAppear() {
        capturedViewWillAppearCallCount += 1
        messages.append(.viewWillAppear)
    }
    public func viewWillDisappear() {
        capturedViewWillDisappearCallCount += 1
        messages.append(.viewWillDisappear)
    }
    public func viewDidAppear() {
        capturedViewDidAppearCallCount += 1
        messages.append(.viewDidAppear)
    }
    public func viewDidDisappear() {
        capturedViewDidDisappearCallCount += 1
        messages.append(.viewDidDisappear)
    }
    public func viewDidLayoutSubviews() {
        capturedViewDidLayoutSubviewsCallCount += 1
        messages.append(.viewDidLayoutSubviews)
    }
    public func composed(with output: LifeCycleViewOutput) {
        capturedComposedOutput.append(output)
        messages.append(.composedOutput(with: output))
    }
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        capturedWithAnalyticsEventName.append((eventName: eventName, parameters: parameters, analytics: analytics))
        messages.append(.withAnalyticsEventName(eventName: eventName, parameters: parameters, analytics: analytics))
    }

    // MARK: - Properties
}
