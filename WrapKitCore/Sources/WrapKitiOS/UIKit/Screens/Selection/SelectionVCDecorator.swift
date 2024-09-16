//
//  SelectionVCDecorator.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 10/9/24.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class SelectionVCDecorator: ViewController<SelectionContentView> {
    private let decoratee: SelectionVC
    private let servicePresenter: SelectionServiceDecoratorInput

    public init(decoratee: SelectionVC, servicePresenter: SelectionServiceDecoratorInput) {
        self.decoratee = decoratee
        self.servicePresenter = servicePresenter
        super.init(contentView: decoratee.contentView)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.refreshControl = contentView.refreshControl
        decoratee.contentView.refreshControl.onRefresh = servicePresenter.onRefresh
        decoratee.viewDidLoad()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionVCDecorator: SelectionServiceDecoratorOutput {
    
}
#endif
