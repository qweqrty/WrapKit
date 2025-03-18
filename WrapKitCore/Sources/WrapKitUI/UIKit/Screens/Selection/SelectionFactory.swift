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
import UIKit

public class SelectionFactoryiOS: ISelectionFactory {
    public func resolveSelection(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: SelectionPresenterModel
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            flow: flow.mainQueueDispatched,
            model: model,
            configuration: configuration
        )
       
        let contentView = SelectionContentView(config: configuration)
        let vc = SelectionVC(
            contentView: contentView,
            presenter: presenter
        )
        presenter.view = vc
            .weakReferenced
            .mainQueueDispatched
        presenter.navBarView = contentView.navigationBar
            .weakReferenced
            .mainQueueDispatched
        presenter.resetButton = contentView.resetButton
            .weakReferenced
            .mainQueueDispatched
        presenter.selectButton = contentView.selectButton
            .weakReferenced
            .mainQueueDispatched
        presenter.emptyView = contentView.emptyView
            .weakReferenced
            .mainQueueDispatched
        
        vc.preferredSheetSizing = model.items.count > SelectionPresenter.shouldShowSearchBarThresholdCount ? .fill : .fit
        return vc
    }
    
    
    public func resolveSelection<Request, Response>(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: ServicedSelectionModel<Request, Response>
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            flow: flow.mainQueueDispatched,
            model: model.model,
            configuration: configuration
        )
        
        let servicePresenter = SelectionServiceProxy(
            decoratee: presenter,
            storage: model.storage,
            service: model.service,
            makeRequest: model.request,
            makeResponse: model.response
        )
        let contentView = SelectionContentView(config: configuration)
        let vc = SelectionServiceVC(
            contentView: contentView,
            servicePresenter: servicePresenter
        )
        
        presenter.view = vc
            .weakReferenced
            .mainQueueDispatched
        presenter.navBarView = contentView.navigationBar
            .weakReferenced
            .mainQueueDispatched
        presenter.resetButton = contentView.resetButton
            .weakReferenced
            .mainQueueDispatched
        presenter.selectButton = contentView.selectButton
            .weakReferenced
            .mainQueueDispatched
        presenter.emptyView = contentView.emptyView
            .weakReferenced
            .mainQueueDispatched
        
        servicePresenter.view = vc
            .weakReferenced
            .mainQueueDispatched
        
        vc.preferredSheetSizing = .fill
        return vc
    }
    
    public init() {}
}
#endif


