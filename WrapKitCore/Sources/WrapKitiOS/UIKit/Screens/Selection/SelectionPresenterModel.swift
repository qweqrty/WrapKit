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
        public let isSelected: any Storage<Bool>
        public let trailingTitle: String?
        public let leadingImage: ImageEnum?
        public let onPress: (() -> Void)?
        public let configuration: SelectionConfiguration.Cell
        
        public init(
            id: String,
            title: String,
            circleColor: String? = nil,
            isSelected: Bool = false,
            trailingTitle: String? = nil,
            leadingImage: ImageEnum? = nil,
            onPress: (() -> Void)? = nil,
            configuration: SelectionConfiguration.Cell
        ) {
            self.id = id
            self.title = title
            self.circleColor = circleColor
            self.isSelected = InMemoryStorage<Bool>(model: isSelected)
            self.leadingImage = leadingImage
            self.trailingTitle = trailingTitle
            self.onPress = onPress
            self.configuration = configuration
        }
    }
    
    case singleSelection(SelectionCellPresentableModel)
    case multipleSelection([SelectionCellPresentableModel])
}

public struct SelectionConfiguration {
    public let texts: Texts
    public let content: Content
    public let resetButton: ActionButton
    public let searchButton: ActionButton
    public let searchBar: SearchBar
    public let resetButtonColors: ResetButtonColors
    
    public init(
        texts: Texts,
        content: Content,
        resetButton: ActionButton,
        searchButton: ActionButton,
        searchBar: SearchBar,
        resetButtonColors: ResetButtonColors
    ) {
        self.texts = texts
        self.content = content
        self.resetButton = resetButton
        self.searchButton = searchButton
        self.searchBar = searchBar
        self.resetButtonColors = resetButtonColors
    }
    
    public struct Texts {
        public let searchTitle: String
        public let resetTitle: String
        public let selectTitle: String
        public let selectedCountTitle: String
        
        public init(
            searchTitle: String,
            resetTitle: String,
            selectTitle: String,
            selectedCountTitle: String
        ) {
            self.searchTitle = searchTitle
            self.resetTitle = resetTitle
            self.selectTitle = selectTitle
            self.selectedCountTitle = selectedCountTitle
        }
    }
    
    public struct Cell {
        public var titleFont: Font
        public var trailingFont: Font
        public var titleColor: Color
        public var selectedTitleColor: Color?
        public var trailingColor: Color
        public var selectedImage: ImageEnum?
        public var notSelectedImage: ImageEnum?
        public var lineColor: Color
        public var keyLabelNumberOfLines: Int
        
        public init(
            titleFont: Font,
            trailingFont: Font,
            titleColor: Color,
            selectedTitleColor: Color? = nil,
            trailingColor: Color,
            selectedImage: ImageEnum? = nil,
            notSelectedImage: ImageEnum? = nil,
            lineColor: Color,
            keyLabelNumberOfLines: Int = 1
        ) {
            self.titleFont = titleFont
            self.trailingFont = trailingFont
            self.titleColor = titleColor
            self.selectedTitleColor = selectedTitleColor
            self.trailingColor = trailingColor
            self.selectedImage = selectedImage
            self.notSelectedImage = notSelectedImage
            self.lineColor = lineColor
            self.keyLabelNumberOfLines = keyLabelNumberOfLines
        }
    }
    
    public struct SearchBar {
        public var textfieldAppearence: TextfieldAppearance
        public var searchImage: Image
        public var tintColor: Color
        
        public init(
            textfieldAppearence: TextfieldAppearance,
            searchImage: Image,
            tintColor: Color
        ) {
            self.textfieldAppearence = textfieldAppearence
            self.searchImage = searchImage
            self.tintColor = tintColor
        }
    }
    
    public struct Content {
        public var lineColor: Color
        public var backgroundColor: Color
        
        public var backButtonImage: ImageEnum?
        public var navBarFont: Font
        public var navBarTextColor: Color
        
        public let shadowBackgroundColor: Color
        
        public init(
            lineColor: Color,
            backgroundColor: Color,
            backButtonImage: ImageEnum? = nil,
            navBarFont: Font,
            navBarTextColor: Color,
            shadowBackgroundColor: Color
        ) {
            self.lineColor = lineColor
            self.backgroundColor = backgroundColor
            self.backButtonImage = backButtonImage
            self.navBarFont = navBarFont
            self.navBarTextColor = navBarTextColor
            self.shadowBackgroundColor = shadowBackgroundColor
        }
    }
    
    public struct ActionButton {
        public var labelFont: Font
        public var textColor: Color
        public var backgroundColor: Color
        public var borderColor: Color
        
        public init(
            labelFont: Font,
            textColor: Color,
            backgroundColor: Color,
            borderColor: Color
        ) {
            self.labelFont = labelFont
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
        }
    }
    
    public struct ResetButtonColors {
        public let activeTitleColor: Color
        public let activeBorderColor: Color
        public let activeBackgroundColor: Color
        public let inactiveTitleColor: Color
        public let inactiveBorderColor: Color
        public let inactiveBackgroundColor: Color
        
        public init(
            activeTitleColor: Color,
            activeBorderColor: Color,
            activeBackgroundColor: Color,
            inactiveTitleColor: Color,
            inactiveBorderColor: Color,
            inactiveBackgroundColor: Color
        ) {
            self.activeTitleColor = activeTitleColor
            self.activeBorderColor = activeBorderColor
            self.activeBackgroundColor = activeBackgroundColor
            self.inactiveTitleColor = inactiveTitleColor
            self.inactiveBorderColor = inactiveBorderColor
            self.inactiveBackgroundColor = inactiveBackgroundColor
        }
    }
}
