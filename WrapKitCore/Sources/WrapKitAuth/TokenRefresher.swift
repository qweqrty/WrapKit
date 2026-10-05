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
    func refreshTask(completion: @escaping (Result<Tokens, ServiceError>) -> Void) -> HTTPClientTask
}

public extension TokenRefresher {
    func refreshTask(completion: @escaping (Result<Tokens, ServiceError>) -> Void) -> HTTPClientTask {
        let result = AuthenticationCompletion(completion)
        refresh { result.finish($0) }
        return AuthenticationCancellation { result.finish(.failure(.cancelled)) }
    }
}

public class TokenRefresherImpl<RefreshRequest, RefreshResponse>: TokenRefresher {
    private let refreshTokenStorage: any Storage<String>
    private let refreshService: any Service<RefreshRequest, RefreshResponse>
    private let mapRefreshRequest: (String) -> RefreshRequest
    private let mapResponseToAccess: ((RefreshResponse) -> String)?
    private let mapResponseToRefresh: ((RefreshResponse) -> String?)?
    
    private let authenticationLock = NSLock()
    private var flights: [String: (
        id: UUID,
        completions: [(UUID, (Result<Tokens, ServiceError>) -> Void)],
        subscription: AnyCancellable?
    )] = [:]
    
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
        _ = refreshTask(completion: completion)
    }

    public func refreshTask(completion: @escaping (Result<Tokens, ServiceError>) -> Void) -> HTTPClientTask {
        guard let refreshToken = refreshTokenStorage.get(), !refreshToken.isEmpty else {
            completion(.failure(.internal))
            return CompositeHTTPClientTask()
        }

        let waiterID = UUID()
        authenticationLock.lock()
        let existing = flights[refreshToken]
        let flightID = existing?.id ?? UUID()
        if existing == nil { flights[refreshToken] = (flightID, [], nil) }
        flights[refreshToken]?.completions.append((waiterID, completion))
        authenticationLock.unlock()

        let task = AuthenticationCancellation { [weak self] in
            self?.cancel(waiterID, in: flightID, token: refreshToken)
        }
        guard existing == nil else { return task }

        let subscription = refreshService.make(request: mapRefreshRequest(refreshToken))
            .prefix(1)
            .sink(receiveCompletion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .finished:
                    self.completeAll(with: .failure(.internal), flightID: flightID, token: refreshToken)
                case .failure(let error):
                    self.completeAll(with: .failure(error), flightID: flightID, token: refreshToken)
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                self.authenticationLock.lock()
                let isCurrent = self.flights[refreshToken]?.id == flightID
                self.authenticationLock.unlock()
                guard isCurrent else { return }
                guard let access = self.mapResponseToAccess?(response), !access.isEmpty else {
                    self.completeAll(with: .failure(.internal), flightID: flightID, token: refreshToken)
                    return
                }
                let tokens = Tokens(accessToken: access, refreshToken: self.mapResponseToRefresh?(response))
                self.completeAll(with: .success(tokens), flightID: flightID, token: refreshToken)
            })
        authenticationLock.lock()
        let isCurrent = flights[refreshToken]?.id == flightID
        if isCurrent { flights[refreshToken]?.subscription = subscription }
        authenticationLock.unlock()
        if !isCurrent { subscription.cancel() }
        return task
    }

    private func cancel(_ waiterID: UUID, in flightID: UUID, token: String) {
        authenticationLock.lock()
        guard flights[token]?.id == flightID else { authenticationLock.unlock(); return }
        let completion = flights[token]?.completions.first { $0.0 == waiterID }?.1
        flights[token]?.completions.removeAll { $0.0 == waiterID }
        let subscription: AnyCancellable?
        if flights[token]?.completions.isEmpty == true {
            subscription = flights[token]?.subscription
            flights[token] = nil
        } else {
            subscription = nil
        }
        authenticationLock.unlock()
        subscription?.cancel()
        completion?(.failure(.cancelled))
    }

    private func completeAll(with result: Result<Tokens, ServiceError>, flightID: UUID, token: String) {
        authenticationLock.lock()
        guard let flight = flights[token], flight.id == flightID else { authenticationLock.unlock(); return }
        flights[token] = nil
        let completions = flight.completions
        let subscription = flight.subscription
        authenticationLock.unlock()
        subscription?.cancel()
        completions.forEach { $0.1(result) }
    }
}
