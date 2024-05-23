//
//  DIffableTableViewDatasource.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
public class DiffableTableViewDataSource<Model: Hashable>: NSObject, UITableViewDelegate {
    public enum TableItem: Hashable {
        case model(Model)
        case footer(UUID)
    }
    
    public var didSelectAt: ((IndexPath, Model) -> Void)?
    public var configureCell: ((UITableView, IndexPath, Model) -> UITableViewCell)?
    public var configureFooter: (() -> UITableViewCell)?
    public var onRetry: (() -> Void)?
    public var showLoader = false {
        didSet {
            updateSnapshot()
        }
    }
    public var loadNextPage: (() -> Void)?
    public var heightForRowAt: ((IndexPath) -> CGFloat)?
    public var didScrollViewDidScroll: ((UIScrollView) -> Void)?
    
    private weak var tableView: UITableView?
    private var dataSource: UITableViewDiffableDataSource<Int, TableItem>!
    private var items = [Model]()
    
    public init(tableView: UITableView, configureCell: @escaping (UITableView, IndexPath, Model) -> UITableViewCell) {
        super.init()
        self.tableView = tableView
        self.configureCell = configureCell
        setupDataSource(for: tableView)
    }
    
    private func setupDataSource(for tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Int, TableItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            switch item {
            case .footer:
                return self?.configureFooter?() ?? UITableViewCell()
            case .model(let model):
                return self?.configureCell?(tableView, indexPath, model) ?? UITableViewCell()
            }
        }
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    private func updateSnapshot() {
        let numberOfSections = dataSource.snapshot().numberOfSections
        var snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>()
        snapshot.appendSections([0])
        if numberOfSections > 0 {
            snapshot.appendItems(dataSource.snapshot().itemIdentifiers(inSection: 0), toSection: 0)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    public func updateItems(_ items: [Model]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items.map { .model($0) }, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt?(indexPath) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemCount = tableView.numberOfRows(inSection: 0)
        let thresholdIndex = itemCount - 1
        
        if indexPath.row == thresholdIndex, showLoader {
            loadNextPage?()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedModel = items.item(at: indexPath.row) else { return }
        didSelectAt?(indexPath, selectedModel)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewDidScroll?(scrollView)
    }
}

#endif
