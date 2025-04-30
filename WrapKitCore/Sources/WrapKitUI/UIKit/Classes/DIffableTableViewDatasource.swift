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

public struct TableContextualAction {
    public enum Style {
        case normal
        case destructive
    }
    let style: Style
    let backgroundColor: Color?
    let image: Image?
    let title: String?
    let onPress: (() -> Void)?
    
    public init(
        style: Style = .normal,
        backgroundColor: Color? = .clear,
        image: Image? = nil,
        title: String? = nil,
        onPress: (() -> Void)? = nil
    ) {
        self.style = style
        self.backgroundColor = backgroundColor
        self.image = image
        self.title = title
        self.onPress = onPress
    }
}

public protocol TableOutput<Header, Cell, Footer>: AnyObject {
    associatedtype Header
    associatedtype Cell: Hashable
    associatedtype Footer
    func display(sections: [TableSection<Header, Cell, Footer>])
    func display(actions: [TableContextualAction])
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
    class EditableDataSource: UITableViewDiffableDataSource<Int, Cell> {
        public var canEdit: ((IndexPath) -> Bool)?
        
        override func tableView(_ tableView: UITableView,
                                canEditRowAt indexPath: IndexPath) -> Bool {
            return canEdit?(indexPath) ?? false
        }
    }
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
    public var trailingSwipeActionsConfigurationForRowAt: ((IndexPath) -> UISwipeActionsConfiguration?)?
    public var canEditRowAtIndexPath: ((IndexPath) -> Bool)?
    
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
        let dataSource = EditableDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            self?.configureCell?(tableView, indexPath, item) ?? UITableViewCell()
        }
        dataSource.canEdit = canEditRowAtIndexPath
        dataSource.defaultRowAnimation = defaultRowAnimation
        self.dataSource = dataSource
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
    
    // MARK: - Actions
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return trailingSwipeActionsConfigurationForRowAt?(indexPath)
    }
}

extension DiffableTableViewDataSource {
    public func display(actions: [TableContextualAction]) {
        trailingSwipeActionsConfigurationForRowAt = { indexPath in
            let contextualActions = actions.map { action in
                let uiStyle: UIContextualAction.Style = action.style == .destructive ? .destructive : .normal
                let uiAction = UIContextualAction(style: uiStyle, title: action.title) { _, _, completion in
                    action.onPress?()
                    completion(true)
                }
                if let backgroundColor = action.backgroundColor {
                    uiAction.backgroundColor = backgroundColor
                }
                if let image = action.image {
                    uiAction.image = image
                }
                return uiAction
            }
            let configuration = UISwipeActionsConfiguration(actions: contextualActions)
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
    }
}
#endif
