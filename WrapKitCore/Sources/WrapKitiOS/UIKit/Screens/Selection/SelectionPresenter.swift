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
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool)
}

public class SelectionPresenter {
    public static let shouldShowSearchBarThresholdCount = 15
    private let flow: SelectionFlow
    public var view: SelectionOutput?
    
    private let model: SelectionPresenterModel
    public var isMultipleSelectionEnabled: Bool { model.isMultipleSelectionEnabled }
    public var items: ShimmeredCellModel<[SelectionType.SelectionCellPresentableModel]> {
        didSet {
            guard let count = items.model?.count else { return }
            view?.display(shouldShowSearchBar: count > Self.shouldShowSearchBarThresholdCount)
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
        self.items = .model(model.items)
        self.configuration = configuration
    }
    
    private var itemsToPresent: [SelectionType.SelectionCellPresentableModel] {
        guard let model = items.model else { return [] }
        return searchText.isEmpty ? model : model.filter({ ($0.title ).lowercased().contains(searchText.lowercased()) })
    }
}

extension SelectionPresenter: SelectionInput {
    public func onTapClose() {
        model.callback?(nil)
        flow.close(with: nil)
    }
    
    public func viewDidLoad() {
        view?.display(shouldShowSearchBar: items.model?.count ?? 0 > Self.shouldShowSearchBarThresholdCount)
        view?.display(title: model.title)
        onSearch(searchText)
    }
    
    public func onTapFinishSelection() {
        guard let presentableModel = items.model else { return }
        let selectedItems = presentableModel.filter { $0.isSelected.get() == true }
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
    
    public func onTapReset() {
        items.model?.forEach { $0.isSelected.set(model: false) }
        view?.display(canReset: false)
        onSearch(searchText)
    }
    
    public func onSearch(_ text: String?) {
        searchText = text ?? ""
        view?.display(items: itemsToPresent, selectedCountTitle: configuration.texts.selectedCountTitle)
        guard let model = items.model else { return }
        view?.display(canReset: model.contains(where: { $0.isSelected.get() == true }))
    }
    
    public func onSelect(at index: Int) {
        guard let selectedItem = itemsToPresent.item(at: index) else { return }
        guard let model = items.model else { return }
        guard let selectedItemIndex = model.firstIndex(where: { $0.id == selectedItem.id }) else { return }
        selectedItem.onPress?()
        
        let isSelected = selectedItem.isSelected.get() == true
        model[selectedItemIndex].isSelected.set(model: !isSelected)
        
        onSearch(searchText)
        
        if !self.isMultipleSelectionEnabled {
            model.enumerated().forEach {
                model[$0.offset].isSelected.set(model: $0.element.id == selectedItem.id)
            }
            self.onTapFinishSelection()
        }
        view?.display(canReset: model.contains(where: { $0.isSelected.get() == true }))
    }
    
    public func isNeedToShowSearch(_ isNeedToShowSearch: Bool) {
        view?.display(shouldShowSearchBar: isNeedToShowSearch)
    }
}
