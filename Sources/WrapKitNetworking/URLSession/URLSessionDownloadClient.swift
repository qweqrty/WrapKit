//
//  URLSessionDownloadClient.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/12/23.
//

import Foundation

open class DownloadService {
    public typealias DownloadCompletionHandler = (Result<URL, ServiceError>) -> Void
    public typealias DownloadProgressHandler = (Double) -> Void
    public typealias MakeDownloadRequest = (URL) -> URLRequest?

    private let downloadClient: HTTPDownloadClient
    private let makeDownloadRequest: MakeDownloadRequest

    public init(downloadClient: HTTPDownloadClient, makeDownloadRequest: @escaping MakeDownloadRequest) {
        self.downloadClient = downloadClient
        self.makeDownloadRequest = makeDownloadRequest
    }

    public func download(from url: URL, progress: @escaping DownloadProgressHandler, completion: @escaping DownloadCompletionHandler) -> HTTPClientTask? {
        guard let urlRequest = makeDownloadRequest(url) else {
            completion(.failure(.internal))
            return nil
        }

        return downloadClient.download(urlRequest, progress: progress, completion: { result in
            switch result {
            case .success(let fileURL):
                completion(.success(fileURL))
            case .failure(let error):
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.connectivity))
                } else {
                    completion(.failure(.internal))
                }
            }
        })
    }
}
