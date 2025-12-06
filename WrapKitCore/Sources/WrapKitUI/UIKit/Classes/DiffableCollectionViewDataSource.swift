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

    private weak var collectionView: UICollectionView?
    private var headers = [Int: Header]()
    private var footers = [Int: Footer]()
    private var carouselConfigs = [Int: CarouselConfig]()
    private var scrollTimers: [Int: Timer] = [:]
    
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
        
        sections.enumerated().forEach { idx, section in
            headers[idx] = section.header
            footers[idx] = section.footer
            if let cfg = section.carouselConfig {
                carouselConfigs[idx] = cfg
            }
        }
        
        collectionView?.reloadData()
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
        
        guard let collectionView = scrollView as? UICollectionView else { return }
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            didScrollTo?(indexPath)
        }
        
        guard scrollView.isDragging else { return }
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        if position > contentHeight - scrollViewHeight * 2 && showLoader {
            loadNextPage?()
        }
        
        if scrollView.isDragging {
            pauseTimersIfNeeded()
        } else {
            resumeTimersIfNeeded()
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
        guard let collectionView = self.collectionView else { return }
        
        let total = collectionView.numberOfItems(inSection: section)
        guard total > 1 else { return }
        
        let visibleInSection = collectionView.indexPathsForVisibleItems
            .filter { $0.section == section }
            .sorted { $0.item < $1.item }
        
        guard let current = visibleInSection.first else { return }
        
        let nextItem = current.item + 1
        let targetIndexPath: IndexPath
        if nextItem >= total {
            guard endless else { return }
            targetIndexPath = IndexPath(item: 0, section: section)
        } else {
            targetIndexPath = IndexPath(item: nextItem, section: section)
        }
        
        let scrollPosition: UICollectionView.ScrollPosition = {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
               layout.scrollDirection == .horizontal {
                return .centeredHorizontally
            } else {
                return .centeredVertically
            }
        }()
        
        collectionView.scrollToItem(at: targetIndexPath, at: scrollPosition, animated: true)
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
