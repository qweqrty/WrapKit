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
