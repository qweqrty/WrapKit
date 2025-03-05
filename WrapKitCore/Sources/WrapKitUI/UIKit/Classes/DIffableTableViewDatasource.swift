import Foundation

public protocol DiffableTableViewDataSourceOutput: AnyObject {
    associatedtype Model
    associatedtype SectionItem: Hashable

    func display(model: DiffableTableViewDataSourcePresentableModel<Model, SectionItem>?)
    func display(didSelectAt: ((IndexPath, Model) -> Void)?)
    func display(configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?)
    func display(configureFooter: (() -> UITableViewCell)?)
    func display(viewForHeaderInSection: ((UITableView, Int) -> UIView)?)
    func display(heightForHeaderInSection: ((Int) -> CGFloat)?)
    func display(onRetry: (() -> Void)?)
    func display(showLoader: Bool)
    func display(loadNextPage: (() -> Void)?)
    func display(heightForRowAt: ((IndexPath) -> CGFloat)?)
    func display(didScrollViewDidScroll: ((UIScrollView) -> Void)?)
    func display(didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?)
    func display(didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?)
    func display(defaultRowAnimation: UITableView.RowAnimation)
    func display(items: [Model]?, at section: SectionItem?)
    func display<Item: SectionedDiffableItem>(sectionedItems: [Item]?) where Item.SectionItem == SectionItem, Item.Model == Model
    func display(header: SectionItem?, forItems items: [Model]?)
}

public struct DiffableTableViewDataSourcePresentableModel<Model, SectionItem: Hashable> {
    public let didSelectAt: ((IndexPath, Model) -> Void)?
    public let configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?
    public let configureFooter: (() -> UITableViewCell)?
    public let viewForHeaderInSection: ((UITableView, Int) -> UIView)?
    public let heightForHeaderInSection: ((Int) -> CGFloat)?
    public let onRetry: (() -> Void)?
    public let showLoader: Bool
    public let loadNextPage: (() -> Void)?
    public let heightForRowAt: ((IndexPath) -> CGFloat)?
    public let didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public let didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?
    public let didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    public let defaultRowAnimation: UITableView.RowAnimation
    public let items: [Model]?
    public let sectionedItems: SectionItem?
    public let header: SectionItem?

    public init(
        didSelectAt: ((IndexPath, Model) -> Void)? = nil,
        configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)? = nil,
        configureFooter: (() -> UITableViewCell)? = nil,
        viewForHeaderInSection: ((UITableView, Int) -> UIView)? = nil,
        heightForHeaderInSection: ((Int) -> CGFloat)? = nil,
        onRetry: (() -> Void)? = nil,
        showLoader: Bool = false,
        loadNextPage: (() -> Void)? = nil,
        heightForRowAt: ((IndexPath) -> CGFloat)? = nil,
        didScrollViewDidScroll: ((UIScrollView) -> Void)? = nil,
        didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)? = nil,
        didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)? = nil,
        defaultRowAnimation: UITableView.RowAnimation = .fade,
        items: [Model]? = nil,
        sectionedItems: SectionItem? = nil,
        header: SectionItem? = nil
    ) {
        self.didSelectAt = didSelectAt
        self.configureCell = configureCell
        self.configureFooter = configureFooter
        self.viewForHeaderInSection = viewForHeaderInSection
        self.heightForHeaderInSection = heightForHeaderInSection
        self.onRetry = onRetry
        self.showLoader = showLoader
        self.loadNextPage = loadNextPage
        self.heightForRowAt = heightForRowAt
        self.didScrollViewDidScroll = didScrollViewDidScroll
        self.didScrollViewDidEndDragging = didScrollViewDidEndDragging
        self.didScrollViewDidEndDecelerating = didScrollViewDidEndDecelerating
        self.defaultRowAnimation = defaultRowAnimation
        self.items = items
        self.sectionedItems = sectionedItems
        self.header = header
    }
}

#if canImport(UIKit)
import UIKit

extension DiffableTableViewDataSource: DiffableTableViewDataSourceOutput {
    public func display(model: DiffableTableViewDataSourcePresentableModel<Model, SectionItem>?) {
        guard let model else { return }
        display(didSelectAt: model.didSelectAt)
        display(configureCell: model.configureCell)
        display(configureFooter: model.configureFooter)
        display(viewForHeaderInSection: model.viewForHeaderInSection)
        display(heightForHeaderInSection: model.heightForHeaderInSection)
        display(onRetry: model.onRetry)
        display(showLoader: model.showLoader)
        display(loadNextPage: model.loadNextPage)
        display(heightForRowAt: model.heightForRowAt)
        display(didScrollViewDidScroll: model.didScrollViewDidScroll)
        display(didScrollViewDidEndDragging: model.didScrollViewDidEndDragging)
        display(didScrollViewDidEndDecelerating: model.didScrollViewDidEndDecelerating)
        display(defaultRowAnimation: model.defaultRowAnimation)
        display(items: model.items, at: model.sectionedItems)
    }
    
    public func display(didSelectAt: ((IndexPath, Model) -> Void)?) {
        self.didSelectAt = didSelectAt
    }

    public func display(configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?) {
        self.configureCell = configureCell
    }

    public func display(configureFooter: (() -> UITableViewCell)?) {
        self.configureFooter = configureFooter
    }

    public func display(viewForHeaderInSection: ((UITableView, Int) -> UIView)?) {
        self.viewForHeaderInSection = viewForHeaderInSection
    }

    public func display(heightForHeaderInSection: ((Int) -> CGFloat)?) {
        self.heightForHeaderInSection = heightForHeaderInSection
    }

    public func display(onRetry: (() -> Void)?) {
        self.onRetry = onRetry
    }

    public func display(showLoader: Bool) {
        self.showLoader = showLoader
    }

    public func display(loadNextPage: (() -> Void)?) {
        self.loadNextPage = loadNextPage
    }

    public func display(heightForRowAt: ((IndexPath) -> CGFloat)?) {
        self.heightForRowAt = heightForRowAt
    }

    public func display(didScrollViewDidScroll: ((UIScrollView) -> Void)?) {
        self.didScrollViewDidScroll = didScrollViewDidScroll
    }

    public func display(didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?) {
        self.didScrollViewDidEndDragging = didScrollViewDidEndDragging
    }

    public func display(didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?) {
        self.didScrollViewDidEndDecelerating = didScrollViewDidEndDecelerating
    }

    public func display(defaultRowAnimation: UITableView.RowAnimation) {
        self.defaultRowAnimation = defaultRowAnimation
    }

    public func display(items: [Model]?, at section: SectionItem?) {
        guard let items, let section else { return }
        updateItems(items, at: section)
    }

    public func display<Item: SectionedDiffableItem>(sectionedItems: [Item]?) where Item.SectionItem == SectionItem, Item.Model == Model {
        guard let sectionedItems else { return }
        updateSectionedItems(sectionedItems)
    }

    public func display(header: SectionItem?, forItems items: [Model]?) {
        guard let items, let header else { return }
        updateItems(items, at: header)
    }
}

public protocol SectionedDiffableItem: Hashable {
    associatedtype SectionItem: Hashable
    associatedtype Model: Hashable
    var header: SectionItem { get set }
    var cells: [Model] { get set }
}

@available(iOS 13.0, *)
public class DiffableTableViewDataSource<SectionItem: Hashable, Model: Hashable>: NSObject, UITableViewDelegate {
    public enum TableItem: Hashable {
        case model(Model)
        case footer(UUID)
    }
    
    // MARK: - Properties
    public var didSelectAt: ((IndexPath, Model) -> Void)?
    public var configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?
    public var configureFooter: (() -> UITableViewCell)?
    public var viewForHeaderInSection: ((UITableView, Int) -> UIView)?
    public var heightForHeaderInSection: ((Int) -> CGFloat)?
    public var onRetry: (() -> Void)?
    public var showLoader = false
    public var loadNextPage: (() -> Void)?
    public var heightForRowAt: ((IndexPath) -> CGFloat)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?
    public var didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    
    private weak var tableView: UITableView?
    private var dataSource: UITableViewDiffableDataSource<SectionItem, TableItem>!
    
    public var defaultRowAnimation: UITableView.RowAnimation = .fade {
        didSet {
            dataSource.defaultRowAnimation = defaultRowAnimation
        }
    }
    
    // MARK: - Initializer
    public init(tableView: UITableView, configureCell: @escaping (UITableView, IndexPath, Model) -> UITableViewCell) {
        super.init()
        self.tableView = tableView
        self.configureCell = configureCell
        setupDataSource(for: tableView)
    }
    
    // MARK: - Setup Data Source
    private func setupDataSource(for tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<SectionItem, TableItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            switch item {
            case .footer:
                return self?.configureFooter?() ?? UITableViewCell()
            case .model(let model):
                return self?.configureCell?(tableView, indexPath, model) ?? UITableViewCell()
            }
        }
        dataSource.defaultRowAnimation = defaultRowAnimation
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    
    // MARK: - Snapshot Management
    public func updateItems(_ items: [Model], at section: SectionItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            let uniqueItems = items.uniqued
            DispatchQueue.main.async { [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<SectionItem, TableItem>()
                snapshot.appendSections([section])
                snapshot.appendItems(uniqueItems.map { .model($0) }, toSection: section)
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    public func updateSectionedItems<Item: SectionedDiffableItem>(_ items: [Item]) where Item.SectionItem == SectionItem, Item.Model == Model {
        DispatchQueue.global(qos: .userInitiated).async {
            let uniqueItems = items.uniqued
            DispatchQueue.main.async { [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<SectionItem, TableItem>()
                let headers = uniqueItems.map { $0.header }.uniqued
                snapshot.appendSections(headers)
                uniqueItems.forEach { item in
                    snapshot.appendItems(item.cells.uniqued.map { .model($0) }, toSection: item.header)
                }
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt?(indexPath) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard case .model(let selectedModel) = dataSource.itemIdentifier(for: indexPath) else { return }
        didSelectAt?(indexPath, selectedModel)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
        
        guard scrollView.isDragging else { return }
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        // Load next page if near the bottom of table view
        if position > contentHeight - scrollViewHeight * 2 && showLoader {
            loadNextPage?()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didScrollViewDidEndDragging?(scrollView, decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollViewDidEndDecelerating?(scrollView)
    }
    
    // MARK: - Header/Footer Views
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeaderInSection?(tableView, section) ?? UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection?(section) ?? .leastNonzeroMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension DiffableTableViewDataSource where SectionItem == Int {
    public func updateItems(_ items: [Model], at section: Int = 0) {
        DispatchQueue.global(qos: .userInitiated).async {
            let uniqueItems = items.uniqued
            DispatchQueue.main.async { [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<SectionItem, TableItem>()
                snapshot.appendSections([section])
                snapshot.appendItems(uniqueItems.map { .model($0) }, toSection: section)
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
    }
}

extension DiffableTableViewDataSource where SectionItem == Int {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard case .model(let selectedModel) = dataSource.snapshot().itemIdentifiers(inSection: indexPath.section).item(at: indexPath.row) else { return }
        didSelectAt?(indexPath, selectedModel)
    }
}

#endif
