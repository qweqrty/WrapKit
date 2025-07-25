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
    
    public init(
        contentView: SelectionContentView,
        servicePresenter: SelectionServiceInput & SelectionInput,
        lifeCycleViewOutput: LifeCycleViewOutput?
    ) {
        self.servicePresenter = servicePresenter
        super.init(
            contentView: contentView,
            presenter: servicePresenter,
            lifeCycleViewOutput: lifeCycleViewOutput
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.refreshControl = contentView.refreshControl
        contentView.refreshControl.display(onRefresh: servicePresenter.onRefresh)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionServiceVC: LoadingOutput {
    public func display(isLoading: Bool) {
        self.isLoading = isLoading
        isLoading ? contentView.refreshControl.beginRefreshing() : contentView.refreshControl.endRefreshing()
    }
}
#endif
