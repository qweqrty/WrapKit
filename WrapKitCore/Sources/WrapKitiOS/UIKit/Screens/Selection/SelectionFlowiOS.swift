//
//  SelectionFlowiOS.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation
import UIKit
import BottomSheet

public class SelectionFlowiOS: SelectionFlow {
    public let model: Model
    
    private weak var navigationController: UINavigationController?
    private let factory: ISelectionFactory
    
    init(
        model: Model,
        navigationController: UINavigationController?,
        factory: ISelectionFactory
    ) {
        self.model = model
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func showSelection() {
        let vc = factory.resolveSelection(
            title: model.title,
            isMultipleSelectionEnabled: model.isMultipleSelectionEnabled,
            items: model.items,
            flow: self
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: UIColor.white)
            )
        )
    }
    
    public func close(with result: SelectionType?) {
        model.callback?(result)
        DispatchQueue.main.async {
            self.navigationController?.presentedViewController?.dismiss(animated: true)
        }
    }
}
