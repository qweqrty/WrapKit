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

public protocol ResourceViewInput<Item>: AnyObject where Item: ViewModelDTO {
    associatedtype Item
    var resourceStorage: any Storage<Item> { get }

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
    public func load() {
        view?.display(isLoading: true)
        let task = service.make(request: mapRequest()) { [weak self] result in
            self?.view?.display(isLoading: false)
            switch result {
            case .success(let model):
                self?.view?.display(model: model.viewModel)
            case .failure(let error):
                self?.view?.display(error: error.title)
            }
        }
        task?.resume()
    }
}
