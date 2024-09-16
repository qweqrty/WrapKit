//
//  SelectionFlowiOS.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import Foundation
import UIKit
import BottomSheet
import DesignSystemiOSNur

public class SelectionFlowiOS: SelectionFlow {
    public let configuration: Model
    
    private weak var navigationController: UINavigationController?
    private let factory: any ISelectionFactory<UIViewController>
    
    public init(
        configuration: Model,
        navigationController: UINavigationController?,
        factory: any ISelectionFactory<UIViewController>
    ) {
        self.configuration = configuration
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func showSelection(model: SelectionPresenterModel) {
        let vc = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: configuration.content.shadowBackgroundColor)
            )
        )
    }
    
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        let vc = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: configuration.content.shadowBackgroundColor)
            )
        )
    }
    
    public func close(with result: SelectionType?) {
        DispatchQueue.main.async {
            self.navigationController?.presentedViewController?.dismiss(animated: true)
        }
    }
}

public extension SelectionConfiguration.Cell {
    static let nurSelectionCell = SelectionConfiguration.Cell.init(
        titleFont: UIFont.h2,
        trailingFont: UIFont.l1,
        titleColor: NurAssets.Colors.Text.primary.color,
        trailingColor: NurAssets.Colors.Text.primary.color,
        selectedImage: NurAssets.Images.Selection.icSelectedRadioButton.image,
        notSelectedImage: NurAssets.Images.Selection.icUnselectedRadioButton.image,
        lineColor: NurAssets.Colors.ShevronAndDivider.divider.color
    )
}

public extension SelectionFlowiOS {
    static func dashboardSelection(
        title: String?,
        items: [SelectionType.SelectionCellPresentableModel],
        isMultipleSelectionEnabled: Bool,
        callback: ((SelectionType?) -> Void)?,
        navigationController: UINavigationController?,
        factory: any ISelectionFactory<UIViewController>
    ) -> SelectionFlowiOS {
        let texts = SelectionConfiguration.Texts(
            searchTitle: NurStrings.Selection.search,
            resetTitle: NurStrings.Selection.reset,
            selectTitle: NurStrings.Selection.select,
            selectedCountTitle: NurStrings.Selection.selected
        )
        let content = SelectionConfiguration.Content.init(
            lineColor: NurAssets.Colors.ShevronAndDivider.divider.color,
            backgroundColor: NurAssets.Colors.Background.bottomsheetBackground.color,
            refreshColor: NurAssets.Colors.SelectionControl.segmentedGray.color,
            backButtonImage: NurAssets.Images.NavigationBar.close.image,
            navBarFont: UIFont.h2,
            navBarTextColor: NurAssets.Colors.Text.primary.color,
            shadowBackgroundColor: NurAssets.Colors.NavigationTab.icon.color.withAlphaComponent(0.5)
        )
        let resetButton = SelectionConfiguration.ActionButton.init(
            labelFont: UIFont.h2,
            textColor: NurAssets.Colors.Text.inner.color,
            backgroundColor: NurAssets.Colors.Button.primaryActive.color,
            borderColor: UIColor.clear
        )
        let searchButton = SelectionConfiguration.ActionButton.init(
            labelFont: UIFont.h2,
            textColor: NurAssets.Colors.Text.primary.color,
            backgroundColor: NurAssets.Colors.Button.secondaryActive.color,
            borderColor: UIColor.clear
        )
        let searchBar = SelectionConfiguration.SearchBar.init(
            textfieldAppearence: Textfield.nurTextfieldAppearence,
            searchImage: NurAssets.Images.InputField.search.image,
            tintColor: NurAssets.Colors.Button.secondaryActive.color
        )
        let resetButtonColors = SelectionConfiguration.ResetButtonColors(
            activeTitleColor: NurAssets.Colors.Text.inner.color,
            activeBorderColor: UIColor.clear,
            activeBackgroundColor: NurAssets.Colors.Button.primaryActive.color,
            inactiveTitleColor: NurAssets.Colors.Text.placeholder.color,
            inactiveBorderColor: UIColor.clear,
            inactiveBackgroundColor: NurAssets.Colors.Button.primaryDisabled.color
        )
        let configuration = SelectionConfiguration(
            texts: texts,
            content: content,
            resetButton: resetButton,
            searchButton: searchButton,
            searchBar: searchBar,
            resetButtonColors: resetButtonColors
        )
        let model = SelectionPresenterModel(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            callback: callback
        )
        let flow = SelectionFlowiOS(
            configuration: configuration,
            navigationController: navigationController,
            factory: factory
        )
        return flow
    }
}

#endif
