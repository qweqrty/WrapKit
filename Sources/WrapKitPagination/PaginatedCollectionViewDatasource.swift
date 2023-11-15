//
//  PaginatedCollectionViewDatasource.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class CollectionViewDatasource<Cell: UICollectionViewCell & Configurable>: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public var getItems: (() -> [Cell.Model]) = { [] }
    public var selectAt: ((IndexPath) -> Void)?
    public var onRetry: (() -> Void)?
    public var showLoader = false
    public var hasMore = true
    public var minimumLineSpacingForSectionAt: ((Int) -> CGFloat) = { _ in 16 }
    public var loadNextPage: (() -> Void)?
    
    public var loadingView: CollectionReusableView<UIActivityIndicatorView> = CollectionReusableView<UIActivityIndicatorView>()

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getItems().count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
        cell.model = getItems()[indexPath.row]
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSectionAt(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAt?(indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard showLoader else { return .zero }
        guard let scrollDirection = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection else { return .zero }
        let width = scrollDirection == .horizontal ? loadingView.contentView.intrinsicContentSize.width * 3 : collectionView.bounds.width
        let height = scrollDirection == .horizontal ? loadingView.contentView.intrinsicContentSize.height : loadingView.contentView.intrinsicContentSize.height * 3
        return .init(width: width, height: height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: CollectionReusableView<UIActivityIndicatorView> = collectionView.dequeueSupplementaryView(kind: kind, for: indexPath)
        view.contentView.hidesWhenStopped = false
        view.contentView.startAnimating()
        self.loadingView = view
        return view
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        guard hasMore else { return }
        guard let scrollDirection = ((scrollView as? UICollectionView)?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection else { return }
        let isHorizontalDirection = scrollDirection == .horizontal
        let contentOffset = isHorizontalDirection ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let contentSize = isHorizontalDirection ? scrollView.contentSize.width : scrollView.contentSize.height
        let frameSize = isHorizontalDirection ? scrollView.bounds.size.width : scrollView.bounds.size.height
        
        if contentOffset > contentSize - frameSize * 4.5/5 {
            loadNextPage?()
        }
    }
}
#endif
