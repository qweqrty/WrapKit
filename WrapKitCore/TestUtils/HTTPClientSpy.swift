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
    
    public init() { }
    
    public struct Task: HTTPClientTask {
        public let resumeCallback: () -> Void
        public let cancelCallback: () -> Void
        public func resume() { resumeCallback() }
        public func cancel() { cancelCallback() }
    }
    
    private let lock = NSLock()
    private var recordedMessages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private var recordedResumedURLs: [URL] = []
    private var recordedCancelledURLs: [URL] = []
    private var recordedCompletedResponses: [HTTPClient.Result] = []

    public var messages: [(requests: URLRequest, completion: (Result) -> Void)] {
        synchronized { recordedMessages }
    }

    public var resumedURLs: [URL] {
        synchronized { recordedResumedURLs }
    }

    public var cancelledURLs: [URL] {
        synchronized { recordedCancelledURLs }
    }

    public var completedResponses: [HTTPClient.Result] {
        synchronized { recordedCompletedResponses }
    }
    
    public var requestedURLs: [URL] {
        return messages.compactMap { $0.requests.url }
    }
    
    public var requestedURLRequests: [URLRequest] {
        return messages.map { $0.requests }
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        synchronized { recordedMessages.append((request, completion)) }
        return Task(resumeCallback: { [weak self] in
            guard let self else { return }
            self.synchronized { self.recordedResumedURLs.append(request.url!) }
        }, cancelCallback: { [weak self] in
            guard let self else { return }
            self.synchronized { self.recordedCancelledURLs.append(request.url!) }
        })
    }
    
    public func completes(with error: Error, at index: Int = 0) {
        let result = HTTPClient.Result.failure(error)
        let completion = synchronized {
            recordedCompletedResponses.append(result)
            return recordedMessages[index].completion
        }
        completion(result)
    }
    
    public func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let (completion, result) = synchronized {
            let message = recordedMessages[index]
            let response = HTTPURLResponse(
                url: message.requests.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            let result = HTTPClient.Result.success((data, response))
            recordedCompletedResponses.append(result)
            return (message.completion, result)
        }
        completion(result)
    }

    private func synchronized<Value>(_ action: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
}
