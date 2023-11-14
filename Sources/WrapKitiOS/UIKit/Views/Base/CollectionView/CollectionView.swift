//
//  CollectionView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class CollectionView: UICollectionView {
    private var adjustHeight = false
    
    open override var intrinsicContentSize: CGSize {
        if adjustHeight {
            return super.intrinsicContentSize
        } else {
            layoutIfNeeded()
            return CGSize(width: contentSize.width, height: contentSize.height)
        }
    }
    
    open override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
    
    public init(
        collectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(),
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        backgroundColor: UIColor = .clear,
        cells: [AnyClass],
        isPagingEnabled: Bool = false,
        isScrollEnabled: Bool = true,
        contentInset: UIEdgeInsets = .zero,
        refreshControl: UIRefreshControl? = nil,
        emptyPlaceholderView: UIView? = nil,
        adjustHeight: Bool = false) {
        collectionViewFlowLayout.scrollDirection = scrollDirection
        super.init(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        self.backgroundColor = backgroundColor
        self.contentInset = contentInset
        self.refreshControl = refreshControl
        self.isPagingEnabled = isPagingEnabled
        self.backgroundView = emptyPlaceholderView
        self.isScrollEnabled = isScrollEnabled
        self.backgroundView?.isHidden = false
        self.backgroundView?.alpha = 0
        self.adjustHeight = adjustHeight
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        cells.forEach { register($0, forCellWithReuseIdentifier: String(describing: $0)) }
    }
    
    public override var contentSize: CGSize {
        didSet {
            guard !isScrollEnabled else { return }
            invalidateIntrinsicContentSize()
        }
    }

    open func changePlaceholder(_ state: Bool) {
        switch state {
        case false:
            self.backgroundView?.alpha = 0
        default:
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.backgroundView?.alpha = 1
                }
            )
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(kind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.reuseIdentifier)")
        }
        
        return view
    }
}
#endif
