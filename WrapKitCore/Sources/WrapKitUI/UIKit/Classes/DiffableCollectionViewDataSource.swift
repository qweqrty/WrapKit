//
//  DiffableCollectionViewDataSource.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

import Foundation

#if canImport(UIKit)
import UIKit

public enum CollectionItem<Model: Hashable>: Hashable {
    case model(Model)
    case footer(UUID)
}

@available(iOS 13.0, *)
public class DiffableCollectionViewDataSource<Model: Hashable>: UICollectionViewDiffableDataSource<Int, CollectionItem<Model>>, UICollectionViewDelegateFlowLayout {
    public var didSelectAt: ((IndexPath, Model) -> Void)?
    public var configureCell: ((UICollectionView, IndexPath, Model) -> UICollectionViewCell)?
    public var configureSupplementaryView: ((UICollectionView, String, IndexPath) -> UICollectionReusableView)?
    public var onRetry: (() -> Void)?
    public var showLoader = false
    public var minimumLineSpacingForSectionAt: ((Int) -> CGFloat) = { _ in 0 }
    public var loadNextPage: (() -> Void)?
    public var sizeForItemAt: ((IndexPath) -> CGSize)?
    public var didScrollTo: ((IndexPath) -> Void)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var didMoveItem: ((_ atIndexPath: IndexPath, _ toIndexPath: IndexPath) -> Void)?

    private weak var collectionView: UICollectionView?
    
    public init(collectionView: UICollectionView, configureCell: @escaping (UICollectionView, IndexPath, Model) -> UICollectionViewCell) {
        super.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .footer:
                let cell: CollectionViewCell<UIView> = collectionView.dequeueReusableCell(for: indexPath)
                return cell
            case .model(let model):
                return configureCell(collectionView, indexPath, model)
            }
        })
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.configureSupplementaryView?(collectionView, kind, indexPath) ?? UICollectionReusableView()
        }
        
        self.collectionView = collectionView
        self.configureCell = configureCell
        collectionView.register(CollectionViewCell<UIView>.self, forCellWithReuseIdentifier: CollectionViewCell<UIView>.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    public func updateItems(_ items: [Model], at section: Int = 0) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let uniqueItems = items.uniqued
            DispatchQueue.main.async { [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<Int, CollectionItem<Model>>()
                snapshot.appendSections([section])
                snapshot.appendItems(uniqueItems.map { .model($0) }, toSection: section)
                self?.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    public func updateItems(_ items: [[Model]]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let uniqueItems = items.uniqued
            DispatchQueue.main.async { [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<Int, CollectionItem<Model>>()
                snapshot.appendSections(uniqueItems.enumerated().map { $0.offset })
                uniqueItems.enumerated().forEach {
                    snapshot.appendItems($0.element.uniqued.map { .model($0) }, toSection: $0.offset)
                }
                self?.apply(snapshot, animatingDifferences: true)
            }
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
        
        if case .model(let selectedModel) = snapshot().itemIdentifiers(inSection: indexPath.section).item(at: indexPath.row) {
            didSelectAt?(indexPath, selectedModel)
        }
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

        // Load the next page when the user is near the bottom of the collection view
        if position > contentHeight - scrollViewHeight * 2 && showLoader {
            loadNextPage?()
        }
    }

    public override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        super.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
        
        didMoveItem?(sourceIndexPath, destinationIndexPath)
    }
}

extension DiffableCollectionViewDataSource: DiffableDataSourceOutput {
    public typealias Model = Model
    public typealias SectionItem = CollectionItem
    
    public func display(model: [DiffableDataSourcePresentableModel<Model>], at section: SectionItem<Model>) {
        self.updateItems(model.map { $0.model })
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
#endif
