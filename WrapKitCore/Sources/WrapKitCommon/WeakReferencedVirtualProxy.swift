//
//  WeakRefVirtualProxy.swift
//
//
//  Created by Stanislav Li on 17/10/24.
//

import Foundation

public final class WeakRefVirtualProxy<T: AnyObject> {
    public weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: CommonLoadingOutput where T: CommonLoadingOutput {
    public var isLoading: Bool { object?.isLoading == true }
    
    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

extension WeakRefVirtualProxy: SelectionOutput where T: SelectionOutput {
    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
        object?.display(items: items, selectedCountTitle: selectedCountTitle)
    }
    
    public func display(title: String?) {
        object?.display(title: title)
    }
    
    public func display(shouldShowSearchBar: Bool) {
        object?.display(shouldShowSearchBar: shouldShowSearchBar)
    }
    
    public func display(canReset: Bool) {
        object?.display(canReset: canReset)
    }
    
}