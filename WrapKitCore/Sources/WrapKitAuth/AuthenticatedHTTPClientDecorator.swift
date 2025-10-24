//
//  AuthenticatedHTTPClientDecorator.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import Combine

public class AuthenticatedHTTPClientDecorator<RefreshRequest, RefreshResponse>: HTTPClient {
    public enum AuthenticationPolicyResult {
        case authenticated
        case needsRefresh(onErrorMessage: String?)
        case logout(message: String?)
    }
    public typealias EnrichRequestWithToken = ((URLRequest, String) -> URLRequest)
    public typealias AuthenticationPolicy = (((Data, HTTPURLResponse)) -> AuthenticationPolicyResult)
    
    private let decoratee: HTTPClient
    private let accessTokenStorage: any Storage<String>
    private let refreshTokenStorage: any Storage<String>
    private let refreshService: (any Service<RefreshRequest, RefreshResponse>)?
    private let mapRefreshRequest: ((String) -> RefreshRequest)?
    private let mapResponseToAccess: ((RefreshResponse) -> String)?
    private let mapResponseToRefresh: ((RefreshResponse) -> String?)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    private let onNotAuthenticated: ((String?) -> Void)?
    
    private let lock = NSLock()
    
    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        refreshTokenStorage: any Storage<String>,
        refreshService: (any Service<RefreshRequest, RefreshResponse>)?,
        mapRefreshRequest: ((String) -> RefreshRequest)?,
        mapResponseToAccess: ((RefreshResponse) -> String)?,
        mapResponseToRefresh: ((RefreshResponse) -> String?)?,
        onNotAuthenticated: ((String?) -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
        self.refreshTokenStorage = refreshTokenStorage
        self.refreshService = refreshService
        self.mapRefreshRequest = mapRefreshRequest
        self.mapResponseToAccess = mapResponseToAccess
        self.mapResponseToRefresh = mapResponseToRefresh
        self.onNotAuthenticated = onNotAuthenticated
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return dispatch(request, completion: completion, isRetryNeeded: true)
    }
    
    private func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void, isRetryNeeded: Bool) -> HTTPClientTask {
        lock.lock()
        defer { lock.unlock() }
        guard let token = accessTokenStorage.get(), !token.isEmpty else {
            return CompositeHTTPClientTask()
        }
        
        let compositeTask = CompositeHTTPClientTask(tasks: [])
        let enrichedRequest = enrichRequestWithToken(request, token)
        let firstTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                let currentToken = self.accessTokenStorage.get()
                let result = self.isAuthenticated((data, response))
                switch result {
                case .authenticated:
                    completion(.success((data, response)))
                case .logout(let message):
                    refreshTokenStorage.clear()
                    accessTokenStorage.clear()
                    self.onNotAuthenticated?(message)
                case .needsRefresh(let message):
                    if isRetryNeeded {
                        guard let refreshToken =  refreshTokenStorage.get(),
                                let refreshRequest = self.mapRefreshRequest?(refreshToken),
                                let refreshService = self.refreshService else {
                            return
                        }
                        lock.lock()
                        refreshService
                            .make(request: refreshRequest)
                            .handle(
                                onSuccess: { [weak self] response in
                                    if let mapResponseToAccess = self?.mapResponseToAccess {
                                        self?.accessTokenStorage.set(model: mapResponseToAccess(response))
                                    }
                                    if let mapResponseToRefresh = self?.mapResponseToRefresh {
                                        self?.refreshTokenStorage.set(model: mapResponseToRefresh(response))
                                    }
                                    self?.retryRequest(request, completion: completion, compositeTask: compositeTask)
                                },
                                onError: { [weak self] error in
                                    self?.refreshTokenStorage.clear()
                                    self?.accessTokenStorage.clear()
                                    self?.onNotAuthenticated?(message)
                                },
                                onCompletion: { [weak self] in
                                    self?.lock.unlock()
                                }
                            )
                    } else {
                        refreshTokenStorage.clear()
                        accessTokenStorage.clear()
                        self.onNotAuthenticated?(message)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(firstTask)
        return compositeTask
    }
    
    private func retryRequest(
        _ request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void,
        compositeTask: CompositeHTTPClientTask
    ) {
        guard let token = accessTokenStorage.get(), !token.isEmpty else {
            return
        }
        
        let enrichedRequest = enrichRequestWithToken(request, token)
        
        let newTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                let authenticationResult = self.isAuthenticated((data, response))
                switch authenticationResult {
                case .authenticated:
                    completion(.success((data, response)))
                case .logout(let message), .needsRefresh(let message):
                    self.refreshTokenStorage.clear()
                    self.accessTokenStorage.clear()
                    self.onNotAuthenticated?(message)
                    completion(.failure(ServiceError.internal))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(newTask)
        newTask.resume()
    }
}
