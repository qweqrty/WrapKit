//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

public extension LifeCycleViewInput {
    func withAnalytics(screenName: String, analytics: AnalyticsTracker) -> LifeCycleViewInput {
        return ViewDidLoadAnalyticsDecorator(wrapped: self, analytics: analytics, screenName: screenName)
    }
}

public class ViewDidLoadAnalyticsDecorator: LifeCycleViewInput {
    private let wrapped: LifeCycleViewInput
    private let analytics: AnalyticsTracker
    private let screenName: String

    public init(wrapped: LifeCycleViewInput, analytics: AnalyticsTracker, screenName: String) {
        self.wrapped = wrapped
        self.analytics = analytics
        self.screenName = screenName
    }

    public func viewDidLoad() {
        wrapped.viewDidLoad()
        analytics.log(screenName: screenName)
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
