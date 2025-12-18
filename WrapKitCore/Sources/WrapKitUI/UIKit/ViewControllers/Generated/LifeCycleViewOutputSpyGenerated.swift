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
    public private(set) var capturedComposedOutput: [LifeCycleViewOutput] = []
    public private(set) var capturedWithAnalyticsEventName: [String] = []
    public private(set) var capturedWithAnalyticsParameters: [[String: Any]] = []
    public private(set) var capturedWithAnalyticsAnalytics: [AnalyticsTracker] = []

    // MARK: - LifeCycleViewOutput methods
    public func viewDidLoad() {
        messages.append(.viewDidLoad)
    }
    public func viewWillAppear() {
        messages.append(.viewWillAppear)
    }
    public func viewWillDisappear() {
        messages.append(.viewWillDisappear)
    }
    public func viewDidAppear() {
        messages.append(.viewDidAppear)
    }
    public func viewDidDisappear() {
        messages.append(.viewDidDisappear)
    }
    public func viewDidLayoutSubviews() {
        messages.append(.viewDidLayoutSubviews)
    }
    public func composed(with output: LifeCycleViewOutput) {
        capturedComposedOutput.append(output)
        messages.append(.composedOutput(with: output))
    }
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        capturedWithAnalyticsEventName.append(eventName)
        capturedWithAnalyticsParameters.append(parameters)
        capturedWithAnalyticsAnalytics.append(analytics)
        messages.append(.withAnalyticsEventName(eventName: eventName, parameters: parameters, analytics: analytics))
    }

    // MARK: - Properties
}
