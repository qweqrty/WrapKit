//
//  SelectionVC.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import Foundation
import UIKit
import BottomSheet

open class SelectionVC: ViewController<SelectionContentView> {
    private let presenter: SelectionInput
    private lazy var datasource = DiffableTableViewDataSource<SelectionType.SelectionCellPresentableModel>(
        tableView: contentView.tableView,
        configureCell: { [weak self] tableView, indexPath, model in
            let cell: SelectionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.model = model
            return cell
        }
    )
    
    public init(contentView: SelectionContentView, presenter: SelectionInput) {
        self.presenter = presenter
        super.init(contentView: contentView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        contentView.searchBar.textfield.placeholder = presenter.configuration.texts.searchTitle
        contentView.resetButton.setTitle(presenter.configuration.texts.resetTitle, for: .normal)
        contentView.selectButton.setTitle(presenter.configuration.texts.selectTitle, for: .normal)
        
        datasource.didSelectAt = { [weak self] indexPath, _ in
            self?.presenter.onSelect(at: indexPath.row)
        }
        contentView.navigationBar.primeTrailingImageWrapperView.onPress = presenter.onTapClose
        contentView.resetButton.onPress = presenter.onTapReset
        contentView.selectButton.onPress = presenter.onTapFinishSelection
        contentView.searchBar.textfield.didChangeText.append(presenter.onSearch)
        contentView.stackView.isHidden = !presenter.isMultipleSelectionEnabled
    }
    
    private func updatePreferredContentSize() {
        let calculatedHeight = !contentView.searchBar.isHidden ? contentView.frame.height : contentView.tableView.contentSize.height +
        contentView.navigationBar.frame.height +
        contentView.lineView.frame.height +
        (contentView.searchBarConstraints?.height?.constant ?? 0) +
        (contentView.searchBarConstraints?.top?.constant ?? 0) +
        contentView.stackView.frame.height +
        (contentView.tableViewConstraints?.top?.constant ?? 0)
        
        let bottomViewHeight = contentView.stackView.bounds.height + 24 + view.safeAreaInsets.bottom
        
        if presenter.isMultipleSelectionEnabled {
            if ((window?.bounds.height ?? 0) - contentView.stackView.bounds.height) > calculatedHeight {
                preferredContentSize = CGSize(
                    width: (window?.bounds.width ?? 0),
                    height: calculatedHeight + contentView.stackView.bounds.height
                )
            } else {
                preferredContentSize = CGSize(
                    width: (window?.bounds.width ?? 0),
                    height: calculatedHeight
                )
                contentView.tableView.contentInset = .init(top: 0, left: 0, bottom: bottomViewHeight, right: 0)
            }
        } else {
            preferredContentSize = CGSize(
                width: (window?.bounds.width ?? 0),
                height: calculatedHeight
            )
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionVC: SelectionOutput {
    public func display(canReset: Bool) {
        if canReset {
            contentView.resetButton.setTitleColor(presenter.configuration.resetButtonColors.activeTitleColor, for: .normal)
            contentView.resetButton.layer.borderColor = presenter.configuration.resetButtonColors.activeBorderColor.cgColor
            contentView.resetButton.backgroundColor = presenter.configuration.resetButtonColors.activeBackgroundColor
        } else {
            contentView.resetButton.setTitleColor(presenter.configuration.resetButtonColors.inactiveTitleColor, for: .normal)
            contentView.resetButton.layer.borderColor = presenter.configuration.resetButtonColors.inactiveBorderColor.cgColor
            contentView.resetButton.backgroundColor = presenter.configuration.resetButtonColors.inactiveBackgroundColor
        }
        contentView.resetButton.isUserInteractionEnabled = canReset
    }
    
    public func display(shouldShowSearchBar: Bool) {
        contentView.searchBar.isHidden = !shouldShowSearchBar
        contentView.searchBarConstraints?.height?.constant = shouldShowSearchBar ? 44 : 0
        contentView.searchBarConstraints?.top?.constant = shouldShowSearchBar ? 8 : 0
        contentView.tableViewConstraints?.top?.constant = shouldShowSearchBar ? 16 : 8
    }
    
    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
        datasource.updateItems(items)
        let selectedItemsCount = items.filter { $0.isSelected.get() == true }.count
        contentView.selectButton.setTitle("\(selectedCountTitle)\(selectedItemsCount == 0 ? "" : " (\(selectedItemsCount))")", for: .normal)
        updatePreferredContentSize()
    }
    
    public func display(title: String?) {
        contentView.navigationBar.titleViews.keyLabel.text = title
        contentView.navigationBar.leadingCardView.titleViews.keyLabel.text = title
    }
}

extension SelectionVC: ScrollableBottomSheetPresentedController {
    public var scrollView: UIScrollView? { contentView.tableView }
}
#endif
