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
    func display(canReset: Bool)
}

public protocol SelectionInput {
    var isMultipleSelectionEnabled: Bool { get }
    var configuration: SelectionConfiguration { get }
    
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
    
    public let configuration: SelectionConfiguration
    
    public init(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) {
        self.title = title
        self.isMultipleSelectionEnabled = isMultipleSelectionEnabled
        self.initialSelectedItems = items.filter { $0.isSelected.get() == true }
        self.items = items
        self.flow = flow
        self.configuration = configuration
    }
    
    private var itemsToPresent: [SelectionType.SelectionCellPresentableModel] { searchText.isEmpty ? items : items.filter({ ($0.title ).lowercased().contains(searchText.lowercased()) }) }
}

extension SelectionPresenter: SelectionInput {
    public func onTapClose() {
        flow.close(with: nil)
    }
    
    public func viewDidLoad() {
        onSearch(searchText)
        view?.display(title: title)
        view?.display(shouldShowSearchBar: items.count > shouldShowSearchBarThresholdCount)
    }
    
    public func onTapFinishSelection() {
        let selectedItems = items.filter { $0.isSelected.get() == true }
        if isMultipleSelectionEnabled {
            flow.close(with: .multipleSelection(selectedItems))
        } else if let selectedItem = selectedItems.first {
            flow.close(with: .singleSelection(selectedItem))
        } else {
            flow.close(with: nil)
        }
    }
    
    public func onTapReset() {
        self.items.forEach {
            $0.isSelected.set(model: initialSelectedItems.contains($0))
        }
        view?.display(canReset: false)
        onSearch(searchText)
    }
    
    public func onSearch(_ text: String?) {
        searchText = text ?? ""
        view?.display(items: itemsToPresent, selectedCountTitle: configuration.texts.selectedCountTitle)
        view?.display(canReset: initialSelectedItems != items.filter { $0.isSelected.get() == true })
    }
    
    public func onSelect(at index: Int) {
        guard let selectedItem = itemsToPresent.item(at: index) else { return }
        guard let selectedItemIndex = self.items.firstIndex(where: { $0.id == selectedItem.id }) else { return }
        selectedItem.onPress?()
        
        let isSelected = selectedItem.isSelected.get() == true
        items[selectedItemIndex].isSelected.set(model: !isSelected)
        
        onSearch(searchText)
        
        if !self.isMultipleSelectionEnabled {
            items.enumerated().forEach {
                items[$0.offset].isSelected.set(model: $0.element.id == selectedItem.id)
            }
            self.onTapFinishSelection()
        }
        view?.display(canReset: initialSelectedItems != items.filter { $0.isSelected.get() == true })
    }
}
