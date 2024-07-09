//
//  SelectionPresenterModel.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public struct SelectionPresenterModel {
    public let title: String?
    public let isMultipleSelectionEnabled: Bool
    public let items: [SelectionType.SelectionCellPresentableModel]
    public let callback: ((SelectionType?) -> Void)?
    public let configuration: SelectionConfiguration
    
    public init(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        callback: ((SelectionType?) -> Void)?,
        configuration: SelectionConfiguration
    ) {
        self.title = title
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        self.items = items
        self.callback = callback
        self.configuration = configuration
    }
}

public enum SelectionType {
    public struct SelectionCellPresentableModel: HashableWithReflection {
        public let id: String
        public let title: String
        public let circleColor: String?
        public var isSelected: Bool
        public let trailingTitle: String?
        public let icon: String?
        public let configuration: SelectionConfiguration.Cell
        
        public init(
            id: String,
            title: String,
            circleColor: String? = nil,
            isSelected: Bool = false,
            trailingTitle: String? = nil,
            icon: String? = nil,
            configuration: SelectionConfiguration.Cell
        ) {
            self.id = id
            self.title = title
            self.circleColor = circleColor
            self.isSelected = isSelected
            self.icon = icon
            self.trailingTitle = trailingTitle
            self.configuration = configuration
        }
    }
    
    case singleSelection(SelectionCellPresentableModel)
    case multipleSelection([SelectionCellPresentableModel])
}
