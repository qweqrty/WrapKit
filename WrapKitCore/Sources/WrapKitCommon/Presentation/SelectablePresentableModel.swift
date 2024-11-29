//
//  Selectable.swift
//  WrapKit
//
//  Created by Stanislav Li on 3/6/24.
//

import Foundation

public struct SelectablePresentableModel<Model>: HashableWithReflection {
    public var isSelected: InMemoryStorage<Bool>
    public var model: Model
    
    public init(
        isSelected: Bool = false,
        model: Model
    ) {
        self.isSelected = InMemoryStorage(model: isSelected)
        self.model = model
    }
    
    public init(model: Model) {
        self.isSelected = InMemoryStorage(model: nil)
        self.model = model
    }
    
    public init(
        isSelected: InMemoryStorage<Bool>,
        model: Model
    ) {
        self.isSelected = isSelected
        self.model = model
    }
}
