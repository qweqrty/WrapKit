//
//  Storage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation

public protocol Storage<Model>: Hashable {
    associatedtype Model
    typealias Observer = ((Model?) -> Void)
    
    func addObserver(for client: AnyObject, observer: @escaping Observer)
    
    func get() -> Model?
    
    func set(model: Model?, completion: ((Bool) -> Void)?)
    
    func clear(completion: ((Bool) -> Void)?)
}
