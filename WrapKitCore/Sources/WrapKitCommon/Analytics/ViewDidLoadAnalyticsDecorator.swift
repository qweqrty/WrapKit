//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

public extension LifeCycleViewOutput {
    func withAnalytics(screenName: String, analytics: AnalyticsTracker) -> LifeCycleViewOutput {
        return ViewDidLoadAnalyticsDecorator(wrapped: self, analytics: analytics, screenName: screenName)
    }
}

public class ViewDidLoadAnalyticsDecorator: LifeCycleViewOutput {
    private let wrapped: LifeCycleViewOutput
    private let analytics: AnalyticsTracker
    private let screenName: String

    public init(wrapped: LifeCycleViewOutput, analytics: AnalyticsTracker, screenName: String) {
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
