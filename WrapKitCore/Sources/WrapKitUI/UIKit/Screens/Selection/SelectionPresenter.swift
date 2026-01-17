//
//  SelectionPresenter.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public protocol SelectionOutput: AnyObject {
    func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String)
    func display(shouldShowSearchBar: Bool)
}

public protocol SelectionInput {
    var items: [SelectionType.SelectionCellPresentableModel] { get set }
    var isMultipleSelectionEnabled: Bool { get }
    var configuration: SelectionConfiguration { get }
    
    func onSearch(_ text: String?)
    func onTapFinishSelection()
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool)
}

public class SelectionPresenter {
    public static let shouldShowSearchBarThresholdCount = 15
    private let flow: SelectionFlow
    public var view: SelectionOutput?
    public var navBarView: HeaderOutput?
    public var resetButton: ButtonOutput?
    public var selectButton: ButtonOutput?
    public var emptyView: EmptyViewOutput?
    
    private let model: SelectionPresenterModel
    public var isMultipleSelectionEnabled: Bool { model.isMultipleSelectionEnabled }
    public var items: [SelectionType.SelectionCellPresentableModel] {
        didSet {
            view?.display(shouldShowSearchBar: items.count > Self.shouldShowSearchBarThresholdCount)
            onSearch(searchText)
        }
    }
    
    private var searchText = ""
    
    public let configuration: SelectionConfiguration
    
    public init(
        flow: SelectionFlow,
        model: SelectionPresenterModel,
        configuration: SelectionConfiguration
    ) {
        self.flow = flow
        self.model = model
        self.items = model.items
        self.configuration = configuration
    }
    
    private var itemsToPresent: [SelectionType.SelectionCellPresentableModel] { searchText.isEmpty ? items : items.filter({ ($0.title ).lowercased().contains(searchText.lowercased()) }) }
}

extension SelectionPresenter: SelectionInput, LifeCycleViewOutput {
    
    public func viewDidLoad() {
       
        view?.display(shouldShowSearchBar: items.count > Self.shouldShowSearchBarThresholdCount)
        navBarView?.display(model: .init(
            style: configuration.navBar,
            leadingCard: .init(title: .text(model.title)),
            primeTrailingImage: configuration.content.backButtonImage.map { backButtonImage in
                    .init(image: backButtonImage, onPress: { [weak self] in
                        guard let self = self else { return }
                        self.model.callback?(nil)
                        self.flow.close(with: nil)
                    })
            }
        ))
        emptyView?.display(model: model.emptyViewPresentableModel)
        
        resetButton?.display(model: .init(
            title: configuration.texts.resetTitle,
            height: 48,
            style: .init(
                backgroundColor: configuration.resetButton?.backgroundColor,
                titleColor: configuration.resetButton?.textColor,
                borderWidth: 1,
                borderColor: configuration.resetButton?.borderColor,
                font: configuration.resetButton?.labelFont,
                cornerRadius: 16
            ),
            enabled: false,
            onPress: { [weak self] in
                self?.items.forEach { $0.isSelected.set(model: false) }
                self?.setupButton(canReset: false)
                self?.onSearch(self?.searchText)
            }
        ))
        
        selectButton?.display(model: .init(
            title: configuration.texts.selectTitle,
            height: 48,
            style: .init(
                backgroundColor: configuration.searchButton.backgroundColor,
                titleColor: configuration.searchButton.textColor,
                borderWidth: 0,
                borderColor: configuration.searchButton.borderColor,
                font: configuration.resetButton?.labelFont,
                cornerRadius: 16
            ),
            enabled: true,
            onPress: { [weak self] in
                self?.onTapFinishSelection()
            }
        ))
        
        onSearch(searchText)
    }
    
    private func setupButton(canReset: Bool) {
        
        resetButton?.display(style: .init(
            backgroundColor: canReset ? configuration.resetButtonColors.activeBackgroundColor
            : configuration.resetButtonColors.inactiveBackgroundColor,
            titleColor: canReset ? configuration.resetButtonColors.activeTitleColor
            : configuration.resetButtonColors.inactiveTitleColor,
            borderColor: canReset ? configuration.resetButtonColors.activeBorderColor
            : configuration.resetButtonColors.inactiveBorderColor
        ))
        
        resetButton?.display(enabled: canReset)
    }
    
    public func onTapFinishSelection() {
        let selectedItems = items.filter { $0.isSelected.get() == true }
        if isMultipleSelectionEnabled {
            model.callback?(.multipleSelection(selectedItems))
            flow.close(with: .multipleSelection(selectedItems))
        } else if let selectedItem = selectedItems.first {
            model.callback?(.singleSelection(selectedItem))
            flow.close(with: .singleSelection(selectedItem))
        } else {
            model.callback?(nil)
            flow.close(with: nil)
        }
    }
    
    public func onSearch(_ text: String?) {
        searchText = text ?? ""
        view?.display(items: [.init(cells: itemsToPresent.map { .init(cell: $0, onTap: onSelect(at:model:)) })], selectedCountTitle: configuration.texts.selectedCountTitle)
        setupButton(canReset: items.contains(where: { $0.isSelected.get() == true }))
    }
    
    private func onSelect(at indexPath: IndexPath, model: SelectionType.SelectionCellPresentableModel) {
        guard let selectedItem = itemsToPresent.item(at: indexPath.unifiedIndex) else { return }
        guard let selectedItemIndex = self.items.firstIndex(where: { $0.id == selectedItem.id }) else { return }
        selectedItem.onPress?()
        
        let isSelected = selectedItem.isSelected.get() == true
        items[selectedItemIndex].isSelected.set(model: !isSelected)
        
        if !self.isMultipleSelectionEnabled {
            items.enumerated().forEach {
                items[$0.offset].isSelected.set(model: $0.element.id == selectedItem.id)
            }
            onTapFinishSelection()
        } else {
            onSearch(searchText)
        }
    }
    
    public func isNeedToShowSearch(_ isNeedToShowSearch: Bool) {
        view?.display(shouldShowSearchBar: isNeedToShowSearch)
    }
}
