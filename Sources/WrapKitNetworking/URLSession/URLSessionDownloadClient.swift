//
//  URLSessionDownloadClient.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/12/23.
//

import Foundation

public final class URLSessionDownloadClient: NSObject, HTTPDownloadClient {
    private let session: URLSession
    private var completionHandlers: [URLSessionTask: (DownloadResult) -> Void] = [:]
    private var progressHandlers: [URLSessionDownloadTask: (Double) -> Void] = [:]
    private var resumeData: [URLSessionDownloadTask: Data] = [:]

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionDownloadTask
        let cancelHandler: ((Data?) -> Void)
        
        func resume() {
            wrapped.resume()
        }
        
        func cancel() {
            wrapped.cancel(byProducingResumeData: cancelHandler)
        }
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
        super.init()
    }

    public func download(_ request: URLRequest, progress: @escaping (Double) -> Void, completion: @escaping (DownloadResult) -> Void) -> HTTPClientTask {
        let downloadTask = session.downloadTask(with: request)

        let taskWrapper = URLSessionTaskWrapper(wrapped: downloadTask, cancelHandler: { [weak self] resumeData in
            self?.storeResumeData(resumeData, for: downloadTask)
        })

        progressHandlers[downloadTask] = progress
        completionHandlers[downloadTask] = completion
        return taskWrapper
    }
    
    private func storeResumeData(_ data: Data?, for task: URLSessionDownloadTask) {
        if let data = data {
            resumeData[task] = data
        } else {
            resumeData.removeValue(forKey: task)
        }
    }
}


extension URLSessionDownloadClient: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completionHandlers[downloadTask]?(.success(location))
        completionHandlers.removeValue(forKey: downloadTask)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let downloadTask = task as? URLSessionDownloadTask {
            completionHandlers[downloadTask]?(.failure(error))
            completionHandlers.removeValue(forKey: downloadTask)
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandlers[downloadTask]?(progress)
    }
}
