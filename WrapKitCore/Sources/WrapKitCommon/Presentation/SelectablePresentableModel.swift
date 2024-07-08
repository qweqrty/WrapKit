//
//  Selectable.swift
//  WrapKit
//
//  Created by Stanislav Li on 3/6/24.
//

import Foundation

public struct SelectablePresentableModel<Model> {
    public var isSelected: Bool
    public var model: Model
    
    public init(
        isSelected: Bool = false,
        model: Model
    ) {
        self.isSelected = isSelected
        self.model = model
    }
}
