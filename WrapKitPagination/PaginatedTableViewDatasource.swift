//
//  PaginatedTableViewDatasource.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class PaginatedTableViewDatasource<Cell: UITableViewCell & Configurable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    public var getItems: (() -> [Cell.Model]) = { [] }
    public var selectAt: ((IndexPath) -> Void)?
    public var onRetry: (() -> Void)?
    public var showBottomLoader = false
    public var hasMore = true
    public var loadNextPage: (() -> Void)?
    
    private(set) var bottomLoadingView: UIView = {
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
    
    public override init() {
        super.init()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getItems().count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        cell.model = getItems()[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAt?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard showBottomLoader else { return UIView() }
        return bottomLoadingView
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard showBottomLoader else { return .leastNonzeroMagnitude }
        return bottomLoadingView.intrinsicContentSize.height * 1.5
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
