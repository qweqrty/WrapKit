//
//  HTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 24/7/23.
//

import Foundation

public class CompositeHTTPClientTask: HTTPClientTask {
    private var tasks: [HTTPClientTask]
    private let lock = NSLock()
    private var cancelled = false
    private var resumed = false
    private var finished = false

    public var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }

    public init(tasks: [HTTPClientTask] = []) {
        self.tasks = tasks
    }

    public func add(_ task: HTTPClientTask) {
        lock.lock()
        let shouldCancel = cancelled || finished
        let shouldResume = resumed
        if !shouldCancel { tasks.append(task) }
        lock.unlock()
        if shouldCancel { task.cancel() }
        else if shouldResume { task.resume() }
    }

    public func resume() {
        lock.lock()
        guard !cancelled, !resumed else { lock.unlock(); return }
        resumed = true
        let pending = tasks
        lock.unlock()
        pending.forEach { $0.resume() }
    }

    public func cancel() {
        lock.lock()
        guard !cancelled else { lock.unlock(); return }
        cancelled = true
        let pending = tasks
        tasks.removeAll()
        lock.unlock()
        pending.forEach { $0.cancel() }
    }

    func finish() {
        lock.lock()
        finished = true
        tasks.removeAll()
        lock.unlock()
    }
}

public protocol HTTPClientTask {
    func cancel()
    func resume()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>
    
    @discardableResult
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public protocol HTTPDownloadClient {
    typealias DownloadResult = Swift.Result<URL, Error>

    @discardableResult
    func download(_ request: URLRequest, progress: @escaping (Double) -> Void, completion: @escaping (DownloadResult) -> Void) -> HTTPClientTask
}

public class MockHTTPClient: HTTPClient {
    private class MockHTTPClientTask: HTTPClientTask {
        private let resumeAction: () -> Void
        private var isCancelled = false
        init(resumeAction: @escaping () -> Void) {
            self.resumeAction = resumeAction
        }
        func resume() {
            guard !isCancelled else { return }
            resumeAction()
        }
        func cancel() {
            isCancelled = true
        }
    }
    
    public struct Response {
        public let json: String
        public let statusCode: Int
        
        public init(json: String, statusCode: Int = 200) {
            self.json = json
            self.statusCode = statusCode
        }
    }
    
    private let responses: [Response]
    private var responseIndex: Int = 0
    
    public init(responses: [Response]) {
        self.responses = responses
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result<(data: Data, response: HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        let mockTask = MockHTTPClientTask { [weak self] in
            guard let self else { return }
            if let response = responses.item(at: responseIndex), let url = request.url, let data = response.json.data(using: .utf8), let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: response.statusCode,
                httpVersion: "1.1",
                headerFields: ["Content-Type": "application/json"]
            ) {
                completion(.success((data: data, response: httpResponse)))
                responseIndex += 1
            } else if let response = responses.item(at: 0), let url = request.url, let data = response.json.data(using: .utf8), let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: response.statusCode,
                httpVersion: "1.1",
                headerFields: ["Content-Type": "application/json"]
            ) {
                completion(.success((data: data, response: httpResponse)))
            } else {
                completion(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: nil)))
            }
        }
        return mockTask
    }
}
