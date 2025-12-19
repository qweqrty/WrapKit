//
//  SelectionFlow.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public struct ServicedSelectionModel<Request, Response> {
    public let model: SelectionPresenterModel
    public let service: any Service<Request, Response>
    public let storage: any Storage
    public let request: (() -> Request)
    public let response: ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    
    public init(
        model: SelectionPresenterModel,
        service: any Service<Request, Response>,
        storage: any Storage,
        request: @escaping () -> Request,
        response: @escaping (Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel]
    ) {
        self.model = model
        self.service = service
        self.storage = storage
        self.request = request
        self.response = response
    }
}

public protocol SelectionFlow: AnyObject {
    typealias Model = SelectionConfiguration
    
    func showSelection(model: SelectionPresenterModel)
    func close(with result: SelectionType?)
}

public protocol ServicedSelectionFlow<Request, Response>: AnyObject {
    associatedtype Request
    associatedtype Response
    func showSelection(model: ServicedSelectionModel<Request, Response>)
}
