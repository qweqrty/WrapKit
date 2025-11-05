//
//  AuthenticatedHTTPClientDecorator.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import Combine

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public enum AuthenticationPolicyResult {
        case authenticated
        case needsRefresh(onErrorMessage: String?)
        case logout(message: String?)
    }
    public static let tokenLock = DispatchQueue(label: "com.wrapkit.tokenLock")
    public static var ongoingRefresh: AnyPublisher<Tokens, ServiceError>?
    public static var hasHandledUnauthenticated = false
    
    public typealias EnrichRequestWithToken = ((URLRequest, String) -> URLRequest)
    public typealias AuthenticationPolicy = (((Data, HTTPURLResponse)) -> AuthenticationPolicyResult)
    
    private let decoratee: HTTPClient
    
    private let accessTokenStorage: any Storage<String>
    private let refreshTokenStorage: any Storage<String>
    private var tokenRefresher: TokenRefresher
    private let onNotAuthenticated: ((String?) -> Void)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        refreshTokenStorage: any Storage<String>,
        tokenRefresher: TokenRefresher,
        onNotAuthenticated: ((String?) -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
        self.refreshTokenStorage = refreshTokenStorage
        self.tokenRefresher = tokenRefresher
        self.onNotAuthenticated = onNotAuthenticated
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
        
        accessTokenStorage.publisher
            .sink { [weak self] value in
                if let value = value, !value.isEmpty {
                    Self.tokenLock.sync {
                        Self.hasHandledUnauthenticated = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return dispatch(request, completion: completion, isRetryNeeded: true)
    }
    
    private func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void, isRetryNeeded: Bool) -> HTTPClientTask {
        
        // Nothing to enrich case
        guard let token = synchronizedTokenAccess({ accessTokenStorage.get() }), !token.isEmpty else {
            handleUnauthenticated(message: nil)
            completion(.failure(ServiceError.internal))
            return CompositeHTTPClientTask()
        }
        
        let compositeTask = CompositeHTTPClientTask(tasks: [])
        let enrichedRequest = enrichRequestWithToken(request, token)
        let firstTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                let result = self.isAuthenticated((data, response))
                switch result {
                case .authenticated:
                    completion(.success((data, response)))
                case .logout(let message):
                    self.handleUnauthenticated(message: message)
                    completion(.failure(ServiceError.internal))
                case .needsRefresh(let message):
                    if isRetryNeeded {
                        refreshToken(
                            message: message,
                            completion: { [weak self] tokens in
                                if let accessToken = tokens?.accessToken, !accessToken.isEmpty {
                                    self?.retryRequest(request, completion: completion, compositeTask: compositeTask)
                                }
                            }, compositeTask: compositeTask)
                    } else {
                        self.handleUnauthenticated(message: message)
                        completion(.failure(ServiceError.internal))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(firstTask)
        return compositeTask
    }
    
    public func refreshToken(
        message: String? = nil,
        completion: ((Tokens?) -> Void)?,
        compositeTask: CompositeHTTPClientTask
    ) {
        
        if let ongoingRefresh = synchronizedTokenAccess({ Self.ongoingRefresh }) {
            ongoingRefresh
                .handle(
                    onSuccess: { tokens in
                        completion?(tokens)
                    },
                    onError: { [weak self] _ in
                        self?.handleUnauthenticated(message: message)
                        completion?(nil)
                    }
                )
            return
        }
        
        var publisherToSubscribe: AnyPublisher<Tokens, ServiceError>?
        Self.tokenLock.sync {
            if Self.ongoingRefresh == nil {
                let refreshPublisher = Future<Tokens, ServiceError> { [weak self] promise in
                    self?.tokenRefresher.refresh { result in
                        promise(result)
                    }
                }
                    .flatMap { [weak self] tokens -> AnyPublisher<Tokens, ServiceError> in
                        guard let self else {
                            return Just(tokens).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
                        }
                        if let refreshToken = tokens.refreshToken, !refreshToken.isEmpty {
                            return Publishers.Zip(
                                accessTokenStorage.set(model: tokens.accessToken),
                                refreshTokenStorage.set(model: tokens.refreshToken)
                            )
                            .map { _ in tokens }
                            .setFailureType(to: ServiceError.self)
                            .eraseToAnyPublisher()
                        } else {
                            return accessTokenStorage.set(model: tokens.accessToken)
                                .map { _ in tokens }
                                .setFailureType(to: ServiceError.self)
                                .eraseToAnyPublisher()
                        }
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
                onSuccess: { [weak self] tokens in
                    if tokens.accessToken.isEmpty {
                        self?.handleUnauthenticated(message: message)
                        completion?(nil)
                    } else {
                        completion?(tokens)
                    }
                },
                onError: { [weak self] _ in
                    self?.handleUnauthenticated(message: message)
                    completion?(nil)
                }
            )
    }
    
    private func retryRequest(
        _ request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void,
        compositeTask: CompositeHTTPClientTask
    ) {
        guard let token = synchronizedTokenAccess({ accessTokenStorage.get() }), !token.isEmpty else { // Add sync and empty check
            handleUnauthenticated(message: nil)
            completion(.failure(ServiceError.internal))
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
                    self.handleUnauthenticated(message: message)
                    completion(.failure(ServiceError.internal))
                }
            case .failure(let error):
                self.handleUnauthenticated(message: nil)
                completion(.failure(error))
            }
        }
        compositeTask.add(newTask)
        newTask.resume()
    }
    
    private func handleUnauthenticated(message: String?) {
        Self.tokenLock.sync {
            guard !Self.hasHandledUnauthenticated else { return }
            Self.hasHandledUnauthenticated = true
            
            accessTokenStorage.clear()
            refreshTokenStorage.clear()
            onNotAuthenticated?(message)
        }
    }
    
    @discardableResult
    private func synchronizedTokenAccess<T>(_ block: () -> T) -> T {
        return Self.tokenLock.sync {
            return block()
        }
    }
}
