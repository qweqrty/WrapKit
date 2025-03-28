//
//  TokenRefresher.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/9/23.
//

import Foundation
import Combine

public protocol TokenRefresher {
    func refresh(completion: @escaping (Result<String, ServiceError>) -> Void)
}

public class TokenRefresherImpl<RefreshRequest, RefreshResponse>: TokenRefresher {
    private let refreshTokenStorage: any Storage<String>
    private let refreshService: any Service<RefreshRequest, RefreshResponse>
    private let mapRefreshRequest: (String) -> RefreshRequest
    private let mapResponseToAccess: ((RefreshResponse) -> String)?
    private let mapResponseToRefresh: ((RefreshResponse) -> String?)?
    
    private var isAuthenticating = false
    private var authenticationLock = DispatchQueue(label: "com.tokenRefresher.lock")
    private var pendingCompletions: [(Result<String, ServiceError>) -> Void] = []
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

    public func refresh(completion: @escaping (Result<String, ServiceError>) -> Void) {
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
                    guard let self else { return }
                    guard let newToken = self.mapResponseToAccess?(response) else { return }
                    if let newRefreshToken = self.mapResponseToRefresh?(response) {
                        self.refreshTokenStorage.set(model: newRefreshToken)
                    }
                    self.completeAll(with: .success(newToken))
                },
                onError: { [weak self] error in
                    self?.completeAll(with: .failure(error))
                }
            )
    }
    
    private func completeAll(with result: Result<String, ServiceError>) {
        var completions: [(Result<String, ServiceError>) -> Void] = [] // Initialize as mutable

        authenticationLock.sync {
            isAuthenticating = false
            completions = pendingCompletions
            pendingCompletions.removeAll()
        }

        completions.forEach { $0(result) }
    }
}
