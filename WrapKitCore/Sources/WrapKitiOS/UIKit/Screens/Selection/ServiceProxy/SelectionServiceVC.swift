//
//  SelectionVCDecorator.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 10/9/24.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class SelectionServiceVC: SelectionVC {
    private let servicePresenter: SelectionServiceInput
    
    public var isLoading: Bool? = false
    
    public init(contentView: SelectionContentView, servicePresenter: SelectionServiceInput & SelectionInput) {
        self.servicePresenter = servicePresenter
        super.init(contentView: contentView, presenter: servicePresenter)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.refreshControl = contentView.refreshControl
        contentView.refreshControl.onRefresh = servicePresenter.onRefresh
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionServiceVC: LoadingOutput {
    public func display(model: LoadingOutputPresentableModel?) {
        guard let isLoading = model?.isLoading else { return }
        self.isLoading = isLoading
        isLoading ? contentView.refreshControl.beginRefreshing() : contentView.refreshControl.endRefreshing()
    }
}
#endif
