//
//  HTTPClientDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 18/5/24.
//

import Foundation

public class EncrichHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let enrichRequest: ((URLRequest) -> URLRequest)
    
    public init(
        decoratee: HTTPClient,
        enrichRequest: @escaping ((URLRequest) -> URLRequest)
    ) {
        self.decoratee = decoratee
        self.enrichRequest = enrichRequest
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return decoratee.dispatch(enrichRequest(request), completion: completion)
    }
}
