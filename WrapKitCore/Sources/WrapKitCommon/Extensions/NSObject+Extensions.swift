//
//  NSObject+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension NSObject {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
