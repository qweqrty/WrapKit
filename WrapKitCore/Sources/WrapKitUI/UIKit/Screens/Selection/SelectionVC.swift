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
    
    public init(
        contentView: SelectionContentView,
        presenter: SelectionInput,
        lifeCycleViewOutput: LifeCycleViewOutput?
    ) {
        self.presenter = presenter
        super.init(contentView: contentView, lifeCycleViewOutput: lifeCycleViewOutput)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.searchBar.textfield.placeholder = presenter.configuration.texts.searchTitle
        contentView.searchBar.textfield.didChangeText.append(presenter.onSearch)
        contentView.buttonsStackView.isHidden = !presenter.isMultipleSelectionEnabled
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionVC: SelectionOutput {
    public func display(shouldShowSearchBar: Bool) {
        contentView.searchBar.isHidden = !shouldShowSearchBar
        contentView.searchBarConstraints?.height?.constant = shouldShowSearchBar ? SelectionContentView.searchBarHeight : 0
        contentView.searchBarConstraints?.top?.constant = shouldShowSearchBar ? 8 : 0
        contentView.tableStackViewConstraints?.top?.constant = shouldShowSearchBar ? 16 : 8
    }
    
    public func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        contentView.emptyView.isHidden = !items.isEmpty
        datasource.display(sections: items)
        let selectedItemsCount = items.flatMap(\.cells).filter { $0.cell.isSelected.get() == true }.count
        contentView.selectButton.setTitle("\(selectedCountTitle)\(selectedItemsCount == 0 ? "" : " (\(selectedItemsCount))")", for: .normal)
    }
}

extension SelectionVC {
    typealias Datasource = DiffableTableViewDataSource<Void, SelectionType.SelectionCellPresentableModel, Void>
    
    func makeDatasource() -> Datasource {
        let datasource = Datasource(
            tableView: contentView.tableView,
            configureCell: { tableView, indexPath, model in
                let cell: SelectionCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = model
                return cell
            }
        )
        
        datasource.didScrollViewDidScroll = { [weak self] scrollView in
            guard let self = self,
                  !self.contentView.searchBar.isHidden,
                  !self.contentView.searchBar.textfield.isFirstResponder,
                  scrollView.contentOffset.y > 0 || (scrollView.refreshControl?.isRefreshing ?? false) else { return } // Fix for refreshControl

            let isNearBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
            guard !isNearBottom else { return }
            
            // Determine scroll direction
            let offset = scrollView.contentOffset.y - self.currentContentYOffset
            let currentTopConstant = self.contentView.searchBarConstraints?.top?.constant ?? 0

            // Compute new top constant
            let newTopConstant = offset >= 0
                ? max(-SelectionContentView.searchBarHeight, currentTopConstant - offset) // Hide
                : min(SelectionContentView.maxSearchBarTopSpacing, currentTopConstant - offset) // Show

            // Ensure correct behavior when refreshControl is active
            if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
                self.showSearchBar()
                return
            }

            // Update searchBar constraints and alpha
            self.contentView.searchBarConstraints?.top?.constant = newTopConstant
            let visibilityProgress = (newTopConstant + SelectionContentView.searchBarHeight) / SelectionContentView.searchBarHeight
            self.contentView.searchBar.alpha = min(1, max(0, visibilityProgress))

            // Store last offset for next calculation
            self.currentContentYOffset = scrollView.contentOffset.y
        }

        // Ensure final positioning when scrolling stops
        datasource.didScrollViewDidEndDragging = { [weak self] scrollView, decelerate in
            guard scrollView.contentOffset.y > 0 else {
                self?.showSearchBar()
                return
            }

            if scrollView.refreshControl?.isRefreshing == true {
                self?.showSearchBar() // Keep search bar visible when refreshing
            } else if !decelerate {
                self?.finalizeSearchBarPosition()
            }
        }

        datasource.didScrollViewDidEndDecelerating = { [weak self] scrollView in
            guard scrollView.contentOffset.y > 0 else {
                self?.showSearchBar()
                return
            }

            if scrollView.refreshControl?.isRefreshing == true {
                self?.showSearchBar()
            } else {
                self?.finalizeSearchBarPosition()
            }
        }
        return datasource
    }
    
    private func finalizeSearchBarPosition() {
        let currentTopConstant = contentView.searchBarConstraints?.top?.constant ?? 0
        let threshold = -SelectionContentView.searchBarHeight / 2

        let shouldHide = currentTopConstant < threshold
        let finalTopConstant = shouldHide ? -SelectionContentView.searchBarHeight : SelectionContentView.maxSearchBarTopSpacing
        let finalAlpha = shouldHide ? 0 : 1

            contentView.searchBarConstraints?.top?.constant = finalTopConstant
            contentView.searchBar.alpha = CGFloat(finalAlpha)
            view.layoutIfNeeded()
    }

    // Show search bar explicitly when refresh starts
    private func showSearchBar(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.1 : 0) { [weak self] in
            self?.contentView.searchBarConstraints?.top?.constant = SelectionContentView.maxSearchBarTopSpacing
            self?.contentView.searchBar.alpha = 1
            self?.view.layoutIfNeeded()
        }
    }
}
#endif
