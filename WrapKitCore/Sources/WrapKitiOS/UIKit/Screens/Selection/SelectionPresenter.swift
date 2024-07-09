//
//  SelectionPresenter.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public protocol SelectionOutput: AnyObject {
    func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String)
    func display(title: String?)
    func display(shouldShowSearchBar: Bool)
    func display(canReset: Bool, resetButtonColors: SelectionConfiguration.ResetButtonColors)
    func apply(configuration: SelectionConfiguration)
}

public protocol SelectionInput {
    var isMultipleSelectionEnabled: Bool { get }
    
    func viewDidLoad()
    func onSearch(_ text: String?)
    func onSelect(at index: Int)
    func onTapFinishSelection()
    func onTapReset()
    func onTapClose()
}

public class SelectionPresenter {
    private let flow: SelectionFlow
    public weak var view: SelectionOutput?
    
    public let title: String?
    public let isMultipleSelectionEnabled: Bool
    public var items: [SelectionType.SelectionCellPresentableModel] {
        didSet {
            view?.display(shouldShowSearchBar: items.count > shouldShowSearchBarThresholdCount)
            onSearch(searchText)
        }
    }
    
    private let initialSelectedItems: [SelectionType.SelectionCellPresentableModel]
    private var searchText = ""
    private let shouldShowSearchBarThresholdCount = 15
    
    private let configuration: SelectionConfiguration
    
    public init(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) {
        self.title = title
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        self.initialSelectedItems = items
        self.items = items
        self.flow = flow
        self.configuration = configuration
    }
    
    private var itemsToPresent: [SelectionType.SelectionCellPresentableModel] { searchText.isEmpty ? items : items.filter({ ($0.title ).lowercased().contains(searchText.lowercased()) }) }
    private var selectedItems: [SelectionType.SelectionCellPresentableModel] { itemsToPresent.filter { $0.isSelected } }
}

extension SelectionPresenter: SelectionInput {
    public func onTapClose() {
        flow.close(with: nil)
    }
    
    public func viewDidLoad() {
        onSearch(searchText)
        view?.display(title: title)
        view?.display(shouldShowSearchBar: items.count > shouldShowSearchBarThresholdCount)
        view?.apply(configuration: configuration)
    }
    
    public func onTapFinishSelection() {
        if isMultipleSelectionEnabled {
            flow.close(with: .multipleSelection(selectedItems))
        } else if let selectedItem = selectedItems.first {
            let selectedIndexes = items.enumerated().filter { $0.element.isSelected }.map { $0.offset }
            flow.close(with: .singleSelection(selectedItem))
        } else {
            flow.close(with: nil)
        }
    }
    
    public func onTapReset() {
        self.items = initialSelectedItems
        onSearch(searchText)
    }
    
    public func onSearch(_ text: String?) {
        searchText = text ?? ""
        view?.display(items: itemsToPresent, selectedCountTitle: configuration.texts.selectedCountTitle)
        view?.display(
            canReset: initialSelectedItems != items,
            resetButtonColors: configuration.resetButtonColors
        )
    }
    
    public func onSelect(at index: Int) {
        guard let selectedItem = itemsToPresent.item(at: index) else { return }
        guard let selectedItemIndex = self.items.firstIndex(where: { $0.id == selectedItem.id }) else { return }

        let isSelected = selectedItem.isSelected
        items[selectedItemIndex].isSelected = !isSelected
        
        onSearch(searchText)
        
        if !self.isMultipleSelectionEnabled {
            items.enumerated().forEach {
                items[$0.offset].isSelected = $0.element.id == selectedItem.id
            }
            self.onTapFinishSelection()
        }
        
    }
}
