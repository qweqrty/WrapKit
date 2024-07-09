//
//  SelectionFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import UIKit

public protocol ISelectionFactory {
    func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> UIViewController
}

public class SelectionFactory: ISelectionFactory {
    public func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            flow: flow,
            configuration: configuration
        )
        let vc = SelectionVC(
            contentView: .init(config: configuration),
            presenter: presenter
        )
        presenter.view = vc
        return vc
    }
    
    public init() {}
}

public struct SelectionConfiguration {
    public let searchTitle: String
    public let resetTitle: String
    public let selectTitle: String
    
    public let cell: Cell
    public let content: Content
    public let resetButton: ActionButton
    public let searchButton: ActionButton
    public let searchBar: SearchBar
    public let resetButtonColors: ResetButtonColors
    
    public init(
        searchTitle: String,
        resetTitle: String,
        selectTitle: String,
        cell: Cell,
        content: Content,
        resetButton: ActionButton,
        searchButton: ActionButton,
        searchBar: SearchBar,
        resetButtonColors: ResetButtonColors
    ) {
        self.searchTitle = searchTitle
        self.resetTitle = resetTitle
        self.selectTitle = selectTitle
        self.cell = cell
        self.content = content
        self.resetButton = resetButton
        self.searchButton = searchButton
        self.searchBar = searchBar
        self.resetButtonColors = resetButtonColors
    }
    
    public struct Cell {
        public var titleFont: UIFont
        public var trailingFont: UIFont
        public var titleColor: UIColor
        public var trailingColor: UIColor
        public var selectedImage: UIImage
        public var notSelectedImage: UIImage
        public var lineColor: UIColor
        
        public init(
            titleFont: UIFont,
            trailingFont: UIFont,
            titleColor: UIColor,
            trailingColor: UIColor,
            selectedImage: UIImage,
            notSelectedImage: UIImage,
            lineColor: UIColor
        ) {
            self.titleFont = titleFont
            self.trailingFont = trailingFont
            self.titleColor = titleColor
            self.trailingColor = trailingColor
            self.selectedImage = selectedImage
            self.notSelectedImage = notSelectedImage
            self.lineColor = lineColor
        }
    }
    
    public struct SearchBar {
        public var textfieldAppearence: Textfield.Appearance
        public var searchImage: UIImage
        public var tintColor: UIColor
        
        public init(
            textfieldAppearence: Textfield.Appearance,
            searchImage: UIImage,
            tintColor: UIColor
        ) {
            self.textfieldAppearence = textfieldAppearence
            self.searchImage = searchImage
            self.tintColor = tintColor
        }
    }
    
    public struct Content {
        public var lineColor: UIColor
        public var backgroundColor: UIColor
        
        public var backButtonImage: UIImage
        public var navBarFont: UIFont
        public var navBarTextColor: UIColor
        
        public init(
            lineColor: UIColor,
            backgroundColor: UIColor,
            backButtonImage: UIImage,
            navBarFont: UIFont,
            navBarTextColor: UIColor
        ) {
            self.lineColor = lineColor
            self.backgroundColor = backgroundColor
            self.backButtonImage = backButtonImage
            self.navBarFont = navBarFont
            self.navBarTextColor = navBarTextColor
        }
    }
    
    public struct ActionButton {
        public var labelFont: UIFont
        public var textColor: UIColor
        public var backgroundColor: UIColor
        public var borderColor: UIColor
        
        public init(
            labelFont: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor
        ) {
            self.labelFont = labelFont
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
        }
    }
    
    public struct ResetButtonColors {
        public let activeTitleColor: UIColor
        public let activeBorderColor: UIColor
        public let inactiveTitleColor: UIColor
        public let inactiveBorderColor: UIColor
        
        public init(
            activeTitleColor: UIColor,
            activeBorderColor: UIColor,
            inactiveTitleColor: UIColor,
            inactiveBorderColor: UIColor
        ) {
            self.activeTitleColor = activeTitleColor
            self.activeBorderColor = activeBorderColor
            self.inactiveTitleColor = inactiveTitleColor
            self.inactiveBorderColor = inactiveBorderColor
        }
    }
}
