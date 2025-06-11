import Foundation
import UIKit

public struct CarouselConfig {
    public let isAutoscrollEnabled: Bool
    public let isEndlessScrollEnabled: Bool
    public let scrollInterval: TimeInterval

    public init(isAutoscrollEnabled: Bool, isEndlessScrollEnabled: Bool, scrollInterval: TimeInterval = 3.0) {
        self.isAutoscrollEnabled = isAutoscrollEnabled
        self.isEndlessScrollEnabled = isEndlessScrollEnabled
        self.scrollInterval = scrollInterval
    }
}

@available(iOS 13.0, *)
extension DiffableCollectionViewDataSource: TableOutput {
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {}
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {}
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {}
    public func display(canMove: ((IndexPath) -> Bool)?) {}
    public func display(canEdit: ((IndexPath) -> Bool)?) {}
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {}

    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        DispatchQueue.global().async { [weak self] in
            self?.headers.removeAll()
            self?.footers.removeAll()
            self?.carouselConfigs.removeAll()

            sections.enumerated().forEach { offset, section in
                self?.headers[offset] = section.header
                self?.footers[offset] = section.footer
                if let config = section.carouselConfig {
                    self?.carouselConfigs[offset] = config
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateItems(sections.map { $0.cells.map(\ .cell) })
                self.didSelectAt = { indexPath, cell in
                    sections.item(at: indexPath.section)?.cells.item(at: indexPath.row)?.onTap?(indexPath, cell)
                }
                self.collectionView?.reloadData()
                self.configureAutoscrollTimersIfNeeded()
            }
        }
    }
}

public class DiffableCollectionViewDataSource<Header, Cell: Hashable, Footer>: UICollectionViewDiffableDataSource<Int, Cell>, UICollectionViewDelegateFlowLayout {
    public var didSelectAt: ((IndexPath, Cell) -> Void)?
    public var configureCell: ((UICollectionView, IndexPath, Cell) -> UICollectionViewCell)?
    public var viewForHeaderInSection: ((UICollectionView, _ atSection: Int, _ header: Header) -> UICollectionReusableView)?
    public var sizeForHeaderInSection: ((_ atSection: Int, _ model: Header) -> CGSize)?
    public var viewForFooterInSection: ((UICollectionView, Int, Footer) -> UICollectionReusableView)?
    public var sizeForFooterInSection: ((_ atSection: Int, _ model: Footer) -> CGSize)?
    public var onRetry: (() -> Void)?
    public var showLoader = false
    public var minimumLineSpacingForSectionAt: ((Int) -> CGFloat) = { _ in 0 }
    public var loadNextPage: (() -> Void)?
    public var sizeForItemAt: ((IndexPath) -> CGSize)?
    public var didScrollTo: ((IndexPath) -> Void)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didMoveItem: ((_ atIndexPath: IndexPath, _ toIndexPath: IndexPath) -> Void)?

    private weak var collectionView: UICollectionView?
    private var scrollTimers: [Int: Timer] = [:]
    var headers = [Int: Header]()
    var footers = [Int: Footer]()
    var carouselConfigs = [Int: CarouselConfig]()

    public init(collectionView: UICollectionView, configureCell: @escaping (UICollectionView, IndexPath, Cell) -> UICollectionViewCell) {
        super.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            return configureCell(collectionView, indexPath, item)
        })
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader, let model = self?.headers[indexPath.section] {
                return self?.viewForHeaderInSection?(collectionView, indexPath.section, model)
            } else if kind == UICollectionView.elementKindSectionFooter, let model = self?.footers[indexPath.section] {
                return self?.viewForFooterInSection?(collectionView, indexPath.section, model)
            }
            return nil
        }

        self.collectionView = collectionView
        self.configureCell = configureCell

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    public func updateItems(_ items: [[Cell]]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Int, Cell>()
            let items = items.enumerated()
            snapshot.appendSections(items.map { $0.offset })
            items.forEach { offset, element in
                let uniqueItems = element.uniqued
                snapshot.appendItems(uniqueItems, toSection: offset)
            }
            self.apply(snapshot, animatingDifferences: true)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItemAt?(indexPath) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? UICollectionViewFlowLayout.automaticSize
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let thresholdIndex = itemCount - 1

        if indexPath.row == thresholdIndex, showLoader {
            loadNextPage?()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSectionAt(section)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let selectedModel = itemIdentifier(for: indexPath) else { return }
        didSelectAt?(indexPath, selectedModel)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)

        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = (scrollView as? UICollectionView)?.indexPathForItem(at: visiblePoint) else { return }

        didScrollTo?(indexPath)

        guard scrollView.isDragging else { return }
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > contentHeight - scrollViewHeight * 2 && showLoader {
            loadNextPage?()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let model = footers[section] else { return .zero }
        return sizeForFooterInSection?(section, model) ?? .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let model = headers[section] else { return .zero }
        return sizeForHeaderInSection?(section, model) ?? .zero
    }

    public override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        super.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)

        didMoveItem?(sourceIndexPath, destinationIndexPath)
    }

    private func configureAutoscrollTimersIfNeeded() {
        scrollTimers.values.forEach { $0.invalidate() }
        scrollTimers.removeAll()

        guard let collectionView = self.collectionView else { return }

        for (section, config) in carouselConfigs where config.isAutoscrollEnabled {
            let timer = Timer.scheduledTimer(withTimeInterval: config.scrollInterval, repeats: true) { [weak self] _ in
                self?.scrollToNextItem(in: section, endless: config.isEndlessScrollEnabled)
            }
            scrollTimers[section] = timer
        }
    }

    private func scrollToNextItem(in section: Int, endless: Bool) {
        guard let collectionView = self.collectionView else { return }

        let indexPaths = collectionView.indexPathsForVisibleItems
            .filter { $0.section == section }
            .sorted(by: { $0.item < $1.item })

        guard let current = indexPaths.first else { return }

        let nextItem = current.item + 1
        let total = collectionView.numberOfItems(inSection: section)

        let targetIndexPath: IndexPath

        if nextItem >= total {
            guard endless else { return }
            targetIndexPath = IndexPath(item: 0, section: section)
        } else {
            targetIndexPath = IndexPath(item: nextItem, section: section)
        }

        collectionView.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: true)
    }
}
