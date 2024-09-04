//
//  HTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 24/7/23.
//

import Foundation

public class CompositeHTTPClientTask: HTTPClientTask {
    private var tasks: [HTTPClientTask]

    public init(tasks: [HTTPClientTask] = []) {
        self.tasks = tasks
    }

    public func add(_ task: HTTPClientTask) {
        tasks.append(task)
    }

    public func resume() {
        tasks.forEach { $0.resume() }
    }

    public func cancel() {
        tasks.forEach { $0.cancel() }
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
