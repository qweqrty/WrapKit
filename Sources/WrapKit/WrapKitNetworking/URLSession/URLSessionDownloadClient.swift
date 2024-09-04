//
//  URLSessionDownloadClient.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/12/23.
//

import Foundation

public final class URLSessionDownloadClient: NSObject, HTTPDownloadClient {
    private let directoryURL: URL
    private let fileManager: FileManager
    private var session: URLSession
    private var completionHandlers: [URLRequest: (DownloadResult) -> Void] = [:]
    private var progressHandlers: [URLRequest: (Double) -> Void] = [:]
    private var resumeData: [URLRequest: Data] = [:]
    
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
    
    public init(session: URLSession? = nil, directoryURL: URL, fileManager: FileManager = .default) {
        self.session = .shared
        self.directoryURL = directoryURL
        self.fileManager = fileManager
        super.init()

        if let session = session {
            self.session = session
        } else {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }

    public func download(_ request: URLRequest, progress: @escaping (Double) -> Void, completion: @escaping (DownloadResult) -> Void) -> HTTPClientTask {
        let downloadTask = session.downloadTask(with: request)

        let taskWrapper = URLSessionTaskWrapper(wrapped: downloadTask, cancelHandler: { [weak self] resumeData in
            self?.storeResumeData(resumeData, for: request)
        })

        progressHandlers[request] = progress
        completionHandlers[request] = completion
        return taskWrapper
    }
    
    private func storeResumeData(_ data: Data?, for request: URLRequest) {
        if let data = data {
            resumeData[request] = data
        } else {
            resumeData.removeValue(forKey: request)
        }
    }
}


extension URLSessionDownloadClient: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let request = downloadTask.originalRequest else  { return }
        guard let fileName = request.url?.lastPathComponent else { return }
         do {
             let permanentURL = directoryURL.appendingPathComponent(fileName)
             if fileManager.fileExists(atPath: permanentURL.path) {
                 try fileManager.removeItem(at: permanentURL)
             }
             try fileManager.moveItem(at: location, to: permanentURL)
             completionHandlers[request]?(.success(permanentURL))
         } catch {
             completionHandlers[request]?(.failure(ServiceError.internal))
         }
        completionHandlers.removeValue(forKey: request)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let request = task.originalRequest else  { return }
        guard let error = error else  { return }
        completionHandlers[request]?(.failure(error))
        completionHandlers.removeValue(forKey: request)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let request = downloadTask.originalRequest else  { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandlers[request]?(progress)
    }
}
