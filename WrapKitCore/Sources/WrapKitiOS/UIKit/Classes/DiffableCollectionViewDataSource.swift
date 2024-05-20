//
//  DiffableCollectionViewDataSource.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
public class DiffableCollectionViewDataSource<Model: Hashable>: NSObject, UICollectionViewDelegateFlowLayout {
    public enum CollectionItem: Hashable {
        case model(Model)
        case footer(UUID)
    }
    
    public var didSelectAt: ((IndexPath) -> Void)?
    public var configureCell: ((UICollectionView, IndexPath, Model) -> UICollectionViewCell)?
    public var configureSupplementaryView: ((UICollectionView, String, IndexPath) -> UICollectionReusableView)?
    public var onRetry: (() -> Void)?
    public var showLoader = false {
        didSet {
            updateSnapshot()
        }
    }
    public var minimumLineSpacingForSectionAt: ((Int) -> CGFloat) = { _ in 0 }
    public var loadNextPage: (() -> Void)?
    public var sizeForItemAt: ((IndexPath) -> CGSize)?
    public var didScrollTo: ((IndexPath) -> Void)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    
    private weak var collectionView: UICollectionView?
    private var dataSource: UICollectionViewDiffableDataSource<Int, CollectionItem>!
    
    public init(collectionView: UICollectionView, configureCell: @escaping (UICollectionView, IndexPath, Model) -> UICollectionViewCell) {
        super.init()
        self.collectionView = collectionView
        self.configureCell = configureCell
        setupDataSource(for: collectionView)
    }
    
    private func setupDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<Int, CollectionItem>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            switch item {
            case .footer:
                return nil
            case .model(let model):
                return self?.configureCell?(collectionView, indexPath, model) ?? UICollectionViewCell()
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.configureSupplementaryView?(collectionView, kind, indexPath) ?? UICollectionReusableView()
        }
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CollectionItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(dataSource.snapshot().itemIdentifiers(inSection: 0), toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func updateItems(_ items: [Model]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CollectionItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items.map { .model($0) }, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        didSelectAt?(indexPath)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = (scrollView as? UICollectionView)?.indexPathForItem(at: visiblePoint) else { return }
        didScrollTo?(indexPath)
    }
}

#endif
