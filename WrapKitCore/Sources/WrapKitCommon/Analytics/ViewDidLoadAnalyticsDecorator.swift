//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

public extension LifeCycleViewOutput {
    func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) -> LifeCycleViewOutput {
        return ViewDidLoadAnalyticsDecorator(wrapped: self, analytics: analytics, eventName: eventName, parameters: parameters)
    }
}

public class ViewDidLoadAnalyticsDecorator: LifeCycleViewOutput {
    private let wrapped: LifeCycleViewOutput
    private let analytics: AnalyticsTracker
    private let eventName: String
    private let parameters: [String: Any]

    public init(
        wrapped: LifeCycleViewOutput,
        analytics: AnalyticsTracker,
        eventName: String,
        parameters: [String: Any]
    ) {
        self.wrapped = wrapped
        self.analytics = analytics
        self.eventName = eventName
        self.parameters = parameters
    }
    
    public func viewDidLoad() {
        wrapped.viewDidLoad()
        analytics.log(eventName: eventName, parameters: parameters)
    }

    // Forward other lifecycle methods without tracking
    public func viewWillAppear() {
        wrapped.viewWillAppear()
    }

    public func viewWillDisappear() {
        wrapped.viewWillDisappear()
    }

    public func viewDidAppear() {
        wrapped.viewDidAppear()
    }

    public func viewDidDisappear() {
        wrapped.viewDidDisappear()
    }
}
