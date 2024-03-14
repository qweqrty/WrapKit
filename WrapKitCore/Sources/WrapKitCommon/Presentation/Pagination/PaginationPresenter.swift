//
//  PaginationPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public protocol PaginationViewOutput<ViewModel>: AnyObject {
    associatedtype ViewModel
    func display(items: [ViewModel], hasMore: Bool)
    func display(isLoadingFirstPage: Bool)
    func display(isLoadingSubsequentPage: Bool)
    func display(errorAtFirstPage: String?)
    func display(errorAtSubsequentPage: String?)
}

public protocol PaginationViewInput<PresentableItemModel>: AnyObject {
    associatedtype PresentableItemModel
    
    var presentableItemsStorage: any Storage<[PresentableItemModel]> { get }
    
    func refresh()
    func loadNextPage()
}

public struct PaginationRequest {
    public init(page: Int, date: Date, perPage: Int) {
        self.page = page
        self.date = date
        self.perPage = perPage
    }
    
    public let page: Int
    public let date: Date
    public let perPage: Int
}

public struct PaginationResponse<Item> {
    public init(totalPages: Int, results: [Item]) {
        self.totalPages = totalPages
        self.results = results
    }
    
    public init(totalItemsCount: Int, perPage: Int, results: [Item]) {
        self.totalPages = perPage == 0 ? 0 : (totalItemsCount + perPage - 1) / perPage
        self.results = results
    }
    
    public let totalPages: Int
    public let results: [Item]
}

open class PaginationPresenter<ServicePaginationRequest, ServicePaginationResponse, Item, PresentableItem> {
    public let presentableItemsStorage: any Storage<[PresentableItem]>

    private(set) var date: Date
    private(set) var page: Int
    private(set) var totalPages: Int?

    public var mapRequest: ((PaginationRequest) -> ServicePaginationRequest?)
    private let perPage: Int
    private let service: any Service<ServicePaginationRequest, ServicePaginationResponse> // Expected to be SerialServiceDecorator
    private let mapResponse: ((ServicePaginationResponse) -> PaginationResponse<Item>?)
    private let mapPresentable: ((Item) -> PresentableItem)
    private var requests = [HTTPClientTask?]()
    
    let initialPage: Int

    public weak var view: (any PaginationViewOutput<PresentableItem>)?

    public init(
        service: any Service<ServicePaginationRequest, ServicePaginationResponse>,
        mapRequest: @escaping ((PaginationRequest) -> ServicePaginationRequest?),
        mapResponse: @escaping ((ServicePaginationResponse) -> PaginationResponse<Item>?),
        mapPresentable: @escaping ((Item) -> PresentableItem),
        presentableItemsStorage: any Storage<[PresentableItem]>,
        timestamp: Date = Date(),
        initialPage: Int = 1,
        perPage: Int = 10
    ) {
        self.service = service
        self.date = timestamp
        self.initialPage = initialPage
        self.page = initialPage
        self.presentableItemsStorage = presentableItemsStorage
        self.perPage = perPage
        self.mapRequest = mapRequest
        self.mapResponse = mapResponse
        self.mapPresentable = mapPresentable
    }
}

extension PaginationPresenter: PaginationViewInput {
    public func refresh() {
        guard let request = mapRequest(.init(page: initialPage, date: Date(), perPage: perPage)) else { return }
        date = Date()
        page = initialPage
        requests.forEach { $0?.cancel() }
        requests.removeAll()
        view?.display(isLoadingSubsequentPage: false)
        view?.display(isLoadingFirstPage: true)
        let task = service.make(request: request) { [weak self, initialPage] result in
            self?.view?.display(isLoadingFirstPage: false)
            self?.handle(response: result, backToPage: initialPage - 1)
        }
        requests.append(task)
        task?.resume()
    }

    public func loadNextPage() {
        guard initialPage + (totalPages ?? 0) - 1 >= page else { return }
        guard let request = mapRequest(.init(page: page + 1, date: date, perPage: perPage)) else { return }
        view?.display(isLoadingSubsequentPage: true)
        page += 1
        let task = service.make(request: request) { [weak self, page] result in
            self?.view?.display(isLoadingSubsequentPage: false)
            self?.handle(response: result, backToPage: page - 1)
        }
        requests.append(task)
        task?.resume()
    }
    
    private func handle(response: Result<ServicePaginationResponse, ServiceError>, backToPage: Int) {
        switch response {
        case .success(let model):
            guard let model = mapResponse(model) else {
                page = backToPage
                backToPage == initialPage ? view?.display(errorAtFirstPage: ServiceError.internal.title) : view?.display(errorAtSubsequentPage: ServiceError.internal.title)
                return
            }
            if backToPage == initialPage - 1 {
                let items = model.results.map { mapPresentable($0) }
                presentableItemsStorage.set(model: items, completion: nil)
                view?.display(items: items, hasMore: initialPage + (totalPages ?? 1) - 1 >= page)
            } else {
                let items = (presentableItemsStorage.get() ?? []) + model.results.map { mapPresentable($0) }
                presentableItemsStorage.set(model: items, completion: nil)
                view?.display(items: items, hasMore: initialPage + (totalPages ?? 1) - 1 >= page)
            }
            totalPages = model.totalPages
        case .failure(let error):
            page = backToPage
            backToPage == initialPage - 1 ? view?.display(errorAtFirstPage: error.title) : view?.display(errorAtSubsequentPage: error.title)
        }
    }
}

