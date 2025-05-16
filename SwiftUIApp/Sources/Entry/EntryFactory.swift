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
        let contentView = SplashContentView(
            lifeCycleOutput: presenter,
            applicationLifecycleOutput: presenter
        )
        presenter.textOutput = contentView
            .adapter
            .weakReferenced
            .mainQueueDispatched
        return AnyView(contentView)
    }
}
