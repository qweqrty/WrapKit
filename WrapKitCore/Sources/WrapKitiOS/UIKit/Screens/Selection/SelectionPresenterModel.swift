//
//  SelectionPresenterModel.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public struct SelectionPresenterModel {
    let title: String?
    let isMultipleSelectionEnabled: Bool
    let items: [SelectionType.SelectionCellPresentableModel]
    let callback: ((SelectionType?) -> Void)?
    
    public init(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        callback: ((SelectionType?) -> Void)?
    ) {
        self.title = title
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        self.items = items
        self.callback = callback
    }
}

public enum SelectionType {
    public struct SelectionCellPresentableModel: HashableWithReflection {
        let id: String
        let title: String
        let circleColor: String?
        var isSelected: Bool
        let trailingTitle: String?
        let icon: String?
        public init(
            id: String,
            title: String,
            circleColor: String? = nil,
            isSelected: Bool = false,
            trailingTitle: String? = nil,
            icon: String? = nil
        ) {
            self.id = id
            self.title = title
            self.circleColor = circleColor
            self.isSelected = isSelected
            self.icon = icon
            self.trailingTitle = trailingTitle
        }
    }
    
    case singleSelection(SelectionCellPresentableModel)
    case multipleSelection([SelectionCellPresentableModel])
}
