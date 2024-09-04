//
//  TokenRefresherTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

class TokenRefresherImplTests: XCTestCase {
    
    func testSuccessfulTokenRefresh() {
        // Given
        let (sut, storage, service) = makeSUT()
        storage.set(model: "validRefreshToken")
        
        let exp = expectation(description: "Token refreshed successfully")
        
        // When
        sut.refresh { result in
            // Then
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "new_token")
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            exp.fulfill()
        }
        
        service.complete(with: .success("new_token"))
        wait(for: [exp], timeout: 1.0)
    }
    
    func testFailedTokenRefresh() {
        // Given
        let (sut, storage, service) = makeSUT()
        storage.set(model: "validRefreshToken")
        
        let exp = expectation(description: "Token refresh failed")
        
        // When
        sut.refresh { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(storage.get(), nil)
                XCTAssertEqual(error, .connectivity)
            }
            exp.fulfill()
        }
        
        service.complete(with: .failure(.connectivity))
        wait(for: [exp], timeout: 1.0)
    }
    
    func testNoRefreshTokenAvailable() {
        // Given
        let (sut, storage, _) = makeSUT()
        storage.set(model: nil)
        
        let exp = expectation(description: "Token refresh failed due to no refresh token")
        
        // When
        sut.refresh { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure due to no token, but got success")
            case .failure(let error):
                XCTAssertEqual(storage.get(), nil)
                XCTAssertEqual(error, .notAuthorized)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testHandlingMultipleConcurrentRequests() {
        // Given
        let (sut, storage, service) = makeSUT()
        storage.set(model: "validRefreshToken")
        
        let exp1 = expectation(description: "First request completed")
        let exp2 = expectation(description: "Second request completed")
        
        // When
        sut.refresh { result in
            // Then
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "new_token")
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            exp1.fulfill()
        }
        
        sut.refresh { result in
            // Then
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "new_token")
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            exp2.fulfill()
        }
        
        service.complete(with: .success("new_token"))
        wait(for: [exp1, exp2], timeout: 1.0)
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
    
    class ServiceSpy<Request, Response>: Service {
        private var completions: [(Result<Response, ServiceError>) -> Void] = []
        
        func make(request: Request, completion: @escaping (Result<Response, ServiceError>) -> Void) -> HTTPClientTask? {
            completions.append(completion)
            return DummyHTTPClientTask()
        }
        
        func complete(with result: Result<Response, ServiceError>, at index: Int = 0) {
            completions[index](result)
        }
    }
    
    struct DummyHTTPClientTask: HTTPClientTask {
        func cancel() {}
        func resume() {}
    }
}
