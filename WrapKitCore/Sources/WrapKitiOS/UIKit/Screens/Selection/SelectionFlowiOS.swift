//
//  SelectionFlowiOS.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import Foundation
import UIKit
import BottomSheet

public class SelectionFlowiOS: SelectionFlow {
    public let model: Model
    
    private weak var navigationController: UINavigationController?
    private let factory: any ISelectionFactory<UIViewController>
    
    public init(
        model: Model,
        navigationController: UINavigationController?,
        factory: any ISelectionFactory<UIViewController>
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
            flow: self,
            configuration: model.configuration
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: model.configuration.content.shadowBackgroundColor)
            )
        )
    }
    
    public func showServicedSelection<Request, Response>(
        service: any Service<Request, Response>,
        request: @escaping (() -> Request),
        response: @escaping ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    ) {
        let vc = factory.resolveServicedSelection(
            title: model.title,
            service: service,
            isMultipleSelectionEnabled: model.isMultipleSelectionEnabled,
            items: model.items,
            flow: self,
            configuration: model.configuration,
            request: request,
            response: response)
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: model.configuration.content.shadowBackgroundColor)
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
#endif
