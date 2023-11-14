//
//  String+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension String {
    func toDate(dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}
