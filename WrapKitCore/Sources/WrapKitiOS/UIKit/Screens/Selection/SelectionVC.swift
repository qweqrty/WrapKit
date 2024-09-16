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
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    private func updateSearchBarHeight(to height: CGFloat) {
        guard self.contentView.searchBarConstraints?.height?.constant != height else { return }
        self.contentView.searchBarConstraints?.height?.constant = height
        UIView.animate(withDuration: 0.1) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    private func fixSearchBarHeight(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset <= 0 {
            self.contentView.searchBarConstraints?.height?.constant = 44
        } else {
            self.contentView.searchBarConstraints?.height?.constant = 0
        }

        UIView.animate(withDuration: 0.1) {
            self.contentView.layoutIfNeeded()
        }
    }
}

extension SelectionVC: SelectionServiceDecoratorOutput {
    
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
        
        datasource.didScrollViewDidScroll = { [weak self] scrollView in
            guard let self = self, !self.contentView.searchBar.isHidden else { return }
            let currentOffsetY = scrollView.contentOffset.y
            let delta = currentOffsetY - self.currentContentYOffset

            let isAtTop = currentOffsetY <= 0
            let isAtBottom = currentOffsetY >= (scrollView.contentSize.height - scrollView.frame.size.height - 10)
            let targetHeight: CGFloat = (delta > 0 && !isAtTop) || isAtBottom ? 0 : 44

            self.updateSearchBarHeight(to: targetHeight)
            self.currentContentYOffset = currentOffsetY
        }

        datasource.didScrollViewDidEndDragging = { [weak self] scrollView, willDecelerate in
            guard let self = self else { return }
            if !willDecelerate {
                self.fixSearchBarHeight(scrollView: scrollView)
            }
        }

        datasource.didScrollViewDidEndDecelerating = { [weak self] scrollView in
            guard let self = self else { return }
            self.fixSearchBarHeight(scrollView: scrollView)
        }

        return datasource
    }
}

extension SelectionVC: ScrollableBottomSheetPresentedController {
    public var scrollView: UIScrollView? { contentView.tableView }
}
#endif

//
//  DIffableTableViewDatasource.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

#if canImport(UIKit)

@available(iOS 13.0, *)
public class DiffableTableViewDataSource<Model: Hashable>: NSObject, UITableViewDelegate {
    public enum TableItem: Hashable {
        case model(Model)
        case footer(UUID)
    }
    
    public var didSelectAt: ((IndexPath, Model) -> Void)?
    public var configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?
    public var configureFooter: (() -> UITableViewCell)?
    public var onRetry: (() -> Void)?
    public var showLoader = false {
        didSet {
            updateSnapshot()
        }
    }
    public var loadNextPage: (() -> Void)?
    public var heightForRowAt: ((IndexPath) -> CGFloat)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?
    public var didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    
    private weak var tableView: UITableView?
    private var dataSource: UITableViewDiffableDataSource<Int, TableItem>!
    private var items = [Model]()
    
    public init(tableView: UITableView, configureCell: @escaping (UITableView, IndexPath, Model) -> UITableViewCell) {
        super.init()
        self.tableView = tableView
        self.configureCell = configureCell
        setupDataSource(for: tableView)
    }
    
    private func setupDataSource(for tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Int, TableItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            switch item {
            case .footer:
                return self?.configureFooter?() ?? UITableViewCell()
            case .model(let model):
                return self?.configureCell?(tableView, indexPath, model) ?? UITableViewCell()
            }
        }
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    private func updateSnapshot() {
        DispatchQueue.main.async {
            let numberOfSections = self.dataSource.snapshot().numberOfSections
            var snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>()
            snapshot.appendSections([0])
            if numberOfSections > 0 {
                snapshot.appendItems(self.dataSource.snapshot().itemIdentifiers(inSection: 0), toSection: 0)
            }
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    public func updateItems(_ items: [Model]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let uniqueItems = items.uniqued
            DispatchQueue.main.async {
                self.items = uniqueItems
                var snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>()
                snapshot.appendSections([0])
                snapshot.appendItems(uniqueItems.map { .model($0) }, toSection: 0)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt?(indexPath) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemCount = tableView.numberOfRows(inSection: 0)
        let thresholdIndex = itemCount - 1
        
        if indexPath.row == thresholdIndex, showLoader {
            loadNextPage?()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedModel = items.item(at: indexPath.row) else { return }
        didSelectAt?(indexPath, selectedModel)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didScrollViewDidEndDragging?(scrollView, decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollViewDidEndDecelerating?(scrollView)
    }
}
#endif
