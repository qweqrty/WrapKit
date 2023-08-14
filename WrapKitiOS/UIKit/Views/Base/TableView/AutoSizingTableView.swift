//
//  AutoSizingTableView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TableViewAdjustedHeight: TableView {
    open override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    open override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    open override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
#endif
