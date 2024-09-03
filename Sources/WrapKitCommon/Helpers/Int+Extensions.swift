//
//  Int+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/5/24.
//

import Foundation

public extension Int {
    func asSecondsToTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if self >= 3600 {
            formatter.allowedUnits = [
                .hour,
                .minute,
                .second
            ]
        } else {
            formatter.allowedUnits = [
                .minute,
                .second
            ]
        }
        
        return formatter.string(from: TimeInterval(self)) ?? "more than a day"
    }
}
