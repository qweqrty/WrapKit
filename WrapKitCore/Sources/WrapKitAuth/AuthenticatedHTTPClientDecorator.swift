//
//  AuthenticatedHTTPClientDecorator.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import Combine

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public static var ongoingRefresh: AnyPublisher<String, ServiceError>?
    
    public typealias EnrichRequestWithToken = ((URLRequest, String) -> URLRequest)
    public typealias AuthenticationPolicy = (((Data, HTTPURLResponse)) -> Bool)
    
    private let decoratee: HTTPClient
    private let tokenLock: DispatchQueue
    private let accessTokenStorage: any Storage<String>
    private let refreshTokenStorage: any Storage<String>
    private var tokenRefresher: TokenRefresher?
    private let onNotAuthenticated: (() -> Void)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy

    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        refreshTokenStorage: any Storage<String>,
        tokenRefresher: TokenRefresher?,
        onNotAuthenticated: (() -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy,
        tokenLock: DispatchQueue = DispatchQueue(label: "com.wrapkit.tokenLock")
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
        self.refreshTokenStorage = refreshTokenStorage
        self.tokenRefresher = tokenRefresher
        self.onNotAuthenticated = onNotAuthenticated
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
        self.tokenLock = tokenLock
    }

    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return dispatch(request, completion: completion, isRetryNeeded: true)
    }
    
    private func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void, isRetryNeeded: Bool) -> HTTPClientTask {
        guard let token = synchronizedTokenAccess({ accessTokenStorage.get() }), !token.isEmpty else {
            refreshTokenStorage.clear()
            onNotAuthenticated?()
            return CompositeHTTPClientTask()
        }

        let compositeTask = CompositeHTTPClientTask(tasks: [])
        let enrichedRequest = enrichRequestWithToken(request, token)
        let firstTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                let currentToken = synchronizedTokenAccess { self.accessTokenStorage.get() } // Add sync
                if self.isAuthenticated((data, response)) {
                    completion(.success((data, response)))
                } else if currentToken != token && !currentToken.isEmpty {
                    let task = dispatch(request, completion: completion, isRetryNeeded: true)
                    task.resume()
                    compositeTask.add(task)
                } else if isRetryNeeded {
                    refreshToken(completion: { [weak self] newToken in
                        if let newToken = newToken, !newToken.isEmpty {
                            self?.retryRequest(request, completion: completion, compositeTask: compositeTask)
                        } else {
                            self?.refreshTokenStorage.clear()
                            self?.accessTokenStorage.clear()
                            self?.onNotAuthenticated?()
                        }
                    }, compositeTask: compositeTask)
                } else {
                    refreshTokenStorage.clear()
                    accessTokenStorage.clear()
                    self.onNotAuthenticated?()
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(firstTask)
        return compositeTask
    }
    
    public func refreshToken(
        completion: @escaping (String?) -> Void,
        compositeTask: CompositeHTTPClientTask
    ) {
        guard let tokenRefresher = tokenRefresher else {
            completion(nil)
            return
        }

        if let ongoingRefresh = synchronizedTokenAccess({ Self.ongoingRefresh }) {
            ongoingRefresh
                .handle(
                    onSuccess: { newToken in
                        completion(newToken)
                    },
                    onError: { _ in
                        completion(nil)
                    }
                )
            return
        }

        var publisherToSubscribe: AnyPublisher<String, ServiceError>?
        tokenLock.sync {
            if Self.ongoingRefresh == nil {
                let refreshPublisher = Future<String, ServiceError> { promise in
                    tokenRefresher.refresh { result in
                        promise(result)
                    }
                }
                .flatMap { [weak self] newToken -> AnyPublisher<String, ServiceError> in
                    guard let self else {
                        self?.accessTokenStorage.set(model: newToken)
                        return Just(newToken).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
                    }
                    return accessTokenStorage.set(model: newToken)
                        .map { _ in newToken }
                        .setFailureType(to: ServiceError.self)
                        .eraseToAnyPublisher()
                }
                .handleEvents(receiveCompletion: { _ in
                    self.synchronizedTokenAccess { Self.ongoingRefresh = nil }
                })
                .eraseToAnyPublisher()

                Self.ongoingRefresh = refreshPublisher
                publisherToSubscribe = refreshPublisher
            } else {
                publisherToSubscribe = Self.ongoingRefresh
            }
        }

        guard let publisherToSubscribe = publisherToSubscribe else { return }
        publisherToSubscribe
            .handle(
                onSuccess: { newToken in
                    completion(newToken)
                },
                onError: { [weak self] _ in
                    self?.refreshTokenStorage.clear()
                    self?.accessTokenStorage.clear()
                    completion(nil)
                }
            )
    }

    private func retryRequest(
        _ request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void,
        compositeTask: CompositeHTTPClientTask
    ) {
        guard let token = synchronizedTokenAccess({ accessTokenStorage.get() }), !token.isEmpty else { // Add sync and empty check
            onNotAuthenticated?()
            return
        }
        
        let enrichedRequest = enrichRequestWithToken(request, token)
        
        let newTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                if self.isAuthenticated((data, response)) {
                    completion(.success((data, response)))
                } else {
                    self.refreshTokenStorage.clear()
                    self.accessTokenStorage.clear()
                    self.onNotAuthenticated?()
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(newTask)
        newTask.resume()
    }

    @discardableResult
    private func synchronizedTokenAccess<T>(_ block: () -> T) -> T {
        return tokenLock.sync {
            return block()
        }
    }
}
