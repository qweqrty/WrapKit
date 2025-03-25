//
//  HTTPClientSpy.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import WrapKit

class HTTPClientSpy: HTTPClient {
    typealias Result = HTTPClient.Result
    
    private struct Task: HTTPClientTask {
        let resumeCallback: () -> Void
        let cancelCallback: () -> Void
        func resume() { resumeCallback() }
        func cancel() { cancelCallback() }
    }
    
    private var messages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private let queue = DispatchQueue(label: "com.httpclientspy.queue") // Serial queue for synchronization
    private(set) var resumedURLs: [URL] = []
    private(set) var cancelledURLs: [URL] = []
    private(set) var completedResponses: [HTTPClient.Result] = []
    
    var requestedURLs: [URL] {
        return messages.compactMap { $0.requests.url }
    }
    
    var requestedURLRequests: [URLRequest] {
        return messages.map { $0.requests }
    }
    
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        queue.sync {
                    messages.append((request, completion))
                }
        return Task(resumeCallback: { [weak self] in
            self?.resumedURLs.append(request.url!)
        }, cancelCallback: { [weak self] in
            self?.cancelledURLs.append(request.url!)
        })
    }
    
    func completes(with error: Error, at index: Int = 0) {
        queue.sync {
            completedResponses.append(.failure(error))
            messages[index].completion(.failure(error))
        }
    }
    
    func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
        queue.sync {
            let response = HTTPURLResponse(
                url: self.requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            let result = HTTPClient.Result.success((data, response))
            self.completedResponses.append(result)
            self.messages[index].completion(result)
        }
    }
}
