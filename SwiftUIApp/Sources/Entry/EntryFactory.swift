//
//  EntryFactory.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import SwiftUI
import Combine

public protocol EntryViewFactory<T> {
    associatedtype T
    func makeSplashScreen() -> T
}

struct EntryViewSwiftUIFactory: EntryViewFactory {
    typealias T = AnyView
    
    func makeSplashScreen() -> AnyView {
        let presenter = SplashPresenter()
        let view = SplashContentView(
            lifeCycleOutput: presenter,
            ApplicationLifecycleOutput: presenter
        )
        return AnyView(view)
    }
}
