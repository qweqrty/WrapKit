//
//  SelectionFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//
public protocol ISelectionFactory<Controller> {
    associatedtype Controller
    
    func resolveSelection(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: SelectionPresenterModel
    ) -> Controller
    
    func resolveSelection<Request, Response>(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: ServicedSelectionModel<Request, Response>
    ) -> Controller
}

#if canImport(UIKit)
#if canImport(BottomSheet)
#if canImport(BottomSheetUtils)
import UIKit

public class SelectionFactoryiOS: ISelectionFactory {
    public func resolveSelection(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: SelectionPresenterModel
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            flow: flow,
            model: model,
            configuration: configuration
        )
        let vc = SelectionVC(
            contentView: .init(config: configuration),
            presenter: presenter
        )
        presenter.view = vc
        return vc
    }
    
    
    public func resolveSelection<Request, Response>(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: ServicedSelectionModel<Request, Response>
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            flow: flow,
            model: model.model,
            configuration: configuration
        )
        
        let servicePresenter = SelectionServiceDecorator(
            decoratee: presenter,
            storage: model.storage,
            service: model.service,
            makeRequest: model.request,
            makeResponse: model.response
        )
        
        let vc = SelectionVC(contentView: .init(config: configuration),
                             presenter: servicePresenter)
        
        let decoratedVC = SelectionVCDecorator(
            decoratee: vc,
            servicePresenter: servicePresenter
        )
        
        presenter.view = vc
        servicePresenter.view = decoratedVC
        return vc
    }
    
    public init() {}
}
#endif
#endif
#endif
