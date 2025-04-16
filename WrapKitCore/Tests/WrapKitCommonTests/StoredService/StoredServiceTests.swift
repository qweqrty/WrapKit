//
//  StoredServiceTests.swift
//  WrapKit
//
//  Created by Stanislav Li on 8/4/25.
//

import Foundation
import XCTest
import WrapKit
import Combine

class ServiceCompositionTests: XCTestCase {
    // Tests for composed(primeStorage:) - StorageServiceComposition
    func test_primeStorage_returnsCachedValue_whenAvailable() {
        let exp = expectation(description: "Wait for response")
        let (storage, service) = makeSUT(serviceResult: .success(2))
        let expectedValue = 42
        storage.set(model: expectedValue)
        
        service.composed(primeStorage: storage).make(request: "")
            .handle(
                onSuccess: { response in
                    XCTAssertEqual(response, expectedValue)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_primeStorage_usesServiceAndCaches_whenCacheIsNil() {
        let exp = expectation(description: "Wait for response")
        let expectedValue = 99
        let (storage, service) = makeSUT(serviceResult: .success(expectedValue))
        
        XCTAssertNil(storage.get())
        service.composed(primeStorage: storage).make(request: "")
            .handle(
                onSuccess: { response in
                    XCTAssertEqual(response, expectedValue)
                    XCTAssertEqual(storage.get(), expectedValue)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_primeStorage_passesServiceError_whenNoCache() {
        let exp = expectation(description: "Wait for failure")
        let (storage, service) = makeSUT(serviceResult: .failure(.connectivity))
        
        service.composed(primeStorage: storage).make(request: "")
            .handle(
                onSuccess: { _ in
                    XCTFail("Expected failure, got value")
                },
                onError: { error in
                    XCTAssertEqual(error, .connectivity)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    // Tests for composed(secondaryStorage:) - ServiceStorageComposition
    func test_secondaryStorage_cachesServiceSuccess() {
        let exp = expectation(description: "Wait for response")
        let expectedValue = 77
        let (storage, service) = makeSUT(serviceResult: .success(expectedValue))
        
        service.composed(secondaryStorage: storage).make(request: "")
            .handle(
                onSuccess: { response in
                    XCTAssertEqual(response, expectedValue)
                    XCTAssertEqual(storage.get(), expectedValue)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_secondaryStorage_returnsCachedValue_whenServiceFailsWithConnectivity() {
        let exp = expectation(description: "Wait for response")
        let cachedValue = 33
        let (storage, service) = makeSUT(serviceResult: .failure(.connectivity))
        storage.set(model: cachedValue)
        
        service.composed(secondaryStorage: storage).make(request: "")
            .handle(
                onSuccess: { response in
                    XCTAssertEqual(response, cachedValue)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_secondaryStorage_passesNonConnectivityError_whenNoCache() {
        let exp = expectation(description: "Wait for failure")
        let (storage, service) = makeSUT(serviceResult: .failure(.internal))
        
        service.composed(secondaryStorage: storage).make(request: "")
            .handle(
                onSuccess: { _ in
                    XCTFail("Expected failure, got value")
                },
                onError: { error in
                    XCTAssertEqual(error, .internal)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_secondaryStorage_passesConnectivityError_whenNoCache() {
        let exp = expectation(description: "Wait for failure")
        let (storage, service) = makeSUT(serviceResult: .failure(.connectivity))
        
        service.composed(secondaryStorage: storage).make(request: "")
            .handle(
                onSuccess: { _ in
                    XCTFail("Expected failure, got value")
                },
                onError: { error in
                    XCTAssertEqual(error, .connectivity)
                    exp.fulfill()
                }
            )
        wait(for: [exp], timeout: 1.0)
    }
}

private extension ServiceCompositionTests {
    private func makeSUT(serviceResult: Result<Int, ServiceError>) -> (storage: any Storage<Int>, service: MockService<String, Int>) {
        let storage = InMemoryStorage<Int>()
        let service = MockService<String, Int>(result: serviceResult)
        return (storage, service)
    }
}
