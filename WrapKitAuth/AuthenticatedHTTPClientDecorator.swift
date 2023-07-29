//
//  AuthenticatedHTTPClientDecorator.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public typealias EnrichRequestWithToken = ((URLRequest, String) -> URLRequest)
    public typealias AuthenticationPolicy = (((Data, HTTPURLResponse)) -> Bool)
    
    public struct NotAuthenticated: Error {
        public init() {}
    }
    
    private let decoratee: HTTPClient
    private let tokenService: TokenService
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let queue = DispatchQueue(label: "AuthenticatedHTTPClientDecorator", attributes: .concurrent)
    
    public init(
        decoratee: HTTPClient,
        tokenService: TokenService,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy
    ) {
        self.decoratee = decoratee
        self.tokenService = tokenService
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var enrichedRequest = request
        tokenService.getAccessToken { [weak self] accessToken in
            if let accessToken = accessToken, let enrichRequestWithToken = self?.enrichRequestWithToken {
                enrichedRequest = enrichRequestWithToken(request, accessToken)
            }
            self?.semaphore.signal()
        }
        semaphore.wait()
        return dispatch(enrichedRequest, completion: completion, isRefreshNeeded: true)
    }
    
    private func dispatch(_ enrichedRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void, isRefreshNeeded: Bool) -> HTTPClientTask {
        var task: HTTPClientTask?
        task = decoratee.dispatch(enrichedRequest, completion: { [weak self, completion, isRefreshNeeded] result in
            switch result {
            case .success(let response) where !(self?.isAuthenticated(response) ?? false):
                guard let refreshToken = self?.tokenService.storage.getRefreshToken(), let refresh = self?.tokenService.refresh, isRefreshNeeded else {
                    completion(.failure(NotAuthenticated()))
                    return
                }
                refresh(.init(refreshToken: refreshToken)) { [completion] response in
                    guard let accessToken = response?.accessToken, let enrichRequestWithToken = self?.enrichRequestWithToken else  {
                        completion(.failure(NotAuthenticated()))
                        return
                    }
                    self?.tokenService.storage.set(accessToken: accessToken)
                    task = self?.dispatch(enrichRequestWithToken(enrichedRequest, accessToken), completion: completion, isRefreshNeeded: false)
                }
            default:
                completion(result)
            }
        })
        return task!
    }
}
