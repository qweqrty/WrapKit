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
    @Published var currentView: AnyView?
    private let factory: any EntryViewFactory<AnyView>

    public init(factory: any EntryViewFactory<AnyView>) {
        self.factory = factory
    }

    public func showSplash() {
        currentView = factory.makeSplashScreen()
    }
}
