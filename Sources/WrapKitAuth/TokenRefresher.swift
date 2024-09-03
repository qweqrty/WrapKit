//
//  TokenRefresher.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/9/23.
//

import Foundation

public protocol TokenRefresher {
    func refresh(completion: @escaping (Result<String, ServiceError>) -> Void)
}

public class TokenRefresherImpl<RefreshRequest, RefreshResponse>: TokenRefresher {
    private let refreshTokenStorage: any Storage<String>
    private let refreshService: any Service<RefreshRequest, RefreshResponse>
    private let mapRefreshRequest: (String) -> RefreshRequest
    private let mapRefreshResponse: (RefreshResponse) -> String
    
    private var isAuthenticating = false
    private var authenticationLock = DispatchQueue(label: "com.tokenRefresher.lock")
    private var pendingCompletions: [(Result<String, ServiceError>) -> Void] = []
    
    public init(
        refreshTokenStorage: any Storage<String>,
        refreshService: any Service<RefreshRequest, RefreshResponse>,
        mapRefreshRequest: @escaping (String) -> RefreshRequest,
        mapRefreshResponse: @escaping (RefreshResponse) -> String
    ) {
        self.refreshTokenStorage = refreshTokenStorage
        self.refreshService = refreshService
        self.mapRefreshRequest = mapRefreshRequest
        self.mapRefreshResponse = mapRefreshResponse
    }

    public func refresh(completion: @escaping (Result<String, ServiceError>) -> Void) {
        authenticationLock.sync {
            if isAuthenticating {
                // Queue up the completion to be called later.
                pendingCompletions.append(completion)
                return
            }
            
            isAuthenticating = true
        }
        
        guard let refreshToken = refreshTokenStorage.get() else {
            completion(.failure(.notAuthorized))
            completeAll(with: .failure(.notAuthorized))
            return
        }

        let refreshRequest = mapRefreshRequest(refreshToken)
        
        refreshService.make(request: refreshRequest) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                let newToken = self.mapRefreshResponse(data)
                completion(.success(newToken))
                self.completeAll(with: .success(newToken))
            case .failure(let error):
                _ = refreshTokenStorage.set(model: nil)
                completion(.failure(error))
                self.completeAll(with: .failure(error))
            }
        }?.resume()
    }
    
    private func completeAll(with result: Result<String, ServiceError>) {
        authenticationLock.sync {
            isAuthenticating = false
            for completion in pendingCompletions {
                completion(result)
            }
            pendingCompletions.removeAll()
        }
    }
}
