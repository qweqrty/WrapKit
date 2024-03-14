//
//  TableView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TableView: UITableView {
    private var adjustHeight = false
    
    open override var intrinsicContentSize: CGSize {
        if adjustHeight {
            layoutIfNeeded()
            return .init(width: super.intrinsicContentSize.width, height: contentSize.height)
        } else {
            return super.intrinsicContentSize
        }
    }
    open override var contentSize: CGSize {
        didSet {
            if adjustHeight {
                invalidateIntrinsicContentSize()
            }
        }
    }
    open override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
    
    public init(
        style: UITableView.Style = .grouped,
        backgroundColor: UIColor = .clear,
        allowsSelection: Bool = true,
        allowsMultipleSelectionDuringEditing: Bool = false,
        cells: [AnyClass] = [],
        contentInset: UIEdgeInsets = .zero,
        refreshControl: UIRefreshControl? = nil,
        emptyPlaceholderView: UIView? = nil,
        adjustHeight: Bool = false
    ) {
        super.init(frame: .zero, style: style)
        
        cells.forEach { register($0, forCellReuseIdentifier: String(describing: $0)) }
        separatorStyle = .none
        self.contentInset = contentInset
        self.adjustHeight = adjustHeight
        self.backgroundColor = backgroundColor
        self.allowsSelection = allowsSelection
        self.allowsMultipleSelectionDuringEditing = allowsMultipleSelectionDuringEditing
        self.showsVerticalScrollIndicator = false
        self.refreshControl = refreshControl
        self.backgroundView = emptyPlaceholderView
        self.backgroundView?.isHidden = false
        self.backgroundView?.alpha = 0
        self.keyboardDismissMode = .onDrag
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func changePlaceholder(_ state: Bool) {
        guard let backgroundView = backgroundView else { return }
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
}

public extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }

    func register(_ cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
}
#endif
