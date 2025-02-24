//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

/// Protocol defining the interface for analytics tracking.
public protocol AnalyticsTracker {
    /// Tracks a screen view event.
    /// - Parameter screenName: The name of the screen being tracked.
    func log(screenName: String)
}

/// A simple AnalyticsTracker implementation that prints tracking events to the console.
public final class ConsoleAnalyticsTracker: AnalyticsTracker {
    /// Tracks a screen view event by printing to the console.
    /// - Parameter screenName: The name of the screen being tracked.
    public func log(screenName: String) {
        print("[Analytics] Tracked screen view: \(screenName)")
    }
}

public final class CompositeAnalyticsTracker: AnalyticsTracker {
    private let trackers: [AnalyticsTracker]
    
    /// Initializes the composite with an array of trackers.
    /// - Parameter trackers: The trackers to compose.
    public init(trackers: [AnalyticsTracker]) {
        self.trackers = trackers
    }
    
    /// Tracks a screen view event by calling the same method on all composed trackers.
    /// - Parameter screenName: The name of the screen being tracked.
    public func log(screenName: String) {
        trackers.forEach { $0.log(screenName: screenName) }
    }
}

public extension AnalyticsTracker {
    /// Composes this tracker with another tracker.
    /// - Parameter other: The other tracker to compose with.
    /// - Returns: A new AnalyticsTracker that combines both.
    func composed(with other: AnalyticsTracker) -> AnalyticsTracker {
        return CompositeAnalyticsTracker(trackers: [self, other])
    }
}
