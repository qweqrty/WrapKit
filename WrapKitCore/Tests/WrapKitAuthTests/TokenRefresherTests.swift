//
//  TokenRefresherTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import Combine
import WrapKit
import XCTest
import XCTest
import Combine

final class TokenRefresherImplTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func test_refresh_deliversNewTokenOnSuccess() {
        let (sut, storage, service) = makeSUT()
        let refreshToken = "old_token"
        let newToken = "new_token"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2
        
        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                exp.fulfill()
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected new token to be returned")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                service.complete(with: .success(newToken), at: 0)
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
    
    func test_refresh_clearsTokenOnFailure() {
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
                        XCTAssertEqual(receivedError, error, "Expected `.connectivity` error")
                        XCTAssertNil(storage.get(), "Expected storage to clear the token on failure")
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
        let newToken = "new_token"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 2

        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected first refresh to return new token")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected queued refresh to return the same new token")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }

                service.complete(with: .success(newToken), at: 0)
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
        let newToken = "new_token"
        let exp = expectation(description: "Wait for refresh")
        exp.expectedFulfillmentCount = 3

        storage.set(model: refreshToken)
            .sink { isSuccess in
                XCTAssertTrue(isSuccess, "Expected storage to successfully set the token")
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected all concurrent refresh calls to return new token")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected all concurrent refresh calls to return new token")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }
                
                sut.refresh { result in
                    switch result {
                    case let .success(token):
                        XCTAssertEqual(token, newToken, "Expected all concurrent refresh calls to return new token")
                    case .failure:
                        XCTFail("Expected success, got failure")
                    }
                    exp.fulfill()
                }

                service.complete(with: .success(newToken), at: 0)
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenRefresher, storage: InMemoryStorage<String>, service: ServiceSpy<String, String>) {
        let storage = InMemoryStorage<String>()
        let service = ServiceSpy<String, String>()
        let mapRequest: (String) -> String = { token in "mapped_\(token)" }
        let mapResponse: (String) -> String = { data in "new_token" } // You can adjust this based on the actual mapping
        
        let sut = TokenRefresherImpl(
            refreshTokenStorage: storage,
            refreshService: service,
            mapRefreshRequest: mapRequest,
            mapRefreshResponse: mapResponse
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(storage, file: file, line: line)
        checkForMemoryLeaks(service, file: file, line: line)
        return (sut, storage, service)
    }
    
    class ServiceSpy<Request: Equatable, Response>: Service {
        private var publishers: [(request: Request, publisher: PassthroughSubject<Response, ServiceError>)] = []

        func make(request: Request) -> AnyPublisher<Response, ServiceError> {
            let publisher = PassthroughSubject<Response, ServiceError>()
            publishers.append((request, publisher))
            return publisher.eraseToAnyPublisher()
        }

        func complete(with result: Result<Response, ServiceError>, at index: Int) {
            switch result {
            case .success(let response):
                publishers.item(at: index)?.publisher.send(response)
                publishers.item(at: index)?.publisher.send(completion: .finished)
            case .failure(let error):
                publishers.item(at: index)?.publisher.send(completion: .failure(error))
            }
        }
    }

}
