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
    
    private var cancellables = Set<AnyCancellable>()
    
    private let decoratee: HTTPClient
    private let accessTokenStorage: any Storage<String>
    private var tokenRefresher: TokenRefresher?
    private let onNotAuthenticated: (() -> Void)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    
    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        tokenRefresher: TokenRefresher?,
        onNotAuthenticated: (() -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
        self.tokenRefresher = tokenRefresher
        self.onNotAuthenticated = onNotAuthenticated
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
    }

    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return dispatch(request, completion: completion, isRetryNeeded: true)
    }
    
    private func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void, isRetryNeeded: Bool) -> HTTPClientTask {
        let compositeTask = CompositeHTTPClientTask(tasks: [])
        let token = accessTokenStorage.get()
        let enrichedRequest = enrichRequestWithToken(request, token ?? "")
        let firstTask = decoratee.dispatch(enrichedRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (data, response)):
                if self.isAuthenticated((data, response)) {
                    completion(.success((data, response)))
                } else if isRetryNeeded, let tokenRefresher {
                    tokenRefresher.refresh { [weak self] refreshResult in
                        guard let self = self else { return }
                        switch refreshResult {
                        case .success(let newToken):
                            self.accessTokenStorage.set(model: newToken)
                                .sink { [weak self] _ in
                                    guard let self = self else { return }
                                    let newTask = self.dispatch(request, completion: completion, isRetryNeeded: false)
                                    compositeTask.add(newTask)
                                    newTask.resume()
                                }
                                .store(in: &self.cancellables)
                        case .failure:
                            _ = self.accessTokenStorage.set(model: nil)
                            self.onNotAuthenticated?()
                            completion(.failure(ServiceError.notAuthorized))
                        }
                    }
                } else {
                    _ = self.accessTokenStorage.set(model: nil)
                    self.onNotAuthenticated?()
                    completion(.success((data, response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        compositeTask.add(firstTask)
        return compositeTask
    }
}
