import Foundation

public protocol SectionedDiffableItem: Hashable {
    associatedtype SectionItem: Hashable
    associatedtype Model: Hashable
    var header: SectionItem { get set }
    var cells: [Model] { get set }
}

#if canImport(UIKit)
import UIKit

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

public struct CellModel<Cell: Hashable>: HashableWithReflection {
    public let cell: Cell
    public let onTap: (() -> Void)?
    
    public init(cell: Cell, onTap: (() -> Void)? = nil) {
        self.cell = cell
        self.onTap = onTap
    }
}

public struct TableSection<Header, Cell: Hashable, Footer>: HashableWithReflection {
    public var header: Header?
    public var cells: [CellModel<Cell>]
    public var footer: Footer?
    
    public init(header: Header? = nil, cells: [CellModel<Cell>], footer: Footer? = nil) {
        self.header = header
        self.cells = cells
        self.footer = footer
    }
}

public protocol TableOutput<Header, Cell, Footer> {
    associatedtype Header
    associatedtype Cell: Hashable
    associatedtype Footer
    func display(sections: [TableSection<Header, Cell, Footer>])
}

extension DiffableTableViewDataSource1: TableOutput {
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        headers.removeAll()
        footers.removeAll()
        sections.enumerated().forEach { offset, section in
            headers[offset] = section.header
            footers[offset] = section.footer
        }
        updateItems(sections.map { $0.cells.map(\.cell) })
        didSelectAt = { [weak self] indexPath, cell in
            guard let self = self else { return }
            sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.onTap?()
        }
        tableView?.reloadData()
    }
}

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
public class DiffableTableViewDataSource1<Header, Cell: Hashable, Footer>: NSObject, UITableViewDelegate {
    // MARK: - Properties
    public var didSelectAt: ((IndexPath, Cell) -> Void)?
    public var configureCell: ((UITableView, IndexPath, Cell) -> UITableViewCell)?
    public var viewForHeaderInSection: ((UITableView, _ atSection: Int, _ header: Header) -> UIView)?
    public var heightForHeaderInSection: ((_ atSection: Int, _ model: Header) -> CGFloat)?
    public var viewForFooterInSection: ((UITableView, Int, Footer) -> UIView)?
    public var heightForFooterInSection: ((_ atSection: Int, _ model: Footer) -> CGFloat)?
    public var heightForRowAt: ((IndexPath) -> CGFloat)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didScrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?
    public var didScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    
    public var showLoader = false
    public var loadNextPage: (() -> Void)?
    
    private weak var tableView: UITableView?
    private var dataSource: UITableViewDiffableDataSource<Int, Cell>!
    
    public var defaultRowAnimation: UITableView.RowAnimation = .fade {
        didSet {
            dataSource.defaultRowAnimation = defaultRowAnimation
        }
    }
    
    var headers = [Int: Header]()
    var footers = [Int: Footer]()
    
    // MARK: - Initializer
    public init(tableView: UITableView, configureCell: @escaping (UITableView, IndexPath, Cell) -> UITableViewCell) {
        super.init()
        self.tableView = tableView
        self.configureCell = configureCell
        setupDataSource(for: tableView)
    }
    
    // MARK: - Setup Data Source
    private func setupDataSource(for tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Int, Cell>(tableView: tableView) { [weak self] tableView, indexPath, item in
            self?.configureCell?(tableView, indexPath, item) ?? UITableViewCell()
        }
        dataSource.defaultRowAnimation = defaultRowAnimation
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    // MARK: - Snapshot Management
    public func updateItems(_ items: [[Cell]]) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Cell>()
            let items = items.enumerated()
            snapshot.appendSections(items.map(\.offset))
            items.forEach { offset, element in
                let uniqueItems = element.uniqued
                snapshot.appendItems(uniqueItems, toSection: offset)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt?(indexPath) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedModel = dataSource.itemIdentifier(for: indexPath) else { return }
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
        guard let model = headers[section] else { return UIView() }
        return viewForHeaderInSection?(tableView, section, model) ?? UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let model = headers[section] else { return .leastNonzeroMagnitude }
        return heightForHeaderInSection?(section, model) ?? .leastNonzeroMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let model = footers[section] else { return UIView() }
        return viewForFooterInSection?(tableView, section, model) ?? UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let model = footers[section] else { return .leastNonzeroMagnitude }
        return heightForFooterInSection?(section, model) ?? .leastNonzeroMagnitude
    }
}

#endif
