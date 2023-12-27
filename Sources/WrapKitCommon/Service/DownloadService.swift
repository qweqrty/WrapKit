//
//  DownloadService.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/12/23.
//

import Foundation

//public struct DownloadRequest {
//    public let url: URL
//    public let onProgress: ((Double) -> Void)?
//}
//
//open class DownloadService: NSObject, Service, URLSessionDownloadDelegate {
//    public typealias Request = DownloadRequest
//    public typealias Response = URL  // Location of the downloaded file
//
//    private var session: URLSession
//    private var activeDownloads: [URL: DownloadTask] = [:]
//
//    public init(session: URLSession = URLSession(configuration: .default)) {
//        self.session = session
//        super.init()
//        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
//    }
//
//    public func make(request: DownloadRequest, completion: @escaping ((Result<URL, ServiceError>)) -> Void) -> HTTPClientTask? {
//        let downloadTask = session.downloadTask(with: request.url)
//        let taskWrapper = DownloadTask(task: downloadTask)
//        taskWrapper.onProgress = request.onProgress
//
//        downloadTask.resume()
//        activeDownloads[request.url] = taskWrapper
//        return taskWrapper
//    }
//
//    // URLSessionDownloadDelegate methods...
//
//    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        guard let url = downloadTask.originalRequest?.url else { return }
//        DispatchQueue.main.async {
//            self.activeDownloads[url]?.onProgress = nil
//            completion(.success(location))
//            self.activeDownloads.removeValue(forKey: url)
//        }
//    }
//
//    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        guard let url = downloadTask.originalRequest?.url,
//              let download = activeDownloads[url] else { return }
//
//        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//        DispatchQueue.main.async {
//            download.updateProgress(progress: progress)
//        }
//    }
//
//    // Implement error handling similar to the RemoteService
//}
