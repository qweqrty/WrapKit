//
//  LoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol LoadingOutput: AnyObject {
    var isLoading: Bool { get }
    
    func display(isLoading: Bool)
}

extension LoadingOutput {
    public var weakReferenced: LoadingOutput {
        return WeakRefVirtualProxy(self)
    }
    
    public var mainQueueDispatched: LoadingOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}
