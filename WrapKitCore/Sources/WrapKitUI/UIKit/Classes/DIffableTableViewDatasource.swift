import Foundation

public protocol DiffableDataSourceOutput: AnyObject {
    associatedtype Model: Hashable
    associatedtype SectionItem: Hashable

    func display(model: [DiffableDataSourcePresentableModel<Model>], at section: SectionItem)
    func display(onRetry: (() -> Void)?)
    func display(showLoader: Bool)
    func display(loadNextPage: (() -> Void)?)
}

public protocol HeaderDiffableDataSourceOutput: AnyObject {
    associatedtype HeaderItem: Hashable
    associatedtype HeaderSectionItem: Hashable

    func display(header: HeaderItem?, section: HeaderSectionItem?)
}

public protocol FooterDiffableDataSourceOutput: AnyObject {
    associatedtype FooterItem: Hashable
    associatedtype FooterSectionItem: Hashable
    
    func display(footer: FooterItem?, section: FooterSectionItem?)
}

public struct DiffableDataSourcePresentableModel<Model: Hashable>: Hashable {
    public let onTap: (() -> Void)?
    public let model: Model
    
    public static func == (lhs: DiffableDataSourcePresentableModel<Model>, rhs: DiffableDataSourcePresentableModel<Model>) -> Bool {
        return lhs.model == rhs.model
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(model)
    }
}

#if canImport(UIKit)
import UIKit

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
        guard let snapshot = dataSource?.snapshot(),
              section < snapshot.numberOfSections,
              let sectionItem = snapshot.sectionIdentifiers[safe: section] else {
            return UIView()
        }
        
        if let footerCell = configureFooter?() {
            let containerView = UIView()
            containerView.addSubview(footerCell)
            footerCell.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                footerCell.topAnchor.constraint(equalTo: containerView.topAnchor),
                footerCell.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                footerCell.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                footerCell.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            return containerView
        }
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

extension DiffableTableViewDataSource: DiffableDataSourceOutput {
    public func display(model: [DiffableDataSourcePresentableModel<Model>], at section: SectionItem) {
        self.updateItems(model.map { $0.model }, at: section)
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
}

extension DiffableTableViewDataSource: HeaderDiffableDataSourceOutput {
    public typealias HeaderItem = Model
    public typealias HeaderSectionItem = SectionItem
    
    public func display(header: HeaderItem?, section: HeaderSectionItem?) {
        self.viewForHeaderInSection = { [weak self] tableView, sectionIndex in
            guard let self = self,
                  let snapshot = self.dataSource?.snapshot(),
                  sectionIndex < snapshot.numberOfSections,
                  let sectionItem = snapshot.sectionIdentifiers[safe: sectionIndex],
                  sectionItem == section else {
                return UIView()
            }
            
            if let headerModel = header {
                let headerView = UIView()
                return headerView
            }
            return UIView()
        }
        
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
}

extension DiffableTableViewDataSource: FooterDiffableDataSourceOutput {
    public typealias FooterItem = Model
    public typealias FooterSectionItem = SectionItem
    
    public func display(footer: FooterItem?, section: FooterSectionItem?) {
        self.configureFooter = { [weak self] in
            guard let self = self else { return UITableViewCell() }
            
            if let footerModel = footer {
                let cell = UITableViewCell()
                return cell
            }
            return UITableViewCell()
        }
        
        if let footer = footer, let section = section {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                
                if !snapshot.sectionIdentifiers.contains(section) {
                    snapshot.appendSections([section])
                }
                
                let footerIdentifier = TableItem.footer(UUID())
                if !snapshot.itemIdentifiers(inSection: section).contains(footerIdentifier) {
                    snapshot.appendItems([footerIdentifier], toSection: section)
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#endif
