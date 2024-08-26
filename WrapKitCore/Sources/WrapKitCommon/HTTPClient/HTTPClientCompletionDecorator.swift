//
//  HTTPClientCompletionDecorator.swift
//
//
//  Created by Stanislav Li on 26/8/24.
//

import Foundation

public class HTTPClientCompletionDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let completion: ((HTTPClient.Result) -> Void)
    
    public init(
        decoratee: HTTPClient,
        completion: @escaping ((HTTPClient.Result) -> Void)
    ) {
        self.decoratee = decoratee
        self.completion = completion
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return decoratee.dispatch(request, completion: { [weak self] result in
            self?.completion(result)
            completion(result)
        })
    }
}
