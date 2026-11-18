//
//  TableView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

open class TableView: UITableView {
    private var adjustHeight = false
    
    open override var intrinsicContentSize: CGSize {
        if adjustHeight {
            layoutIfNeeded()
            return .init(
                width: super.intrinsicContentSize.width,
                height: contentSize.height + contentInset.top + contentInset.bottom
            )
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
        self.invalidateIntrinsicContentSize()
    }
    
    #if os(tvOS)
    public init(
        style: UITableView.Style = .grouped,
        backgroundColor: UIColor = .clear,
        allowsSelection: Bool = true,
        allowsMultipleSelectionDuringEditing: Bool = false,
        cells: [AnyClass] = [],
        contentInset: UIEdgeInsets = .zero,
        emptyPlaceholderView: UIView? = nil,
        adjustHeight: Bool = false
    ) {
        super.init(frame: .zero, style: style)
        commonSetup(
            style: style,
            backgroundColor: backgroundColor,
            allowsSelection: allowsSelection,
            allowsMultipleSelectionDuringEditing: allowsMultipleSelectionDuringEditing,
            cells: cells,
            contentInset: contentInset,
            emptyPlaceholderView: emptyPlaceholderView,
            adjustHeight: adjustHeight
        )
    }
    #else
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
        commonSetup(
            style: style,
            backgroundColor: backgroundColor,
            allowsSelection: allowsSelection,
            allowsMultipleSelectionDuringEditing: allowsMultipleSelectionDuringEditing,
            cells: cells,
            contentInset: contentInset,
            emptyPlaceholderView: emptyPlaceholderView,
            adjustHeight: adjustHeight
        )
        self.refreshControl = refreshControl
    }
    #endif

    private func commonSetup(
        style: UITableView.Style,
        backgroundColor: UIColor,
        allowsSelection: Bool,
        allowsMultipleSelectionDuringEditing: Bool,
        cells: [AnyClass],
        contentInset: UIEdgeInsets,
        emptyPlaceholderView: UIView?,
        adjustHeight: Bool
    ) {
        cells.forEach { register($0, forCellReuseIdentifier: String(describing: $0)) }
        #if !os(tvOS)
        separatorStyle = .none
        #endif
        self.contentInset = contentInset
        self.adjustHeight = adjustHeight
        self.backgroundColor = backgroundColor
        self.allowsSelection = allowsSelection
        self.allowsMultipleSelectionDuringEditing = allowsMultipleSelectionDuringEditing
        self.showsVerticalScrollIndicator = false
        self.backgroundView = emptyPlaceholderView
        self.backgroundView?.isHidden = false
        self.backgroundView?.alpha = 0
        #if !os(visionOS)
        self.keyboardDismissMode = .onDrag
        #endif
        self.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        self.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func numberOfRows(inSection section: Int) -> Int {
        guard numberOfSections > section else { return 0 }
        return super.numberOfRows(inSection: section)
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
