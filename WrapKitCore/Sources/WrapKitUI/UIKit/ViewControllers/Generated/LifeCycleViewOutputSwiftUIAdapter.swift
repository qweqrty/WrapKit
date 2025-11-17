// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(UIKit)
import UIKit
#endif
public class LifeCycleViewOutputSwiftUIAdapter: ObservableObject, LifeCycleViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var viewDidLoadState: ViewDidLoadState? = nil
    public struct ViewDidLoadState {
    }
    public func viewDidLoad() {
        viewDidLoadState = .init(
        )
    }
    @Published public var viewWillAppearState: ViewWillAppearState? = nil
    public struct ViewWillAppearState {
    }
    public func viewWillAppear() {
        viewWillAppearState = .init(
        )
    }
    @Published public var viewWillDisappearState: ViewWillDisappearState? = nil
    public struct ViewWillDisappearState {
    }
    public func viewWillDisappear() {
        viewWillDisappearState = .init(
        )
    }
    @Published public var viewDidAppearState: ViewDidAppearState? = nil
    public struct ViewDidAppearState {
    }
    public func viewDidAppear() {
        viewDidAppearState = .init(
        )
    }
    @Published public var viewDidDisappearState: ViewDidDisappearState? = nil
    public struct ViewDidDisappearState {
    }
    public func viewDidDisappear() {
        viewDidDisappearState = .init(
        )
    }
    @Published public var viewDidLayoutSubviewsState: ViewDidLayoutSubviewsState? = nil
    public struct ViewDidLayoutSubviewsState {
    }
    public func viewDidLayoutSubviews() {
        viewDidLayoutSubviewsState = .init(
        )
    }
    @Published public var composedOutputState: ComposedOutputState? = nil
    public struct ComposedOutputState {
        public let output: LifeCycleViewOutput
    }
    public func composed(with output: LifeCycleViewOutput) {
        composedOutputState = .init(
            output: output
        )
    }
    @Published public var withAnalyticsEventNameParametersAnalyticsState: WithAnalyticsEventNameParametersAnalyticsState? = nil
    public struct WithAnalyticsEventNameParametersAnalyticsState {
        public let eventName: String
        public let parameters: [String: Any]
        public let analytics: AnalyticsTracker
    }
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        withAnalyticsEventNameParametersAnalyticsState = .init(
            eventName: eventName, 
            parameters: parameters, 
            analytics: analytics
        )
    }
}
