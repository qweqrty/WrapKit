//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

/// Protocol defining the interface for analytics tracking.
public protocol AnalyticsTracker {
    /// Tracks an event with optional parameters.
    /// - Parameters:
    ///   - eventName: The name of the event being tracked.
    ///   - parameters: Additional event parameters.
    func log(eventName: String, parameters: [String: Any])
}

/// A simple AnalyticsTracker implementation that prints tracking events to the console.
public final class ConsoleAnalyticsTracker: AnalyticsTracker {
    public func log(eventName: String, parameters: [String: Any]) {
        print("Tracked event: \(eventName) with parameters: \(parameters)")
    }
}

/// A composite tracker that forwards events to multiple underlying trackers.
public final class CompositeAnalyticsTracker: AnalyticsTracker {
    private let trackers: [AnalyticsTracker]
    
    /// Initializes the composite with an array of trackers.
    /// - Parameter trackers: The trackers to compose.
    public init(trackers: [AnalyticsTracker]) {
        self.trackers = trackers
    }
    
    /// Tracks an event by delegating to all composed trackers.
    /// - Parameters:
    ///   - eventName: The name of the event being tracked.
    ///   - parameters: Additional event parameters.
    public func log(eventName: String, parameters: [String: Any] = [:]) {
        trackers.forEach { $0.log(eventName: eventName, parameters: parameters) }
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
