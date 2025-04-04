import Foundation

public struct CellModel<Cell: Hashable>: HashableWithReflection {
    public let cell: Cell
    public let onTap: ((_ atIndexPath: IndexPath, _ model: Cell) -> Void)?
    
    public init(cell: Cell, onTap: ((_ atIndexPath: IndexPath, _ model: Cell) -> Void)? = nil) {
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

public protocol TableOutput<Header, Cell, Footer>: AnyObject {
    associatedtype Header
    associatedtype Cell: Hashable
    associatedtype Footer
    func display(sections: [TableSection<Header, Cell, Footer>])
}

extension DiffableTableViewDataSource: TableOutput {
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        DispatchQueue.global().async { [weak self] in
            self?.headers.removeAll()
            self?.footers.removeAll()
            
            sections.enumerated().forEach { offset, section in
                self?.headers[offset] = section.header
                self?.footers[offset] = section.footer
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateItems(sections.map { $0.cells.map(\.cell) })
                didSelectAt = { indexPath, cell in
                    sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.onTap?(indexPath, cell)
                }
                tableView?.reloadData()
            }
        }
    }
}

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
public class DiffableTableViewDataSource<Header, Cell: Hashable, Footer>: NSObject, UITableViewDelegate {
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
