//
//  SelectionVC.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import UIKit

open class SelectionVC: BottomSheetController<SelectionContentView> {
    public let presenter: SelectionInput
    
    private lazy var datasource = makeDatasource()
    private var currentContentYOffset: CGFloat = 0
    
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
        
        contentView.navigationBar.primeTrailingImageWrapperView.onPress = presenter.onTapClose
        contentView.resetButton.onPress = presenter.onTapReset
        contentView.selectButton.onPress = presenter.onTapFinishSelection
        contentView.searchBar.textfield.didChangeText.append(presenter.onSearch)
        contentView.stackView.isHidden = !presenter.isMultipleSelectionEnabled
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
        contentView.searchBarConstraints?.height?.constant = shouldShowSearchBar ? SelectionContentView.searchBarHeight : 0
        contentView.searchBarConstraints?.top?.constant = shouldShowSearchBar ? 8 : 0
        contentView.tableViewConstraints?.top?.constant = shouldShowSearchBar ? 16 : 8
    }
    
    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
        datasource.updateItems(items)
        let selectedItemsCount = items.filter { $0.isSelected.get() == true }.count
        contentView.selectButton.setTitle("\(selectedCountTitle)\(selectedItemsCount == 0 ? "" : " (\(selectedItemsCount))")", for: .normal)
    }
    
    public func display(title: String?) {
        contentView.navigationBar.titleViews.keyLabel.text = title
        contentView.navigationBar.leadingCardView.titleViews.keyLabel.text = title
    }
}

extension SelectionVC {
    func makeDatasource() -> DiffableTableViewDataSource<SelectionType.SelectionCellPresentableModel> {
        let datasource = DiffableTableViewDataSource<SelectionType.SelectionCellPresentableModel>(
            tableView: contentView.tableView,
            configureCell: { tableView, indexPath, model in
                let cell: SelectionCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = model
                return cell
            }
        )
        
        datasource.didSelectAt = { [weak self] indexPath, model in
            self?.presenter.onSelect(at: indexPath.row)
        }
        
        datasource.didScrollViewDidScroll = { [weak self] scrollView in
            guard let self = self, !self.contentView.searchBar.isHidden, scrollView.isDragging, self.contentView.searchBar.textfield.text.isEmpty, scrollView.contentOffset.y > 0 else { return }
            
            let offset = scrollView.contentOffset.y - self.currentContentYOffset
            let height = self.contentView.searchBarConstraints?.height?.constant ?? 0
            let newHeight = offset >= 0 ? max(0, height - offset) : min(SelectionContentView.searchBarHeight, height - offset)
            
            self.contentView.searchBarConstraints?.height?.constant = newHeight
            
            let alpha = newHeight / SelectionContentView.searchBarHeight
            self.contentView.searchBar.alpha = alpha
            
            if height != newHeight {
                scrollView.contentOffset.y = self.currentContentYOffset
            }
            self.currentContentYOffset = scrollView.contentOffset.y
        }
        
        datasource.didScrollViewDidEndDragging = { [weak self] scrollView, _ in
            guard let self = self, !self.contentView.searchBar.isHidden else { return }
            let height = self.contentView.searchBarConstraints?.height?.constant ?? 0
            let newHeight = height >= (SelectionContentView.searchBarHeight / 2) || !self.contentView.searchBar.textfield.text.isEmpty || scrollView.contentOffset.y <= 0 ? SelectionContentView.searchBarHeight : 0
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
                self.contentView.searchBarConstraints?.height?.constant = newHeight
                self.contentView.searchBar.alpha = newHeight / SelectionContentView.searchBarHeight
                self.view.layoutIfNeeded()
            }
        }
        
        datasource.didScrollViewDidEndDecelerating = { [weak self] scrollView in
            guard let self = self, !self.contentView.searchBar.isHidden else { return }
            let height = self.contentView.searchBarConstraints?.height?.constant ?? 0
            let newHeight = height >= (SelectionContentView.searchBarHeight / 2) || !self.contentView.searchBar.textfield.text.isEmpty || scrollView.contentOffset.y <= 0 ? SelectionContentView.searchBarHeight : 0
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
                self.contentView.searchBarConstraints?.height?.constant = newHeight
                self.contentView.searchBar.alpha = newHeight / SelectionContentView.searchBarHeight
                self.view.layoutIfNeeded()
            }
        }

        return datasource
    }
}
#endif
