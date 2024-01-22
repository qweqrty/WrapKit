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
    func display(errorAtFirstPage: String)
    func display(errorAtSubsequentPage: String)
}

public protocol PaginationViewInput<Item>: AnyObject {
    associatedtype Item
    var items: [Item] { get set }

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
    
    public let totalPages: Int
    public let results: [Item]
}

open class PaginationPresenter<ServicePaginationRequest, ServicePaginationResponse, Item, PresentableItem> {
    private(set) var date: Date
    public var items: [Item] {
        didSet {
            view?.display(items: items.map { mapPresentable($0) }, hasMore: initialPage + (totalPages ?? 1) - 1 >= page)
        }
    }
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
        timestamp: Date = Date(),
        initialPage: Int = 1,
        perPage: Int = 10,
        initialItems: [Item] = []
    ) {
        self.service = service
        self.date = timestamp
        self.initialPage = initialPage
        self.page = initialPage
        self.perPage = perPage
        self.items = initialItems
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
        items = []
        requests.forEach { $0?.cancel() }
        requests.removeAll()
        view?.display(isLoadingSubsequentPage: false)
        view?.display(isLoadingFirstPage: true)
        let task = service.make(request: request) { [weak self, initialPage] result in
            self?.view?.display(isLoadingFirstPage: false)
            self?.handle(response: result, backToPage: initialPage)
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
            items += model.results
            view?.display(items: items.map { mapPresentable($0) }, hasMore: initialPage + (totalPages ?? 1) - 1 >= page)
            totalPages = model.totalPages
        case .failure(let error):
            page = backToPage
            backToPage == initialPage ? view?.display(errorAtFirstPage: error.title) : view?.display(errorAtSubsequentPage: error.title)
        }
    }
}
