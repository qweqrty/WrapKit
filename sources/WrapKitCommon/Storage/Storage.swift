//
//  Storage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation

public protocol Storage<Model> {
    associatedtype Model
    typealias Observer = ((Model?) -> Void)
    
    func addObserver(for client: AnyObject, observer: @escaping Observer)
    
    func get() -> Model?
    
    @discardableResult
    func set(_ model: Model?) -> Bool
    
    @discardableResult
    func clear() -> Bool
}
