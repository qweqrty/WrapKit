//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_dispatch_withAccessTokenAndAuthenticatedResponse_completesSuccessfully() {
        let (sut, storage, httpClientSpy, _) = makeSUT(isAuthenticated: { _ in true })

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8))

        XCTAssertEqual(httpClientSpy.requestedURLs, [URL(string: "http://test.com")!])
        switch receivedResult {
        case .success(let (data, response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_failsWithoutTokenAndNoTokenRefresher() {
        let (sut, storage, httpClientSpy, _) = makeSUT(tokenRefresher: nil)
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 0, "Expected no request to be dispatched without a token")
        switch receivedResult {
        case .failure(let error as ServiceError):
            XCTAssertEqual(error, .internal)
        default:
            XCTFail("Expected '.failure(.internal)', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_triggersOnNotAuthenticatedWithoutTokenRefresher() {
        var onNotAuthenticatedCalled = false
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: nil,
            isAuthenticated: { _ in false },
            onNotAuthenticated: { onNotAuthenticatedCalled = true }
        )
        
        storage.set(model: "valid_token")
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data())
        
        XCTAssertTrue(onNotAuthenticatedCalled, "Expected 'onNotAuthenticated' to be called")
        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_triggersTokenRefreshOnceForMultipleUnauthenticatedResponses() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in false }
        )
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        var receivedResult: HTTPClient.Result?
        sut.dispatch(request1) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        
        tokenRefresherSpy.complete(with: .failure(.internal))
        
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 1, "Expected token refresher to be called only once")
        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }


    func test_dispatch_cancelsAllRequestsWhenCompositeTaskIsCancelled() {
        let (sut, storage, httpClientSpy, _) = makeSUT()
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let task1 = sut.dispatch(request1) { _ in }
        let task2 = sut.dispatch(request2) { _ in }
        let compositeTask = CompositeHTTPClientTask(tasks: [task1, task2])
        
        compositeTask.cancel()
        
        XCTAssertEqual(httpClientSpy.cancelledURLs.count, 2, "Expected both requests to be cancelled")
        XCTAssertEqual(httpClientSpy.cancelledURLs, [URL(string: "http://test.com/1")!, URL(string: "http://test.com/2")!])
    }

    func test_dispatch_handlesDelayedResponseAfterTokenRefresh() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { response in response.1.statusCode != 401 }
        )
        
        storage.set(model: "valid_token")
        
        let request = URLRequest(url: URL(string: "http://test.com")!)
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(request) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        tokenRefresherSpy.complete(with: .success("new_token"))
        
        httpClientSpy.completes(withStatusCode: 200, data: Data("new_data".utf8), at: 1)
        
        switch receivedResult {
        case .success(let (data, _)):
            XCTAssertEqual(data, Data("new_data".utf8))
        default:
            XCTFail("Expected '.success' with new data, but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefresherSuccess_retriesRequest() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { (data, response) in
            return response.statusCode == 200
        })

        storage.set(model: "valid_token")
        var receivedResult: HTTPClient.Result?

        let exp = expectation(description: "Wait for completion")
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy?.complete(with: .success("new_token"))
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8), at: 1)
        
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(httpClientSpy.requestedURLs, [URL(string: "http://test.com")!, URL(string: "http://test.com")!])
        switch receivedResult {
        case .success(let (data, response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefresherFailure_completesWithNotAuthorized() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy?.complete(with: .failure(ServiceError.internal))

        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withAccessTokenAndTwoUnauthenticatedResponses_doesNotRetryTwice() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { response in response.1.statusCode != 401 })

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?

        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        
        tokenRefresherSpy?.complete(with: .success("new_token"))

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 1)

        XCTAssertEqual(httpClientSpy.requestedURLs.count, 2, "Expected only two attempts, one original and one retry")
        XCTAssertEqual(tokenRefresherSpy?.refreshCalledCount, 1, "Expected token refresher to be called only once")

        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }

    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefreshFailure_doesNotRetryAndReturnsError() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy?.complete(with: .failure(ServiceError.internal))
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 1, "Expected only one request attempt")
        
        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withAccessTokenAndSuccessfulRetryAfterTokenRefresh_completesSuccessfullyWithNewToken() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { response in response.1.statusCode != 401 })

        storage.set(model: "invalid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy?.complete(with: .success("new_token"))
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8))

        switch receivedResult {
        case .success((let data, let response)):
            XCTAssertEqual(data, Data("data1".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
            XCTAssertEqual(storage.get(), "new_token", "Expected the new token to be stored")
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withInitialSuccessDoesNotTriggerTokenRefresh() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in true })

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8))

        XCTAssertEqual(tokenRefresherSpy?.refreshCalledCount, 0, "Expected no token refresh attempt")
        switch receivedResult {
        case .success((let data, let response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_triggersOnNotAuthenticatedWhenTokenRefreshFails() {
        var onNotAuthenticatedCalled = false
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(
            tokenRefresher: TokenRefresherSpy(),
            isAuthenticated: { _ in false },
            onNotAuthenticated: { onNotAuthenticatedCalled = true }
        )

        storage.set(model: "valid_token")

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy?.complete(with: .failure(ServiceError.internal))

        XCTAssertTrue(onNotAuthenticatedCalled, "Expected 'onNotAuthenticated' to be called when token refresh fails")
        switch receivedResult {
        case .none:
            break
        default:
            XCTFail("Expected 'nil', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withTokenRefreshed_storesNewToken() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: "valid_token")
        
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { _ in }.resume()
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy?.complete(with: .success("new_token"))

        XCTAssertEqual(storage.get(), "new_token")
    }

    func test_concurrentRequests_useSameToken() {
        let (sut, storage, httpClientSpy, _) = makeSUT()
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        
        sut.dispatch(request1) { result in
            if case let .success(response) = result {
                XCTAssertEqual(response.response.url, URL(string: "http://test.com/1")!)
            }
            exp1.fulfill()
        }.resume()
        
        sut.dispatch(request2) { result in
            if case let .success(response) = result {
                XCTAssertEqual(response.response.url, URL(string: "http://test.com/2")!)
            }
            exp2.fulfill()
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 0)
        httpClientSpy.completes(withStatusCode: 200, data: Data("data2".utf8), at: 1)
        
        wait(for: [exp1, exp2], timeout: 2.0)
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 2)
        XCTAssertEqual(httpClientSpy.requestedURLRequests[0].value(forHTTPHeaderField: "Authorization"), "valid_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[1].value(forHTTPHeaderField: "Authorization"), "valid_token")
    }
    
    func test_concurrentRequestsAfterTokenRefresh_useNewToken() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { response in response.1.statusCode != 401 }
        )
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        
        sut.dispatch(request1) { result in
            if case let .success(response) = result {
                XCTAssertEqual(response.response.url, URL(string: "http://test.com/1")!)
            }
            exp1.fulfill()
        }.resume()
        
        sut.dispatch(request2) { result in
            if case let .success(response) = result {
                XCTAssertEqual(response.response.url, URL(string: "http://test.com/2")!)
            }
            exp2.fulfill()
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        tokenRefresherSpy.complete(with: .success("new_token"))
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 1)
        tokenRefresherSpy.complete(with: .success("new_token"))
        
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 2)
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 3)
        
        wait(for: [exp1, exp2], timeout: 2.0)
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 4)
        XCTAssertEqual(httpClientSpy.requestedURLRequests[2].value(forHTTPHeaderField: "Authorization"), "new_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[3].value(forHTTPHeaderField: "Authorization"), "new_token")
    }
    
    func test_noRaceConditionWhenMultipleRequestsUseSameToken() {
        let (sut, storage, httpClientSpy, _) = makeSUT()
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        let request3 = URLRequest(url: URL(string: "http://test.com/3")!)
        
        let dispatchExp = expectation(description: "Wait for all requests to be dispatched")
        dispatchExp.expectedFulfillmentCount = 3 // Ensure all three requests are appended to `messages`
        
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        let exp3 = expectation(description: "Wait for request 3")
        
        DispatchQueue.global().async {
            sut.dispatch(request1) { result in
                if case let .success(response) = result {
                    XCTAssertEqual(response.response.url, URL(string: "http://test.com/1")!)
                }
                exp1.fulfill()
            }.resume()
            dispatchExp.fulfill()
        }
        
        DispatchQueue.global().async {
            sut.dispatch(request2) { result in
                if case let .success(response) = result {
                    XCTAssertEqual(response.response.url, URL(string: "http://test.com/2")!)
                }
                exp2.fulfill()
            }.resume()
            dispatchExp.fulfill()
        }
        
        DispatchQueue.global().async {
            sut.dispatch(request3) { result in
                if case let .success(response) = result {
                    XCTAssertEqual(response.response.url, URL(string: "http://test.com/3")!)
                }
                exp3.fulfill()
            }.resume()
            dispatchExp.fulfill()
        }
        
        // Wait until all requests are dispatched
        wait(for: [dispatchExp], timeout: 1.0)
        
        // Now complete the requests after ensuring they exist in `httpClientSpy.messages`
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 0)
        httpClientSpy.completes(withStatusCode: 200, data: Data("data2".utf8), at: 1)
        httpClientSpy.completes(withStatusCode: 200, data: Data("data3".utf8), at: 2)
        
        // Wait for all requests to complete
        wait(for: [exp1, exp2, exp3], timeout: 2.0)
        
        // Assertions
        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 3)
        XCTAssertEqual(httpClientSpy.requestedURLRequests[0].value(forHTTPHeaderField: "Authorization"), "valid_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[1].value(forHTTPHeaderField: "Authorization"), "valid_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[2].value(forHTTPHeaderField: "Authorization"), "valid_token")
    }

    
    // MARK: - Helpers

    private func makeSUT(
        tokenRefresher: TokenRefresherSpy? = TokenRefresherSpy(),
        isAuthenticated: @escaping AuthenticatedHTTPClientDecorator.AuthenticationPolicy = { _ in true },
        onNotAuthenticated: (() -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthenticatedHTTPClientDecorator,
        storage: InMemoryStorage<String>,
        httpClientSpy: HTTPClientSpy,
        tokenRefresherSpy: TokenRefresherSpy?
    ) {
        let httpClientSpy = HTTPClientSpy()
        let storage = InMemoryStorage<String>()
        
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: httpClientSpy,
            accessTokenStorage: storage,
            tokenRefresher: tokenRefresher,
            onNotAuthenticated: onNotAuthenticated,
            enrichRequestWithToken: { request, token in
                var req = request
                req.setValue(token, forHTTPHeaderField: "Authorization")
                return req
            },
            isAuthenticated: isAuthenticated
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(storage, file: file, line: line)
        checkForMemoryLeaks(httpClientSpy, file: file, line: line)
        if let tokenRefresher = tokenRefresher {
            checkForMemoryLeaks(tokenRefresher, file: file, line: line)
        }
        return (sut, storage, httpClientSpy, tokenRefresher)
    }

    class TokenRefresherSpy: TokenRefresher {
        var completion: ((Result<String, ServiceError>) -> Void)?
        var refreshCalledCount: Int = 0

        func refresh(completion: @escaping (Result<String, ServiceError>) -> Void) {
            self.completion = completion
            refreshCalledCount += 1
        }

        func complete(with result: Result<String, ServiceError>) {
            completion?(result)
        }
    }
}

