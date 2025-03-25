//
//  AuthenticatedHTTPClientDecorator.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import Combine

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public typealias EnrichRequestWithToken = ((URLRequest, String) -> URLRequest)
    public typealias AuthenticationPolicy = (((Data, HTTPURLResponse)) -> Bool)
    
    private let decoratee: HTTPClient
    private let tokenLock: DispatchQueue
    private let accessTokenStorage: any Storage<String>
    private var tokenRefresher: TokenRefresher?
    private let onNotAuthenticated: (() -> Void)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    private var ongoingRefresh: AnyPublisher<String, ServiceError>?

    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        tokenRefresher: TokenRefresher?,
        onNotAuthenticated: (() -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy,
        tokenLock: DispatchQueue = DispatchQueue(label: "com.wrapkit.tokenLock")
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
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
            onNotAuthenticated?()
            return CompositeHTTPClientTask()
        }

        let compositeTask = CompositeHTTPClientTask(tasks: [])
        let enrichedRequest = enrichRequestWithToken(request, token)
        let firstTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                if self.isAuthenticated((data, response)) {
                    completion(.success((data, response)))
                } else if isRetryNeeded {
                    self.refreshTokenAndRetry(request, completion: completion, compositeTask: compositeTask)
                } else {
                    self.onNotAuthenticated?()
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(firstTask)
        return compositeTask
    }

    private func refreshTokenAndRetry(
        _ request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void,
        compositeTask: CompositeHTTPClientTask
    ) {
        guard let tokenRefresher = tokenRefresher else {
            onNotAuthenticated?()
            return
        }

        if let ongoingRefresh = synchronizedTokenAccess({ ongoingRefresh }) {
            ongoingRefresh
                .handle(
                    onSuccess: { [weak self] newToken in
                        self?.retryRequest(request, with: newToken, completion: completion, compositeTask: compositeTask)
                    },
                    onError: { [weak self] error in
                        self?.onNotAuthenticated?()
                    }
                )
            return
        }

        let refreshPublisher = Future<String, ServiceError> { promise in
            tokenRefresher.refresh { result in
                promise(result)
            }
        }
        .handleEvents(receiveCompletion: { [weak self] _ in
            self?.synchronizedTokenAccess { self?.ongoingRefresh = nil }
        })
        .eraseToAnyPublisher()

        synchronizedTokenAccess { self.ongoingRefresh = refreshPublisher }

        refreshPublisher
            .handle(
                onSuccess: { [weak self] newToken in
                    self?.synchronizedTokenAccess {
                        self?.accessTokenStorage.set(model: newToken)
                    }
                    self?.retryRequest(request, with: newToken, completion: completion, compositeTask: compositeTask)
                },
                onError: { [weak self] error in
                    self?.onNotAuthenticated?()
                }
            )
    }

    private func retryRequest(_ request: URLRequest, with token: String, completion: @escaping (HTTPClient.Result) -> Void, compositeTask: CompositeHTTPClientTask) {
        let enrichedRequest = enrichRequestWithToken(request, token)
        let newTask = dispatch(enrichedRequest, completion: completion, isRetryNeeded: false)
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
