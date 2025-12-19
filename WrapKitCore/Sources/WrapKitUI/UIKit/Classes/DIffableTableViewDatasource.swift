import Foundation

public enum TableEditingStyle {
    case delete
    case insert
    case none
}

public struct TableContextualAction<Cell> {
    public enum Style {
        case normal
        case destructive
    }
    let style: Style
    let backgroundColor: Color?
    let image: Image?
    let title: String?
    let onPress: ((Cell) -> Void)?

    public init(
        style: Style = .normal,
        backgroundColor: Color? = nil,
        image: Image? = nil,
        title: String? = nil,
        onPress: ((Cell) -> Void)? = nil
    ) {
        self.style = style
        self.backgroundColor = backgroundColor
        self.image = image
        self.title = title
        self.onPress = onPress
    }
}

public struct CellModel<Cell: Hashable>: HashableWithReflection {

    public let id: UUID
    public let cell: Cell
    public let onTap: ((IndexPath, Cell) -> Void)?

    public init(
        id: UUID = UUID(),
        cell: Cell,
        onTap: ((IndexPath, Cell) -> Void)? = nil
    ) {
        self.id = id
        self.cell = cell
        self.onTap = onTap
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension CellModel {
    func duplicatedForEndless() -> CellModel<Cell> {
        CellModel(
            id: UUID(),          // 👈 НОВЫЙ UUID
            cell: self.cell,     // тот же контент
            onTap: self.onTap
        )
    }
}

public struct TableSection<Header, Cell: Hashable, Footer>: HashableWithReflection {
    public var header: Header?
    public var cells: [CellModel<Cell>]
    public var footer: Footer?
    public var carouselConfig: CarouselConfig?

    public init(
        header: Header? = nil,
        cells: [CellModel<Cell>],
        footer: Footer? = nil,
        carouselConfig: CarouselConfig? = nil
    ) {
        self.header = header
        self.cells = cells
        self.footer = footer
        self.carouselConfig = carouselConfig
    }
}

public protocol TableOutput<Header, Cell, Footer>: AnyObject {
    associatedtype Header
    associatedtype Cell: Hashable
    associatedtype Footer
    func display(sections: [TableSection<Header, Cell, Footer>])
    func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
    func display(expandTrailingActionsAt indexPath: IndexPath)
    func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
    func display(move: ((IndexPath, IndexPath) -> Void)?)
    func display(canMove: ((IndexPath) -> Bool)?)
    func display(canEdit: ((IndexPath) -> Bool)?)
    func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?)
}

#if canImport(UIKit)
import Foundation
import UIKit

public class DiffableTableViewDataSource<Header, Cell: Hashable, Footer>: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
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
    private var moveHandler: ((IndexPath, IndexPath) -> Void)?
    private var canMoveHandler: ((IndexPath) -> Bool)?
    private var canEditHandler: ((IndexPath) -> Bool)?
    private var commitEditingHandler: ((TableEditingStyle, IndexPath) -> Void)?
    private var trailingSwipeActionsConfigurationForRowAt: ((IndexPath) -> UISwipeActionsConfiguration?)?
    private var leadingSwipeActionsConfigurationForRowAt: ((IndexPath) -> UISwipeActionsConfiguration?)?
    
    private var sections: [TableSection<Header, Cell, Footer>] = []
    
    // MARK: - Initializer
    public init(tableView: UITableView, configureCell: ((UITableView, IndexPath, Cell) -> UITableViewCell)?) {
        self.tableView = tableView
        self.configureCell = configureCell
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - UITableViewDataSource Methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.item(at: section)?.cells.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellModel = sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.cell else {
            return UITableViewCell()
        }
        return configureCell?(tableView, indexPath, cellModel) ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMoveHandler?(indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveHandler?(sourceIndexPath, destinationIndexPath)
        // Update internal data structure
        guard let sourceSection = sections.item(at: sourceIndexPath.section),
              let cell = sourceSection.cells.item(at: sourceIndexPath.row) else { return }
        
        sections[sourceIndexPath.section].cells.remove(at: sourceIndexPath.row)
        if sections.count <= destinationIndexPath.section {
            sections.append(TableSection(cells: []))
        }
        sections[destinationIndexPath.section].cells.insert(cell, at: destinationIndexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditHandler?(indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let customStyle: TableEditingStyle
        switch editingStyle {
        case .delete:
            customStyle = .delete
        case .insert:
            customStyle = .insert
        default:
            customStyle = .none
        }
        commitEditingHandler?(customStyle, indexPath)
    }
    
    // MARK: - UITableViewDelegate Methods
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return trailingSwipeActionsConfigurationForRowAt?(indexPath) ?? .init(actions: [])
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return leadingSwipeActionsConfigurationForRowAt?(indexPath) ?? .init(actions: [])
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt?(indexPath) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedModel = sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.cell else { return }
        sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.onTap?(indexPath, selectedModel)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
        
        guard scrollView.isDragging else { return }
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

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
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let model = sections.item(at: section)?.header else { return UIView() }
        return viewForHeaderInSection?(tableView, section, model) ?? UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let model = sections.item(at: section)?.header else { return .leastNonzeroMagnitude }
        return heightForHeaderInSection?(section, model) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let model = sections.item(at: section)?.footer else { return UIView() }
        return viewForFooterInSection?(tableView, section, model) ?? UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let model = sections.item(at: section)?.footer else { return .leastNonzeroMagnitude }
        return heightForFooterInSection?(section, model) ?? UITableView.automaticDimension
    }
    
    deinit {
        configureCell = nil
        viewForHeaderInSection = nil
        heightForHeaderInSection = nil
        viewForFooterInSection = nil
        heightForFooterInSection = nil
        heightForRowAt = nil
        didScrollViewDidScroll = nil
        didScrollViewDidEndDragging = nil
        didScrollViewDidEndDecelerating = nil
        loadNextPage = nil
    }
}

// MARK: - TableOutput Conformance
extension DiffableTableViewDataSource: TableOutput & HiddableOutput {
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        guard let cell = tableView?.cellForRow(at: indexPath) else { return }
        
        // Cancel any existing swipes
        tableView?.perform(Selector(("_endSwipeToDeleteRowDidDelete:")), with: nil)
        
        // Trigger the swipe (this is the private method for trailing/delete-style swipe)
        tableView?.perform(Selector(("_swipeToDeleteCell:")), with: cell)
    }
    
    public func display(isHidden: Bool) {
        tableView?.isHidden = isHidden
    }
    
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        self.leadingSwipeActionsConfigurationForRowAt = { [weak self] indexPath in
            let contextualActions = leadingSwipeActionsForIndexPath?(indexPath).map { action in
                let uiAction = UIContextualAction(
                    style: action.style.asUIContextualActionStyle,
                    title: action.title
                ) { [weak self] _, _, completion in
                    guard let self = self,
                          let model = self.sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.cell else {
                        completion(false)
                        return
                    }
                    action.onPress?(model)
                    completion(true)
                }
                if let backgroundColor = action.backgroundColor {
                    uiAction.backgroundColor = backgroundColor
                }
                if let image = action.image {
                    uiAction.image = image
                }
                return uiAction
            } ?? [UIContextualAction]()
            let configuration = UISwipeActionsConfiguration(actions: contextualActions)
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
    }
    
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        self.trailingSwipeActionsConfigurationForRowAt = { [weak self] indexPath in
            let contextualActions = trailingSwipeActionsForIndexPath?(indexPath).map { action in
                let uiAction = UIContextualAction(
                    style: action.style.asUIContextualActionStyle,
                    title: action.title
                ) { [weak self] _, _, completion in
                    guard let self = self,
                          let model = self.sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.cell else {
                        completion(false)
                        return
                    }
                    action.onPress?(model)
                    completion(true)
                }
                if let backgroundColor = action.backgroundColor {
                    uiAction.backgroundColor = backgroundColor
                }
                if let image = action.image {
                    uiAction.image = image
                }
                return uiAction
            } ?? [UIContextualAction]()
            let configuration = UISwipeActionsConfiguration(actions: contextualActions)
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
    }
    
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        self.sections = sections
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        self.moveHandler = move
    }
    
    public func display(canMove: ((IndexPath) -> Bool)?) {
        self.canMoveHandler = canMove
    }
    
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        self.canEditHandler = canEdit
    }
    
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        self.commitEditingHandler = commitEditing
    }
}

private extension TableContextualAction.Style {
    var asUIContextualActionStyle: UIContextualAction.Style {
        switch self {
        case .destructive: .destructive
        case .normal: .normal
        }
    }
}
#endif
