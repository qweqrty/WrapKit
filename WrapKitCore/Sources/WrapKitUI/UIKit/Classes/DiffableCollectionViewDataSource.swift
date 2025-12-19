import Foundation
import UIKit

public struct CarouselConfig {
    public let isAutoscrollEnabled: Bool
    public let isEndlessScrollEnabled: Bool
    public let scrollInterval: TimeInterval
    public let pauseWhileDragging: Bool
    
    public init(
        isAutoscrollEnabled: Bool,
        isEndlessScrollEnabled: Bool,
        scrollInterval: TimeInterval = 3.0,
        pauseWhileDragging: Bool = true
    ) {
        self.isAutoscrollEnabled = isAutoscrollEnabled
        self.isEndlessScrollEnabled = isEndlessScrollEnabled
        self.scrollInterval = scrollInterval
        self.pauseWhileDragging = pauseWhileDragging
    }
}

private extension Array where Element: Hashable {
    var uniqued: [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

private enum ScrollState {
    case idle
    case dragging
    case auto
}

private enum EndlessEdge {
    case start
    case end
}

#if canImport(UIKit)
import UIKit

public final class DiffableCollectionViewDataSource<Header, Cell: Hashable, Footer>:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    TableOutput {
    public typealias Header = Header
    public typealias Cell = Cell
    public typealias Footer = Footer
    
    public var configureCell: ((UICollectionView, IndexPath, Cell) -> UICollectionViewCell)?
    public var viewForHeaderInSection: ((UICollectionView, Int, Header) -> UICollectionReusableView)?
    public var sizeForHeaderInSection: ((Int, Header) -> CGSize)?
    public var viewForFooterInSection: ((UICollectionView, Int, Footer) -> UICollectionReusableView)?
    public var sizeForFooterInSection: ((Int, Footer) -> CGSize)?
    public var minimumLineSpacingForSectionAt: ((Int) -> CGFloat) = { _ in 0 }
    public var sizeForItemAt: ((IndexPath) -> CGSize)?
    public var didScrollTo: ((IndexPath) -> Void)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didMoveItem: ((IndexPath, IndexPath) -> Void)?
    public var loadNextPage: (() -> Void)?
    public var showLoader = false
    
    private var scrollState: ScrollState = .idle
    private var isApplyingEndless = false
    private weak var collectionView: UICollectionView?
    private var headers = [Int: Header]()
    private var footers = [Int: Footer]()
    private var carouselConfigs = [Int: CarouselConfig]()
    private var scrollTimers: [Int: Timer] = [:]
    private var isJumping = false
    private var endlessTwoItemSections = Set<Int>()
    
    private var sections: [TableSection<Header, Cell, Footer>] = []
    
    // MARK: - Init
    public init(collectionView: UICollectionView,
                configureCell: @escaping (UICollectionView, IndexPath, Cell) -> UICollectionViewCell) {
        super.init()
        self.collectionView = collectionView
        self.configureCell = configureCell
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    deinit {
        invalidateAllTimers()
    }
    
    // MARK: - Display
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        self.sections = sections
        headers.removeAll()
        footers.removeAll()
        carouselConfigs.removeAll()
        endlessTwoItemSections.removeAll()
        
        var renderedSections: [TableSection<Header, Cell, Footer>] = []
        
        sections.enumerated().forEach { idx, section in
            headers[idx] = section.header
            footers[idx] = section.footer
            if let cfg = section.carouselConfig {
                carouselConfigs[idx] = cfg
            }
            
            renderedSections.append(prepareSectionForEndless(section, at: idx))
        }
        
        self.sections = renderedSections
        collectionView?.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.adjustInitialOffsets()
        }
        
        reconfigureAutoscrollTimers()
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        sections.item(at: section)?.cells.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = sections.item(at: indexPath.section)?.cells.item(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        return configureCell?(collectionView, indexPath, model.cell) ?? UICollectionViewCell()
    }
    
    // MARK: - Supplementary Views
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
           let header = headers[indexPath.section] {
            return viewForHeaderInSection?(collectionView, indexPath.section, header) ?? UICollectionReusableView()
        } else if kind == UICollectionView.elementKindSectionFooter,
                  let footer = footers[indexPath.section] {
            return viewForFooterInSection?(collectionView, indexPath.section, footer) ?? UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let model = sections.item(at: indexPath.section)?.cells.item(at: indexPath.item) else { return }
        model.onTap?(indexPath, model.cell)
    }
    
    // MARK: - Flow Layout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizeForItemAt?(indexPath)
        ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
        ?? UICollectionViewFlowLayout.automaticSize
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let model = headers[section] else { return .zero }
        return sizeForHeaderInSection?(section, model) ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let model = footers[section] else { return .zero }
        return sizeForFooterInSection?(section, model) ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacingForSectionAt(section)
    }
    
    // MARK: - ScrollView Delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
        guard let collectionView = scrollView as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              !isApplyingEndless
        else { return }

        let isHorizontal = layout.scrollDirection == .horizontal
        let offset = isHorizontal
            ? scrollView.contentOffset.x
            : scrollView.contentOffset.y

        let pageSize = isHorizontal
            ? collectionView.bounds.width
            : collectionView.bounds.height

        let maxOffset = pageSize * CGFloat(
            max(0, collectionView.numberOfItems(inSection: currentEndlessSection(collectionView)) - 1)
        )

        if offset < 0 {
            applyEndlessJump(to: .start, collectionView, isHorizontal, pageSize)
        } else if offset > maxOffset {
            applyEndlessJump(to: .end, collectionView, isHorizontal, pageSize)
        }
    }

    private func currentEndlessSection(_ collectionView: UICollectionView) -> Int {
        let center = CGPoint(
            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
            y: collectionView.contentOffset.y + collectionView.bounds.height / 2
        )
        return collectionView.indexPathForItem(at: center)?.section ?? 0
    }

    private func applyEndlessJump(
        to edge: EndlessEdge,
        _ collectionView: UICollectionView,
        _ horizontal: Bool,
        _ pageSize: CGFloat
    ) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
              let cfg = carouselConfigs[indexPath.section],
              cfg.isEndlessScrollEnabled
        else { return }

        let total = collectionView.numberOfItems(inSection: indexPath.section)
        guard total > 1 else { return }

        let targetItem: Int = {
            switch edge {
            case .start:
                return total / 2
            case .end:
                return total / 2 - 1
            }
        }()

        isApplyingEndless = true

        UIView.performWithoutAnimation {
            let offset = CGFloat(targetItem) * pageSize
            if horizontal {
                collectionView.contentOffset.x = offset
            } else {
                collectionView.contentOffset.y = offset
            }
        }

        DispatchQueue.main.async {
            self.isApplyingEndless = false
        }
    }

    // MARK: - Endless Scroll
    private func prepareSectionForEndless(_ section: TableSection<Header, Cell, Footer>, at index: Int) -> TableSection<Header, Cell, Footer> {
        guard let cfg = section.carouselConfig, cfg.isEndlessScrollEnabled else { return section }
        var copy = section
         let cells = section.cells

        guard cells.count >= 2 else {
            return section
        }
        
         let duplicated = cells.map { $0.duplicatedForEndless() }

         copy.cells = cells + duplicated
        
        return copy
    }
    
    private func adjustInitialOffsets() {
        guard let cv = collectionView,
              let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let pos: UICollectionView.ScrollPosition = layout.scrollDirection == .horizontal
        ? .centeredHorizontally
        : .centeredVertically
        
        for section in endlessTwoItemSections {
            UIView.performWithoutAnimation {
                cv.scrollToItem(at: IndexPath(item: 1, section: section), at: pos, animated: false)
            }
        }
    }
    
    // MARK: - Carousel Autoscroll
    private func reconfigureAutoscrollTimers() {
        invalidateAllTimers()
        
        for (section, config) in carouselConfigs where config.isAutoscrollEnabled {
            let timer = Timer.scheduledTimer(withTimeInterval: config.scrollInterval, repeats: true) { [weak self] _ in
                self?.scrollToNextItem(in: section, endless: config.isEndlessScrollEnabled)
            }
            scrollTimers[section] = timer
        }
    }
    
    private func invalidateAllTimers() {
        scrollTimers.values.forEach { $0.invalidate() }
        scrollTimers.removeAll()
    }
    
    private func pauseTimersIfNeeded() {
        for (section, config) in carouselConfigs where config.pauseWhileDragging {
            scrollTimers[section]?.fireDate = .distantFuture
        }
    }
    
    private func resumeTimersIfNeeded() {
        for (section, config) in carouselConfigs where config.pauseWhileDragging {
            scrollTimers[section]?.fireDate = Date().addingTimeInterval(config.scrollInterval)
        }
    }
    
    private func scrollToNextItem(in section: Int, endless: Bool) {
        guard let collectionView,
              scrollState == .idle,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }

        scrollState = .auto

        let pageSize = layout.scrollDirection == .horizontal
            ? collectionView.bounds.width
            : collectionView.bounds.height

        let offset = layout.scrollDirection == .horizontal
            ? collectionView.contentOffset.x
            : collectionView.contentOffset.y

        let page = Int(round(offset / pageSize))
        let total = collectionView.numberOfItems(inSection: section)

        let next = page + 1 < total ? page + 1 : (endless ? 0 : page)

        let targetOffset = CGFloat(next) * pageSize

        UIView.animate(withDuration: 0.3) {
            if layout.scrollDirection == .horizontal {
                collectionView.contentOffset.x = targetOffset
            } else {
                collectionView.contentOffset.y = targetOffset
            }
        }
    }
}

// MARK: TODO - segregate
public extension DiffableCollectionViewDataSource {
    func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {}
    func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {}
    func display(move: ((IndexPath, IndexPath) -> Void)?) {}
    func display(canMove: ((IndexPath) -> Bool)?) {}
    func display(canEdit: ((IndexPath) -> Bool)?) {}
    func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {}
    func display(expandTrailingActionsAt indexPath: IndexPath) {}
}
#endif
