//
//  EntryFactory.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import SwiftUI

public protocol EntryViewFactory<T> {
    associatedtype T
    func makeCatalogScreen() -> T
}

struct EntryViewSwiftUIFactory: EntryViewFactory {
    typealias T = AnyView

    let initialDestination: CatalogOutputDestination?

    init(initialDestination: CatalogOutputDestination? = nil) {
        self.initialDestination = initialDestination
    }
    
    func makeCatalogScreen() -> AnyView {
        ComponentCatalogFactory().makeCatalog(initialDestination: initialDestination)
    }
}
