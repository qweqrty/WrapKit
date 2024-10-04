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
    public var view: SelectionOutput?
    
    public let title: String?
    public let isMultipleSelectionEnabled: Bool
    public let originalItems: [SelectionType.SelectionCellPresentableModel]
    public var items: [SelectionType.SelectionCellPresentableModel] {
        didSet {
            view?.display(shouldShowSearchBar: items.count > shouldShowSearchBarThresholdCount)
            onSearch(searchText)
        }
    }
    
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
        self.originalItems = items
        self.items = items.map {
            SelectionType.SelectionCellPresentableModel(
                id: $0.id,
                title: $0.title,
                circleColor: $0.circleColor,
                isSelected: $0.isSelected.get() ?? false,
                trailingTitle: $0.trailingTitle,
                leadingImage: $0.leadingImage,
                onPress: $0.onPress,
                configuration: $0.configuration
            )
        }
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
        view?.display(shouldShowSearchBar: items.count > shouldShowSearchBarThresholdCount)
        view?.display(title: title)
        onSearch(searchText)
    }
    
    public func onTapFinishSelection() {
        originalItems.forEach { $0.isSelected.set(model: items.filter { $0.isSelected.get() == true }.map { $0.id }.contains($0.id)) }
        let selectedItems = originalItems.filter { $0.isSelected.get() == true }
        if isMultipleSelectionEnabled {
            flow.close(with: .multipleSelection(selectedItems))
        } else if let selectedItem = selectedItems.first {
            flow.close(with: .singleSelection(selectedItem))
        } else {
            flow.close(with: nil)
        }
    }
    
    public func onTapReset() {
        items.forEach { $0.isSelected.set(model: false) }
        view?.display(canReset: false)
        onSearch(searchText)
    }
    
    public func onSearch(_ text: String?) {
        searchText = text ?? ""
        view?.display(items: itemsToPresent, selectedCountTitle: configuration.texts.selectedCountTitle)
        view?.display(canReset: items.contains(where: { $0.isSelected.get() == true }))
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
        view?.display(canReset: items.contains(where: { $0.isSelected.get() == true }))
    }
}
