//
//  SelectionServiceProxyOutput.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 10/9/24.
//

import Foundation
import Combine

public protocol SelectionServiceInput {
    func onRefresh()
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool)
}

public class SelectionServiceProxy<Request, Response>: SelectionInput, LifeCycleViewOutput {
    typealias SelectionService = (any Service<Request, Response>)
    
    public var isMultipleSelectionEnabled: Bool { decoratee.isMultipleSelectionEnabled }
    
    public var configuration: SelectionConfiguration { decoratee.configuration }
    
    private let decoratee: SelectionPresenter
    private let storage: any Storage
    private let service: SelectionService
    private let makeRequest: (() -> Request)
    private let makeResponse: ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    public var view: LoadingOutput?
    
    public init(
        decoratee: SelectionPresenter,
        storage: any Storage,
        service: any Service<Request, Response>,
        makeRequest: @escaping (() -> Request),
        makeResponse: @escaping ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    ) {
        self.decoratee = decoratee
        self.storage = storage
        self.service = service
        self.makeRequest = makeRequest
        self.makeResponse = makeResponse
    }
    
    public func viewDidLoad() {
        view?.display(isLoading: true)
        service.make(request: makeRequest())
            .handle(
                onSuccess: { [weak self] response in
                    self?.decoratee.items = self?.makeResponse(.success(response)) ?? []
                },
                onError: { [weak self] error in
                    self?.decoratee.items = self?.makeResponse(.failure(error)) ?? []
                },
                onCompletion: { [weak self] in
                    self?.view?.display(isLoading: false)
                }
            )
        
        decoratee.viewDidLoad()
    }
    
    public func onSearch(_ text: String?) {
        decoratee.onSearch(text)
    }
    
    public func onTapFinishSelection() {
        decoratee.onTapFinishSelection()
    }
    
    public func isNeedToShowSearch(_ isNeedToShowSearch: Bool) {
        decoratee.isNeedToShowSearch(isNeedToShowSearch)
    }
}

extension SelectionServiceProxy: SelectionServiceInput {
    public func onRefresh() {
        view?.display(isLoading: true)
        service.make(request: makeRequest())
            .handle(
                onSuccess: { [weak self] response in
                    self?.decoratee.items = self?.makeResponse(.success(response)) ?? []
                },
                onError: { [weak self] error in
                    self?.decoratee.items = self?.makeResponse(.failure(error)) ?? []
                },
                onCompletion: { [weak self] in
                    self?.view?.display(isLoading: false)
                }
            )
    }
}
