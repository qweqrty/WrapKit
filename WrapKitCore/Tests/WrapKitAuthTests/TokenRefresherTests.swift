//
//  TokenRefresherTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import Combine
import WrapKit
import XCTest
import WrapKitTestUtils

final class TokenRefresherImplTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_refresh_withEmptyRefreshToken_doesNotCallService() {
        let (sut, storage, service) = makeSUT()
        storage.set(model: "")
        var received: ServiceError?

        sut.refresh { if case .failure(let error) = $0 { received = error } }

        XCTAssertEqual(received, .internal)
        XCTAssertEqual(service.makeCallCount, 0)
    }

    func test_cancelLastWaiter_allowsFreshRequestWithSameTokenAndIgnoresOldResult() {
        let (sut, storage, service) = makeSUT()
        storage.set(model: "same_refresh")
        var firstResults: [Result<Tokens, ServiceError>] = []
        var secondResults: [Result<Tokens, ServiceError>] = []
        let task = sut.refreshTask { firstResults.append($0) }

        task.cancel()
        sut.refresh { secondResults.append($0) }
        XCTAssertEqual(service.makeCallCount, 2)
        service.complete(with: .success("stale"), at: 0)
        XCTAssertTrue(secondResults.isEmpty)
        service.complete(with: .success("current"), at: 1)

        XCTAssertEqual(firstResults.count, 1)
        guard case .failure(.cancelled) = firstResults[0] else { return XCTFail("Expected cancelled waiter") }
        XCTAssertEqual(secondResults.count, 1)
        guard case .success = secondResults[0] else { return XCTFail("Expected current flight success") }
    }

    func test_completionCanStartNextRefreshBeforePreviousPublisherFinishes() {
        let (sut, storage, service) = makeSUT()
        storage.set(model: "refresh")
        var completions = 0
        sut.refresh { _ in
            completions += 1
            sut.refresh { _ in completions += 1 }
        }

        service.complete(with: .success("first"), at: 0)
        XCTAssertEqual(service.makeCallCount, 2)
        XCTAssertEqual(completions, 1)
        service.complete(with: .success("second"), at: 1)
        XCTAssertEqual(completions, 2)
    }

    func test_synchronousServiceOutput_completesOnceAndAllowsNextRefresh() {
        let storage = InMemoryStorage(model: "refresh")
        let sut = TokenRefresherImpl(
            refreshTokenStorage: storage, refreshService: ImmediateService(),
            mapRefreshRequest: { $0 }, mapResponseToAccess: { $0 }
        )
        var received: [Tokens] = []
        sut.refresh { if case .success(let tokens) = $0 { received.append(tokens) } }
        sut.refresh { if case .success(let tokens) = $0 { received.append(tokens) } }

        XCTAssertEqual(received.map(\.accessToken), ["new_access", "new_access"])
    }

    private struct ImmediateService: Service {
        func make(request: String) -> AnyPublisher<String, ServiceError> {
            Just("new_access").setFailureType(to: ServiceError.self).eraseToAnyPublisher()
        }
    }
    
    func test_refresh_deliversNewTokensOnSuccess_withoutRefreshMapper() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                exp.fulfill()
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected new access token to be returned")
                        XCTAssertNil(tokens.refreshToken, "Expected no refresh token without mapper")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .success("response"), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(storage.get(), refreshToken, "Expected refresh token storage unchanged without mapper")
    }
    
    func test_refresh_deliversNewTokensOnSuccess_withRefreshMapper() {
        let newRefresh = "new_refresh"
        let (sut, storage, service) = makeSUT(mapResponseToRefresh: { _ in newRefresh })
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                exp.fulfill()
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected new access token to be returned")
                        XCTAssertEqual(tokens.refreshToken, newRefresh, "Expected new refresh token to be returned")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .success("response"), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_failsWhenNoTokenAvailable() {
        let (sut, _, _) = makeSUT()
        let exp = expectation(description: "Wait for refresh")
        
        sut.refresh { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .internal, "Expected `.internal` error when no token is available")
            case .success:
                XCTFail("Expected failure, got success")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_deliversErrorOnFailure() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let error = ServiceError.connectivity
        let exp = expectation(description: "Wait for refresh")
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case .failure(let receivedError):
                        XCTAssertEqual(receivedError, error, "Expected error to be delivered")
                    case .success:
                        XCTFail("Expected failure, got success")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .failure(error), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_executesQueuedRequestsAfterSuccess() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected first refresh to return new access token")
                        XCTAssertNil(tokens.refreshToken)
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected queued refresh to return the same new access token")
                        XCTAssertNil(tokens.refreshToken)
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .success("response"), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_executesQueuedRequestsAfterFailure() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let error = ServiceError.connectivity
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case .success:
                        XCTFail("Expected failure, got success")
                    case .failure(let receivedError):
                        XCTAssertEqual(receivedError, error, "Expected first refresh to fail with connectivity error")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case .success:
                        XCTFail("Expected failure, got success")
                    case .failure(let receivedError):
                        XCTAssertEqual(receivedError, error, "Expected queued refresh to fail with connectivity error")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .failure(error), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_handlesConcurrentRequests() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 3
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected all concurrent refresh calls to return new access token")
                        XCTAssertNil(tokens.refreshToken)
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected all concurrent refresh calls to return new access token")
                        XCTAssertNil(tokens.refreshToken)
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(tokens):
                        XCTAssertEqual(tokens.accessToken, newAccess, "Expected all concurrent refresh calls to return new access token")
                        XCTAssertNil(tokens.refreshToken)
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .success("response"), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_handlesTrulyConcurrentRequestsFromMultipleQueues() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for concurrent refreshes")
        exp.expectedFulfillmentCount = 5
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                let queues = [
                    DispatchQueue(label: "queue1"),
                    DispatchQueue(label: "queue2"),
                    DispatchQueue(label: "queue3"),
                    DispatchQueue(label: "queue4"),
                    DispatchQueue(label: "queue5")
                ]
                
                let started = DispatchGroup()
                for queue in queues {
                    started.enter()
                    queue.async {
                        defer { started.leave() }
                        sut.refresh { result in
                            switch result {
                            case let .success(tokens):
                                XCTAssertEqual(tokens.accessToken, newAccess, "Expected concurrent refresh to return new access token")
                                XCTAssertNil(tokens.refreshToken)
                            case .failure:
                                XCTFail("Expected success, got failure")
                            }
                            exp.fulfill()
                        }
                    }
                }
                
                started.notify(queue: .main) {
                    XCTAssertEqual(service.makeCallCount, 1)
                    service.complete(with: .success("response"), at: 0)
                }
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_refresh_handlesTrulyConcurrentRequestsFromMultipleQueues_withRefreshMapper() {
        let newRefresh = "new_refresh"
        let (sut, storage, service) = makeSUT(mapResponseToRefresh: { _ in newRefresh })
        let refreshToken = "old_token"
        let newAccess = "new_access"
        let exp = expectation(description: "Wait for concurrent refreshes")
        exp.expectedFulfillmentCount = 5
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                let queues = [
                    DispatchQueue(label: "queue1"),
                    DispatchQueue(label: "queue2"),
                    DispatchQueue(label: "queue3"),
                    DispatchQueue(label: "queue4"),
                    DispatchQueue(label: "queue5")
                ]
                
                let started = DispatchGroup()
                for queue in queues {
                    started.enter()
                    queue.async {
                        defer { started.leave() }
                        sut.refresh { result in
                            switch result {
                            case let .success(tokens):
                                XCTAssertEqual(tokens.accessToken, newAccess, "Expected concurrent refresh to return new access token")
                                XCTAssertEqual(tokens.refreshToken, newRefresh, "Expected concurrent refresh to return new refresh token")
                            case .failure:
                                XCTFail("Expected success, got failure")
                            }
                            exp.fulfill()
                        }
                    }
                }
                
                started.notify(queue: .main) {
                    XCTAssertEqual(service.makeCallCount, 1)
                    service.complete(with: .success("response"), at: 0)
                }
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        mapResponseToRefresh: ((String) -> String?)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: TokenRefresher, storage: InMemoryStorage<String>, service: ServiceSpy<String, String>) {
        let storage = InMemoryStorage<String>()
        let service = ServiceSpy<String, String>()
        let mapRequest: (String) -> String = { token in "mapped_\(token)" }
        let mapResponseToAccess: (String) -> String = { _ in "new_access" }
        
        let sut = TokenRefresherImpl(
            refreshTokenStorage: storage,
            refreshService: service,
            mapRefreshRequest: mapRequest,
            mapResponseToAccess: mapResponseToAccess,
            mapResponseToRefresh: mapResponseToRefresh
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(storage, file: file, line: line)
        checkForMemoryLeaks(service, file: file, line: line)
        return (sut, storage, service)
    }
}
