// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif
import WrapKit

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
    public private(set) var capturedViewDidLoad: [Void] = []
    public private(set) var capturedViewWillAppear: [Void] = []
    public private(set) var capturedViewWillDisappear: [Void] = []
    public private(set) var capturedViewDidAppear: [Void] = []
    public private(set) var capturedViewDidDisappear: [Void] = []
    public private(set) var capturedViewDidLayoutSubviews: [Void] = []
    public private(set) var capturedComposedOutput: [(LifeCycleViewOutput)] = []
    public private(set) var capturedWithAnalyticsEventNameParametersAnalytics: [(String, [String: Any], AnalyticsTracker)] = []

    // MARK: - LifeCycleViewOutput methods
    public func viewDidLoad() {
        capturedViewDidLoad.append(())
        messages.append(.viewDidLoad)
    }
    public func viewWillAppear() {
        capturedViewWillAppear.append(())
        messages.append(.viewWillAppear)
    }
    public func viewWillDisappear() {
        capturedViewWillDisappear.append(())
        messages.append(.viewWillDisappear)
    }
    public func viewDidAppear() {
        capturedViewDidAppear.append(())
        messages.append(.viewDidAppear)
    }
    public func viewDidDisappear() {
        capturedViewDidDisappear.append(())
        messages.append(.viewDidDisappear)
    }
    public func viewDidLayoutSubviews() {
        capturedViewDidLayoutSubviews.append(())
        messages.append(.viewDidLayoutSubviews)
    }
    public func composed(with output: LifeCycleViewOutput) {
        capturedComposedOutput.append((output))
        messages.append(.composedOutput(with: output))
    }
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        capturedWithAnalyticsEventNameParametersAnalytics.append((eventName, parameters, analytics))
        messages.append(.withAnalyticsEventName(eventName: eventName, parameters: parameters, analytics: analytics))
    }

    // MARK: - Properties
}
