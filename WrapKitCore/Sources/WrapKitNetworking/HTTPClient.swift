//
//  HTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 24/7/23.
//

import Foundation

public class CompositeHTTPClientTask: HTTPClientTask {
    private var tasks: [HTTPClientTask]
    private let queue = DispatchQueue(label: "com.compositeHTTPClientTask.queue", attributes: .concurrent) // Concurrent queue

    public init(tasks: [HTTPClientTask] = []) {
        self.tasks = tasks
    }

    public func add(_ task: HTTPClientTask) {
        queue.async(flags: .barrier) { // Barrier to ensure exclusive write access
            self.tasks.append(task)
        }
    }

    public func resume() {
        queue.sync { // Sync read for thread safety
            self.tasks.forEach { $0.resume() }
        }
    }

    public func cancel() {
        queue.sync { // Sync read for thread safety
            self.tasks.forEach { $0.cancel() }
        }
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
