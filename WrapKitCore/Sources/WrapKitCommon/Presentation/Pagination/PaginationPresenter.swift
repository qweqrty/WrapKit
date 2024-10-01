//
//  PaginationPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public protocol PaginationViewOutput<PresentableItem>: AnyObject {
    associatedtype PresentableItem
    func display(model: [PresentableItem], hasMore: Bool)
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


open class PaginationPresenter<ServicePaginationRequest, ServicePaginationResponse, RemoteItem, PresentableModel> {
    public let remoteItemsStorage: any Storage<[RemoteItem]>

    private(set) var date: Date
    private(set) var page: Int
    private(set) var totalPages: Int?

    public var mapRequest: ((PaginationRequest) -> ServicePaginationRequest?)
    private var perPage: Int
    private let initialPerPage: Int
    private let service: any Service<ServicePaginationRequest, ServicePaginationResponse> // Expected to be SerialServiceDecorator
    private let mapToTotalPages: ((ServicePaginationResponse) -> Int)
    private let mapFromResponseToRemoteItems: ((ServicePaginationResponse) -> [RemoteItem])
    private let mapFromRemoteItemToPresentable: ((RemoteItem) -> PresentableModel)
    private var requests = [HTTPClientTask?]()
    
    let initialPage: Int

    public weak var view: (any PaginationViewOutput<PresentableModel>)?

    public init(
        service: any Service<ServicePaginationRequest, ServicePaginationResponse>,
        mapRequest: @escaping ((PaginationRequest) -> ServicePaginationRequest?),
        mapToTotalPages: @escaping ((ServicePaginationResponse) -> Int),
        mapFromResponseToRemoteItems: @escaping ((ServicePaginationResponse) -> [RemoteItem]),
        mapFromRemoteItemToPresentable: @escaping ((RemoteItem) -> PresentableModel),
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
        self.perPage = perPage
        self.initialPerPage = perPage
        self.mapRequest = mapRequest
        self.mapToTotalPages = mapToTotalPages
        self.mapFromResponseToRemoteItems  = mapFromResponseToRemoteItems
        self.mapFromRemoteItemToPresentable = mapFromRemoteItemToPresentable
    }
}

extension PaginationPresenter: PaginationViewInput {
    public func refresh() {
        perPage = max(remoteItemsStorage.get()?.count ?? 0, initialPerPage)
        guard let request = mapRequest(.init(page: initialPage, date: Date(), perPage: perPage)) else { return }
        date = Date()
        page = initialPage
        requests.forEach { $0?.cancel() }
        requests.removeAll()
        view?.display(isLoadingSubsequentPage: false)
        view?.display(isLoadingFirstPage: true)
        let task = service.make(request: request) { [weak self, initialPage] result in
            self?.view?.display(isLoadingFirstPage: false)
            self?.perPage = self?.initialPage ?? 10
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
            let remoteItems = mapFromResponseToRemoteItems(model)
            if backToPage == initialPage - 1 {
                _ = remoteItemsStorage.set(model: remoteItems)
                view?.display(model: remoteItems.map { mapFromRemoteItemToPresentable($0) }, hasMore: initialPage + totalPages - 1 >= page)
            } else {
                let previousItems = remoteItemsStorage.get() ?? []
                _ = remoteItemsStorage.set(model: previousItems + remoteItems)
                view?.display(
                    model: (previousItems + remoteItems).map { mapFromRemoteItemToPresentable($0) },
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
