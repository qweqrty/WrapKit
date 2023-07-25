//
//  URLSessionHTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public typealias Result = HTTPClient.Result
    public struct UnexpectedValuesRepresentation: Error {}

    private let session: URLSession
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func resume() {
            wrapped.resume()
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}

