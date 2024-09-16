//
//  SelectionFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

public protocol ISelectionFactory<Controller> {
    associatedtype Controller
    
    func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> Controller
    
    func resolveServicedSelection<Request, Response>(
        title: String?,
        service: any Service<Request, Response>,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration,
        request: @escaping (() -> Request),
        response: @escaping ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    ) -> Controller
}

#if canImport(UIKit)
#if canImport(BottomSheet)
#if canImport(BottomSheetUtils)
import UIKit

public class SelectionFactoryiOS: ISelectionFactory {
    public func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            flow: flow,
            configuration: configuration
        )
        let vc = SelectionVC(
            contentView: .init(config: configuration),
            presenter: presenter
        )
        presenter.view = vc
        return vc
    }
    
    public func resolveServicedSelection<Request, Response>(
        title: String?,
        service: any Service<Request, Response>,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration,
        request: @escaping (() -> Request),
        response: @escaping ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            flow: flow,
            configuration: configuration
        )
        
        let servicePresenter = SelectionServiceDecorator(
            decoratee: presenter,
            service: service,
            makeRequest: request,
            makeResponse: response
        )
        
        let vc = SelectionVCDecorator(
            decoratee: SelectionVC(contentView: .init(config: configuration),
                                   presenter: servicePresenter),
            servicePresenter: servicePresenter)
        presenter.view = vc
        servicePresenter.view = vc
        return vc
    }
    
    public init() {}
}
#endif
#endif
#endif
