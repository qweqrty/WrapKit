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
    func viewDidLoad()
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool)
}

public class SelectionServiceProxy<Request, Response>: SelectionInput {
    typealias SelectionService = (any Service<Request, Response>)
    
    public var isMultipleSelectionEnabled: Bool  { decoratee.isMultipleSelectionEnabled }
    
    public var configuration: SelectionConfiguration { decoratee.configuration }
    
    private let decoratee: SelectionPresenter
    private let storage: any Storage
    private let service: SelectionService
    private let makeRequest: (() -> Request)
    private let makeResponse: ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    public var view: CommonLoadingOutput?
    private var cancellables = Set<AnyCancellable>()
    
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
            .sink(receiveCompletion: { [weak self] result in
                self?.view?.display(isLoading: false)
                guard case .failure(let error) = result else { return }
                self?.decoratee.items = self?.makeResponse(.failure(error)) ?? []
            }, receiveValue: { [weak self] data in
                self?.view?.display(isLoading: false)
                self?.decoratee.items = self?.makeResponse(.success(data)) ?? []
            })
            .store(in: &cancellables)
        
        decoratee.viewDidLoad()
    }
    
    public func onSearch(_ text: String?) {
        decoratee.onSearch(text)
    }
    
    public func onSelect(at index: Int) {
        decoratee.onSelect(at: index)
    }
    
    public func onTapFinishSelection() {
        decoratee.onTapFinishSelection()
    }
    
    public func onTapReset() {
        decoratee.onTapReset()
    }
    
    public func onTapClose() {
        decoratee.onTapClose()
    }
    
    public func isNeedToShowSearch(_ isNeedToShowSearch: Bool) {
        decoratee.isNeedToShowSearch(isNeedToShowSearch)
    }
}

extension SelectionServiceProxy: SelectionServiceInput {
    public func onRefresh() {
        view?.display(isLoading: true)
        service.make(request: makeRequest()) 
            .sink(receiveCompletion: { [weak self] result in
                self?.view?.display(isLoading: false)
                guard case .failure(let error) = result else { return }
                self?.decoratee.items = self?.makeResponse(.failure(error)) ?? []
            }, receiveValue: { [weak self] data in
                self?.view?.display(isLoading: false)
                self?.decoratee.items = self?.makeResponse(.success(data)) ?? []
            })
            .store(in: &cancellables)
    }
}
