//
//  PaginatedTableViewDatasource.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TableViewDatasource<Cell: UITableViewCell, Model>: NSObject, UITableViewDelegate, UITableViewDataSource {
    open var getItems: (() -> [Model]) = { [] }
    open var selectAt: ((IndexPath) -> Void)?
    open var showBottomLoader = false
    open var configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?
    open var hasMore = true
    open var loadNextPage: (() -> Void)?
    
    open var bottomLoadingView: UIView = {
        if #available(iOS 13.0, *) {
            let loadingControl = UIActivityIndicatorView(style: .medium)
            loadingControl.hidesWhenStopped = false
            loadingControl.startAnimating()
            return loadingControl
        } else {
            let loadingControl = UIActivityIndicatorView(style: .white)
            loadingControl.hidesWhenStopped = false
            loadingControl.startAnimating()
            return loadingControl
        }
    }()
    
    public init(configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)? = nil) {
        self.configureCell = configureCell
        super.init()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getItems().count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = getItems()[indexPath.row]
        if let configureCell = configureCell { return configureCell(tableView, indexPath, model) }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAt?(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard showBottomLoader else { return UIView() }
        return bottomLoadingView
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard showBottomLoader else { return .leastNonzeroMagnitude }
        return bottomLoadingView.intrinsicContentSize.height * 1.5
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        guard hasMore else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 4/5 {
            loadNextPage?()
        }
    }
}
#endif
