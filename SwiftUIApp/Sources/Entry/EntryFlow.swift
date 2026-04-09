//
//  EntryFlow.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import Combine
import SwiftUI

public protocol EntryFlow: AnyObject {
    func showSplash()
}

public class EntrySwiftUIFlow: ObservableObject, EntryFlow {
    enum Screen {
        case splash
    }

    @Published var currentScreen: Screen

    public init() {
        currentScreen = .splash
    }

    public func showSplash() {
        currentScreen = .splash
    }
}
