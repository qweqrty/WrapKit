//
//  HTTPClientSpy.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import WrapKitNetworking

class HTTPClientSpy: HTTPClient {
    typealias Result = HTTPClient.Result
    
    private struct Task: HTTPClientTask {
        let resumeCallback: () -> Void
        let cancelCallback: () -> Void
        func resume() { resumeCallback() }
        func cancel() { cancelCallback() }
    }
    
    private var messages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private(set) var resumedURLs: [URL] = []
    private(set) var cancelledURLs: [URL] = []
    
    var requestedURLs: [URL] {
        return messages.compactMap { $0.requests.url }
    }
    
    var requestedURLRequests: [URLRequest] {
        return messages.map { $0.requests }
    }
    
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        messages.append((request, completion))
        return Task { [weak self] in
            self?.resumedURLs.append(request.url!)
        } cancelCallback: { [weak self] in
            self?.resumedURLs.append(request.url!)
        }
    }
    
    func completes(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}

