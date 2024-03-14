//
//  DownloadService.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/12/23.
//

import Foundation

public struct DownloadRequest {
    public let url: URL
    public let progressHandler: ((Double) -> Void)?

    public init(url: URL, progressHandler: ((Double) -> Void)? = nil) {
        self.url = url
        self.progressHandler = progressHandler
    }
}

open class DownloadService: Service {
    public typealias Request = DownloadRequest
    public typealias Response = URL
    private let downloadClient: HTTPDownloadClient
    private let makeDownloadRequest: (DownloadRequest) -> URLRequest?
    
    public init(downloadClient: HTTPDownloadClient, makeDownloadRequest: @escaping (DownloadRequest) -> URLRequest?) {
        self.downloadClient = downloadClient
        self.makeDownloadRequest = makeDownloadRequest
    }
    
    public func make(request: DownloadRequest, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        guard let urlRequest = makeDownloadRequest(request) else {
            completion(.failure(.internal))
            return nil
        }
        
        let task = downloadClient.download(urlRequest, progress: { progress in
            request.progressHandler?(progress)
        }, completion: { result in
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
        
        return task
    }
}
