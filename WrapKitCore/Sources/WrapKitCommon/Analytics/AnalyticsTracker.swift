//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/2/25.
//

import Foundation

public protocol AnalyticsTracker {
    func trackScreenView(screenName: String)
    // Add other tracking methods as needed
}
