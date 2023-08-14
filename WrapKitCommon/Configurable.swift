//
//  Configurable.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol Configurable<Model>: AnyObject {
    associatedtype Model
    var model: Model? { get set }
}
