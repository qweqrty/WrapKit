//
//  TokenRefresher.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/9/23.
//

import Foundation
import Combine

public struct Tokens {
    public let accessToken: String
    public let refreshToken: String?
    
    public init(accessToken: String, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public protocol TokenRefresher {
    func refresh(completion: @escaping (Result<Tokens, ServiceError>) -> Void)
}

public class TokenRefresherImpl<RefreshRequest, RefreshResponse>: TokenRefresher {
    private let refreshTokenStorage: any Storage<String>
    private let refreshService: any Service<RefreshRequest, RefreshResponse>
    private let mapRefreshRequest: (String) -> RefreshRequest
    private let mapResponseToAccess: ((RefreshResponse) -> String)?
    private let mapResponseToRefresh: ((RefreshResponse) -> String?)?
    
    private var isAuthenticating = false
    private var authenticationLock = DispatchQueue(label: "com.tokenRefresher.lock")
    private var pendingCompletions: [(Result<Tokens, ServiceError>) -> Void] = []
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        refreshTokenStorage: any Storage<String>,
        refreshService: any Service<RefreshRequest, RefreshResponse>,
        mapRefreshRequest: @escaping (String) -> RefreshRequest,
        mapResponseToAccess: ((RefreshResponse) -> String)?,
        mapResponseToRefresh: ((RefreshResponse) -> String?)? = nil
    ) {
        self.refreshTokenStorage = refreshTokenStorage
        self.refreshService = refreshService
        self.mapRefreshRequest = mapRefreshRequest
        self.mapResponseToAccess = mapResponseToAccess
        self.mapResponseToRefresh = mapResponseToRefresh
    }
    
    public func refresh(completion: @escaping (Result<Tokens, ServiceError>) -> Void) {
        var shouldStartAuthentication = false
        
        authenticationLock.sync {
            if isAuthenticating {
                pendingCompletions.append(completion)
                return
            }
            
            isAuthenticating = true
            shouldStartAuthentication = true
            pendingCompletions.append(completion)
        }
        
        guard shouldStartAuthentication else { return }
        
        guard let refreshToken = refreshTokenStorage.get() else {
            completeAll(with: .failure(.internal))
            return
        }
        
        let refreshRequest = mapRefreshRequest(refreshToken)
        
        refreshService.make(request: refreshRequest)
            .handle(
                onSuccess: { [weak self] response in
                    guard let self, let newAccess = self.mapResponseToAccess?(response), !newAccess.isEmpty else {
                        self?.completeAll(with: .failure(.internal))
                        return
                    }
                    let newRefresh = self.mapResponseToRefresh?(response)
                    self.completeAll(with: .success(Tokens(accessToken: newAccess, refreshToken: newRefresh)))
                },
                onError: { [weak self] error in
                    self?.completeAll(with: .failure(error))
                }
            )
    }
    
    private func completeAll(with result: Result<Tokens, ServiceError>) {
        var completions: [(Result<Tokens, ServiceError>) -> Void] = []
        
        authenticationLock.sync {
            isAuthenticating = false
            completions = pendingCompletions
            pendingCompletions.removeAll()
        }
        
        completions.forEach { $0(result) }
    }
}
