//
//  EntryFactory.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import SwiftUI
import WrapKit
import Combine

public protocol EntryViewFactory<T> {
    associatedtype T
    func makeSplashScreen() -> T
}

struct EntryViewSwiftUIFactory: EntryViewFactory {
    typealias T = AnyView
    
    func makeSplashScreen() -> AnyView {
        let presenter = SplashPresenter()
        let adapter = TextOutputSwiftUIAdapter()
        let view = SplashContentView(
            lifeCycleOutput: presenter,
            ApplicationLifecycleOutput: presenter,
            adapter: adapter
        )
        presenter.textOutput = adapter
            .weakReferenced
            .mainQueueDispatched
        return AnyView(view)
    }
}
