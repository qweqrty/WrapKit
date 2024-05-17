//
//  AppLifecycle.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/5/24.
//

import Foundation

public protocol DidEnterBacgkroundInput {
    func didEnterBackground()
}

public protocol WillEnterForegoundInput {
    func willEnterForeground()
}
