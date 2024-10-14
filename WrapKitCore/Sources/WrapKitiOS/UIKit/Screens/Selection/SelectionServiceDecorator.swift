//
//  SelectionServiceDecoratorOutput.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 10/9/24.
//

import Foundation

public protocol SelectionServiceDecoratorOutput: AnyObject {
    func display(isLoading: Bool)
}

public protocol SelectionServiceDecoratorInput {
    func onRefresh()
    func viewDidLoad()
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool)
}

public class SelectionServiceDecorator<Request, Response>: SelectionInput {
    typealias SelectionService = (any Service<Request, Response>)
    
    public var isMultipleSelectionEnabled: Bool  { decoratee.isMultipleSelectionEnabled }
    
    public var configuration: SelectionConfiguration { decoratee.configuration }
    
    private let decoratee: SelectionPresenter
    private let storage: any Storage
    private let service: SelectionService
    private let makeRequest: (() -> Request)
    private let makeResponse: ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    public weak var view: SelectionServiceDecoratorOutput?
    
    init(
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
        service.make(request: makeRequest()) { [weak self] result in
            self?.view?.display(isLoading: false)
            self?.decoratee.items = self?.makeResponse(result) ?? []
        }?.resume()
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

extension SelectionServiceDecorator: SelectionServiceDecoratorInput {
    public func onRefresh() {
        view?.display(isLoading: true)
        service.make(request: makeRequest()) { [weak self] result in
            self?.view?.display(isLoading: false)
            self?.decoratee.items = self?.makeResponse(result) ?? []
        }?.resume()
    }
}
