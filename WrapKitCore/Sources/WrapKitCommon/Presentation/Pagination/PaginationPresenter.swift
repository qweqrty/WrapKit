//
//  PaginationPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public protocol PaginationViewOutput<PresentableItem>: AnyObject {
    associatedtype PresentableItem
    func display(items: [PresentableItem], hasMore: Bool)
    func display(isLoadingFirstPage: Bool)
    func display(isLoadingSubsequentPage: Bool)
    func display(errorAtFirstPage: String?)
    func display(errorAtSubsequentPage: String?)
}

public protocol PaginationViewInput<RemoteItem>: AnyObject {
    associatedtype RemoteItem
    
    var remoteItemsStorage: any Storage<[RemoteItem]> { get }
    
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

open class PaginationPresenter<ServicePaginationRequest, ServicePaginationResponse, RemoteItem, PresentableItem> {
    public let remoteItemsStorage: any Storage<[RemoteItem]>

    private(set) var date: Date
    private(set) var page: Int
    private(set) var totalPages: Int?

    public var mapRequest: ((PaginationRequest) -> ServicePaginationRequest?)
    private var perPage: Int
    private let service: any Service<ServicePaginationRequest, ServicePaginationResponse> // Expected to be SerialServiceDecorator
    private let mapToItems: ((ServicePaginationResponse) -> [RemoteItem])
    private let mapToTotalPages: ((ServicePaginationResponse) -> Int)
    private let mapFromResponseToPresentable: ((ServicePaginationResponse) -> [PresentableItem])
    private let mapFromRemoteItemToPresentable: ((RemoteItem) -> PresentableItem)
    private var requests = [HTTPClientTask?]()
    
    let initialPage: Int

    public weak var view: (any PaginationViewOutput<PresentableItem>)?

    public init(
        service: any Service<ServicePaginationRequest, ServicePaginationResponse>,
        mapRequest: @escaping ((PaginationRequest) -> ServicePaginationRequest?),
        mapToItems: @escaping ((ServicePaginationResponse) -> [RemoteItem]),
        mapToTotalPages: @escaping ((ServicePaginationResponse) -> Int),
        mapFromResponseToPresentable: @escaping ((ServicePaginationResponse) -> [PresentableItem]),
        mapFromRemoteItemToPresentable: @escaping ((RemoteItem) -> PresentableItem),
        remoteItemsStorage: any Storage<[RemoteItem]>,
        timestamp: Date = Date(),
        initialPage: Int = 1,
        perPage: Int = 10
    ) {
        self.service = service
        self.date = timestamp
        self.initialPage = initialPage
        self.page = initialPage
        self.remoteItemsStorage = remoteItemsStorage
        self.mapToItems = mapToItems
        self.perPage = perPage
        self.mapRequest = mapRequest
        self.mapToTotalPages = mapToTotalPages
        self.mapFromRemoteItemToPresentable = mapFromRemoteItemToPresentable
        self.mapFromResponseToPresentable = mapFromResponseToPresentable
    }
}

extension PaginationPresenter: PaginationViewInput {
    public func refresh() {
        perPage = max(remoteItemsStorage.get()?.count ?? 0, perPage)
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
            let totalPages = mapToTotalPages(model)
            let items = mapToItems(model)
            if backToPage == initialPage - 1 {
                remoteItemsStorage.set(model: items, completion: nil)
                view?.display(items: mapFromResponseToPresentable(model), hasMore: initialPage + totalPages - 1 >= page)
            } else {
                let previousItems = remoteItemsStorage.get() ?? []
                let items = mapToItems(model)
                remoteItemsStorage.set(model: previousItems + items, completion: nil)
                view?.display(
                    items: (previousItems + items).map { mapFromRemoteItemToPresentable($0) },
                    hasMore: initialPage + totalPages - 1 >= page
                )
            }
            self.totalPages = totalPages
        case .failure(let error):
            page = backToPage
            backToPage == initialPage - 1 ? view?.display(errorAtFirstPage: error.title) : view?.display(errorAtSubsequentPage: error.title)
        }
    }
}
