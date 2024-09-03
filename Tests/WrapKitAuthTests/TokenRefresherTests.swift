//
//  TokenRefresherTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

//class TokenRefresherImplTests: XCTestCase {
//
//    func test_refresh_whenTokenIsMissing_completesWithNotAuthorizedError() {
//        let (sut, storage, _) = makeSUT()
//
//        storage.set(model: nil, completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        var receivedError: ServiceError?
//        sut.refresh { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//            exp.fulfill()
//        }
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedError, .notAuthorized)
//    }
//
//    func test_refresh_whenTokenIsPresent_andServiceSucceeds_completesWithNewToken() {
//        let (sut, storage, service) = makeSUT()
//
//        storage.set(model: "old_token", completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        var receivedToken: String?
//        sut.refresh { result in
//            if case let .success(token) = result {
//                receivedToken = token
//            }
//            exp.fulfill()
//        }
//
//        service.complete(with: .success("mapped_data"))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedToken, "new_token")
//    }
//
//    func test_refresh_whenTokenIsPresent_andServiceFails_completesWithError() {
//        let (sut, storage, service) = makeSUT()
//
//        storage.set(model: "old_token", completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        var receivedError: ServiceError?
//        sut.refresh { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//            exp.fulfill()
//        }
//
//        service.complete(with: .failure(.internal))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedError, .internal)
//    }
//    
//    func test_refresh_multipleCalls_whenTokenIsMissing_allCompleteWithNotAuthorizedError() {
//        let (sut, storage, _) = makeSUT()
//
//        storage.set(model: nil, completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        exp.expectedFulfillmentCount = 2
//
//        var receivedError1: ServiceError?
//        var receivedError2: ServiceError?
//        
//        sut.refresh { result in
//            if case let .failure(error) = result {
//                receivedError1 = error
//            }
//            exp.fulfill()
//        }
//        
//        sut.refresh { result in
//            if case let .failure(error) = result {
//                receivedError2 = error
//            }
//            exp.fulfill()
//        }
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedError1, .notAuthorized)
//        XCTAssertEqual(receivedError2, .notAuthorized)
//    }
//    
//    func test_refresh_multipleCalls_whenTokenIsPresent_allCompleteWithNewToken() {
//        let (sut, storage, service) = makeSUT()
//
//        storage.set(model: "old_token", completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        exp.expectedFulfillmentCount = 2
//
//        var receivedToken1: String?
//        var receivedToken2: String?
//        
//        sut.refresh { result in
//            if case let .success(token) = result {
//                receivedToken1 = token
//            }
//            exp.fulfill()
//        }
//        
//        sut.refresh { result in
//            if case let .success(token) = result {
//                receivedToken2 = token
//            }
//            exp.fulfill()
//        }
//
//        service.complete(with: .success("mapped_data"))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedToken1, "new_token")
//        XCTAssertEqual(receivedToken2, "new_token")
//    }
//
//    func test_refresh_whenTokenIsPresent_andServiceFailsWithConnectivity_completesWithError() {
//        let (sut, storage, service) = makeSUT()
//
//        storage.set(model: "old_token", completion: nil)
//
//        let exp = expectation(description: "Wait for completion")
//        var receivedError: ServiceError?
//        
//        sut.refresh { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//            exp.fulfill()
//        }
//
//        service.complete(with: .failure(.connectivity))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(receivedError, .connectivity)
//    }
//    
//    func test_refresh_orderOfExecution() {
//        let (sut, storage, service) = makeSUT()
//        
//        storage.set(model: "old_token", completion: nil)
//        
//        let exp1 = expectation(description: "Wait for first refresh completion")
//        let exp2 = expectation(description: "Wait for second refresh completion")
//        let exp3 = expectation(description: "Wait for third refresh completion")
//        
//        var orderOfCompletion: [Int] = []
//        
//        sut.refresh { result in
//            orderOfCompletion.append(1)
//            exp1.fulfill()
//        }
//
//        sut.refresh { result in
//            orderOfCompletion.append(2)
//            exp2.fulfill()
//        }
//        
//        sut.refresh { result in
//            orderOfCompletion.append(3)
//            exp3.fulfill()
//        }
//        
//        service.complete(with: .success("mapped_data_1"))
//
//        wait(for: [exp1, exp2, exp3], timeout: 1.0)
//        
//        XCTAssertEqual(orderOfCompletion, [1, 2, 3])
//    }
//
//    func test_memoryLeak_forTokenRefresherImpl() {
//        let storage = InMemoryStorage<String>()
//        let service = ServiceSpy<String, String>()
//        let mapRequest: (String) -> String = { token in "mapped_\(token)" }
//        let mapResponse: (String) -> String = { data in "new_token" } // You can adjust this based on the actual mapping
//        
//        var sut: TokenRefresherImpl? = TokenRefresherImpl(
//            refreshTokenStorage: storage,
//            refreshService: service,
//            mapRefreshRequest: mapRequest,
//            mapRefreshResponse: mapResponse
//        )
//        weak var weakSUT: TokenRefresherImpl<String, String>? = sut
//
//        sut = nil
//
//        XCTAssertNil(weakSUT)
//    }
//    
//    // MARK: - Helpers
//    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenRefresherImpl<String, String>, storage: InMemoryStorage<String>, service: ServiceSpy<String, String>) {
//        let storage = InMemoryStorage<String>()
//        let service = ServiceSpy<String, String>()
//        let mapRequest: (String) -> String = { token in "mapped_\(token)" }
//        let mapResponse: (String) -> String = { data in "new_token" } // You can adjust this based on the actual mapping
//        
//        let sut = TokenRefresherImpl(
//            refreshTokenStorage: storage,
//            refreshService: service,
//            mapRefreshRequest: mapRequest,
//            mapRefreshResponse: mapResponse
//        )
//        checkForMemoryLeaks(sut, file: file, line: line)
//        return (sut, storage, service)
//    }
//    
//    class ServiceSpy<Request, Response>: Service {
//        private var completions: [(Result<Response, ServiceError>) -> Void] = []
//        
//        func make(request: Request, completion: @escaping (Result<Response, ServiceError>) -> Void) -> HTTPClientTask? {
//            completions.append(completion)
//            return DummyHTTPClientTask()
//        }
//        
//        func complete(with result: Result<Response, ServiceError>, at index: Int = 0) {
//            completions[index](result)
//        }
//    }
//    
//    struct DummyHTTPClientTask: HTTPClientTask {
//        func cancel() {}
//        func resume() {}
//    }
//}
