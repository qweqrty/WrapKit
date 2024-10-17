//
//  CommonLoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol CommonLoadingOutput: AnyObject {
    var isLoading: Bool { get }
    
    func display(isLoading: Bool)
}

extension CommonLoadingOutput {
    public var weakReferenced: CommonLoadingOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: CommonLoadingOutput where T: CommonLoadingOutput {
    public var isLoading: Bool { object?.isLoading == true }
    
    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

public final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
}
