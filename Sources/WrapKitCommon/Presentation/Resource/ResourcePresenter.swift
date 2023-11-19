//
//  ResourcePresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/11/23.
//

import Foundation

public protocol ResourceViewOutput<ViewModel>: AnyObject {
    associatedtype ViewModel
    func display(model: ViewModel)
    func display(isLoading: Bool)
    func display(error: String)
}

public protocol ResourceViewInput: AnyObject {
    func onViewDidLoad()
    func load()
}

open class ResourcePresenter<Request: Encodable, Response: Decodable & ViewModelDTO> {
    public let resourceStorage: any Storage<Response>
    private let service: any Service<Request, Response>
    private let mapRequest: (() -> Request)
    
    public weak var view: (any ResourceViewOutput<Response.ViewModel>)?

    public init(
        service: any Service<Request, Response>,
        mapRequest: @escaping (() -> Request),
        resourceStorage: any Storage<Response>
    ) {
        self.service = service
        self.mapRequest = mapRequest
        self.resourceStorage = resourceStorage
    }
}

extension ResourcePresenter: ResourceViewInput {
    public func onViewDidLoad() {
        resourceStorage.addObserver(for: self) { [weak self] model in
            guard let model = model else { return }
            self?.view?.display(model: model.viewModel)
        }
    }
    
    public func load() {
        let shouldShowLoader = resourceStorage.get() == nil
        if shouldShowLoader { view?.display(isLoading: true) }
        let task = service.make(request: mapRequest()) { [weak self, shouldShowLoader] result in
            if shouldShowLoader { self?.view?.display(isLoading: false) }
            switch result {
            case .success(let model):
                self?.resourceStorage.set(model)
            case .failure(let error):
                self?.view?.display(error: error.title)
            }
        }
        task?.resume()
    }
}
