//
//  ResourcePresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/11/23.
//

import Foundation

struct Resource<Request, Response> {
    let storage: any Storage<Response>
    let service: any WrapKit.Service<Request, Response>
}

public protocol ResourceViewOutput<PresentableModel>: AnyObject {
    associatedtype PresentableModel
    func display(model: PresentableModel)
    func display(isLoading: Bool)
    func display(error: String)
}

public protocol ResourceViewInput: AnyObject {
    func onViewDidLoad()
    func load()
}

open class ResourcePresenter<Request: Encodable, Response: Decodable, PresentableModel> {
    public let resourceStorage: any Storage<Response>
    private let service: any Service<Request, Response>
    private let mapRequest: (() -> Request)
    private let mapResponse: ((Response) -> PresentableModel)
    
    public weak var view: (any ResourceViewOutput<PresentableModel>)?

    public init(
        service: any Service<Request, Response>,
        mapRequest: @escaping (() -> Request),
        resourceStorage: any Storage<Response>,
        mapResponse: @escaping ((Response) -> PresentableModel)
    ) {
        self.service = service
        self.mapRequest = mapRequest
        self.mapResponse = mapResponse
        self.resourceStorage = resourceStorage
    }
}

extension ResourcePresenter: ResourceViewInput {
    public func onViewDidLoad() {
        resourceStorage.addObserver(for: self) { [weak self] model in
            guard let self = self else { return }
            guard let model = model else { return }
            self.view?.display(model: self.mapResponse(model))
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
