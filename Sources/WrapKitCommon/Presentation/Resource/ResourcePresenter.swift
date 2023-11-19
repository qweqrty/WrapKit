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

public protocol ResourceViewInput<Item, Request>: AnyObject where Item: ViewModelDTO, Request: Encodable {
    associatedtype Item
    associatedtype Request
    var resourceStorage: any Storage<Item> { get }

    func load(request: Request)
}

open class ResourcePresenter<Request: Encodable, Response: Decodable & ViewModelDTO> {
    public let resourceStorage: any Storage<Response>
    private let service: any Service<Request, Response>
    
    public weak var view: (any ResourceViewOutput<Response.ViewModel>)?

    public init(
        service: any Service<Request, Response>,
        resourceStorage: any Storage<Response>
    ) {
        self.service = service
        self.resourceStorage = resourceStorage
    }
}

extension ResourcePresenter: ResourceViewInput {
    public func load(request: Request) {
        view?.display(isLoading: true)
        let task = service.make(request: request) { [weak self] result in
            view?.display(isLoading: false)
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
