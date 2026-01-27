//
//  ProcessInfo+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/1/26.
//

import Foundation
    
public extension ProcessInfo {
    static let isUITest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
