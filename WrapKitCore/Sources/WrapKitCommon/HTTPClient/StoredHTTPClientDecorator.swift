//
//  StoredHTTPClientDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/12/23.
//

import Foundation

public class StoredHTTPClientDecorator<Model>: HTTPClient {
    private let decoratee: HTTPClient
    private let storage: any Storage<Model>
    private let enrichRequest: ((URLRequest, Model?) -> URLRequest)
    
    public init(
        decoratee: HTTPClient,
        storage: any Storage<Model>,
        enrichRequest: @escaping ((URLRequest, Model?) -> URLRequest)
    ) {
        self.decoratee = decoratee
        self.storage = storage
        self.enrichRequest = enrichRequest
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return decoratee.dispatch(enrichRequest(request, storage.get()), completion: completion)
    }
}

