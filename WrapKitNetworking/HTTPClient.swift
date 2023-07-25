//
//  HTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 24/7/23.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
    func resume()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>
    
    @discardableResult
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
