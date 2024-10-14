//
//  SelectionFlowiOS.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
#if canImport(BottomSheet)
#if canImport(BottomSheetUtils)
import Foundation
import UIKit
import BottomSheet

public class SelectionFlowiOS: SelectionFlow {
    public let configuration: Model
    
    private weak var navigationController: UINavigationController?
    private let factory: any ISelectionFactory<UIViewController>
    
    public init(
        configuration: Model,
        navigationController: UINavigationController?,
        factory: any ISelectionFactory<UIViewController>
    ) {
        self.configuration = configuration
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func showSelection(model: SelectionPresenterModel) {
        let vc = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: configuration.content.shadowBackgroundColor)
            )
        )
    }
    
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        let vc = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        
        navigationController?.presentBottomSheet(
            viewController: vc,
            configuration: .init(
                cornerRadius: 16,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: configuration.content.shadowBackgroundColor)
            )
        )
    }
    
    public func close(with result: SelectionType?) {
        navigationController?.presentedViewController?.dismiss(animated: true)
    }
}

#endif
#endif
#endif
