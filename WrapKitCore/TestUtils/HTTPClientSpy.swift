//
//  HTTPClientSpy.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import WrapKit

public class HTTPClientSpy: HTTPClient {
    public typealias Result = HTTPClient.Result
    
    public struct Task: HTTPClientTask {
        public let resumeCallback: () -> Void
        public let cancelCallback: () -> Void
        public func resume() { resumeCallback() }
        public func cancel() { cancelCallback() }
    }
    
    public private(set) var messages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private let queue = DispatchQueue(label: "com.httpclientspy.queue") // Serial queue for synchronization
    public private(set) var resumedURLs: [URL] = []
    public private(set) var cancelledURLs: [URL] = []
    public private(set) var completedResponses: [HTTPClient.Result] = []
    
    public var requestedURLs: [URL] {
        return messages.compactMap { $0.requests.url }
    }
    
    public var requestedURLRequests: [URLRequest] {
        return messages.map { $0.requests }
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        queue.sync {
                    messages.append((request, completion))
                }
        return Task(resumeCallback: { [weak self] in
            self?.resumedURLs.append(request.url!)
        }, cancelCallback: { [weak self] in
            self?.cancelledURLs.append(request.url!)
        })
    }
    
    public func completes(with error: Error, at index: Int = 0) {
        queue.sync {
            completedResponses.append(.failure(error))
            messages[index].completion(.failure(error))
        }
    }
    
    public func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
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
