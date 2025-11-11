//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit
import Combine

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_dispatch_withAccessTokenAndAuthenticatedResponse_completesSuccessfully() {
        let (sut, storage, httpClientSpy, _) = makeSUT(isAuthenticated: { _ in .authenticated })
        
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
    
    func test_dispatch_failsWithoutToken() {
        var onNotAuthenticatedCalled = 0
        let (sut, _, httpClientSpy, _) = makeSUT(onNotAuthenticated: { _ in
            onNotAuthenticatedCalled = onNotAuthenticatedCalled + 1
        })
        var receivedResult: HTTPClient.Result?
        
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 0, "Expected no request to be dispatched without a token")
        switch receivedResult {
        case .failure(let error):
            XCTAssertEqual(error as? ServiceError, ServiceError.internal)
        default:
            XCTFail("Expected failure, but got \(String(describing: receivedResult))")
        }
        XCTAssertEqual(onNotAuthenticatedCalled, 1)
    }
    
    func test_dispatch_triggersOnNotAuthenticatedOnNeedsRefreshAndRefreshFailure() {
        var onNotAuthenticatedCalled = 0
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(
            isAuthenticated: { _ in .needsRefresh(onErrorMessage: nil) },
            onNotAuthenticated: { _ in onNotAuthenticatedCalled = onNotAuthenticatedCalled + 1 }
        )
        
        storage.set(model: "valid_token")
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data())
        tokenRefresherSpy.complete(with: .failure(.internal))
        
        XCTAssertEqual(onNotAuthenticatedCalled, 1)
        XCTAssertNil(receivedResult, "Expected no result fired to client, but got \(String(describing: receivedResult))")
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 1, "Expected token refresher to be called only once")
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 1, "Expected only one request attempt")
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
            isAuthenticated: { response in response.1.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "valid_token")
        
        let request = URLRequest(url: URL(string: "http://test.com")!)
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(request) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        
        httpClientSpy.completes(withStatusCode: 200, data: Data("new_data".utf8), at: 1)
        
        switch receivedResult {
        case .success(let (data, _)):
            XCTAssertEqual(data, Data("new_data".utf8))
        default:
            XCTFail("Expected '.success' with new data, but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefresherSuccess_retriesRequest() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { (data, response) in
                return response.statusCode == 200 ? .authenticated : .needsRefresh(onErrorMessage: nil)
            }
        )
        
        storage.set(model: "valid_token")
        var receivedResult: HTTPClient.Result?
        
        let exp = expectation(description: "Wait for completion")
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
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
    
    func test_dispatch_withAccessTokenAndTwoUnauthenticatedResponses_doesNotRetryTwice() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { response in response.1.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "valid_token")
        
        var receivedResult: HTTPClient.Result?
        
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 1)
        
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 2, "Expected only two attempts, one original and one retry")
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 1, "Expected token refresher to be called only once")
        
        switch receivedResult {
        case .failure(let error):
            XCTAssertEqual(error as? ServiceError, ServiceError.internal)
        default:
            XCTFail("Expected failure, but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndSuccessfulRetryAfterTokenRefresh_completesSuccessfullyWithNewToken() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { response in response.1.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "invalid_token")
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
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
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .authenticated }
        )
        
        storage.set(model: "valid_token")
        
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8))
        
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 0, "Expected no token refresh attempt")
        switch receivedResult {
        case .success((let data, let response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withTokenRefreshed_storesNewToken() {
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "valid_token")
        
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { _ in }.resume()
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        
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
            if case let .success((_, response)) = result {
                XCTAssertEqual(response.url, URL(string: "http://test.com/1")!)
            }
            exp1.fulfill()
        }.resume()
        
        sut.dispatch(request2) { result in
            if case let .success((_, response)) = result {
                XCTAssertEqual(response.url, URL(string: "http://test.com/2")!)
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
            isAuthenticated: { _, response in response.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        
        sut.dispatch(request1) { result in
            if case .success = result {
            }
            exp1.fulfill()
        }.resume()
        
        sut.dispatch(request2) { result in
            if case .success = result {
            }
            exp2.fulfill()
        }.resume()
        
        // Complete both originals as 401 *before* refresh
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 1)
        
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 1, "Expected single refresh")
        
        // Single refresh completion
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        
        // Complete both retries
        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 2)
        httpClientSpy.completes(withStatusCode: 200, data: Data("data2".utf8), at: 3)
        
        wait(for: [exp1, exp2], timeout: 2.0)
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 4)
        XCTAssertEqual(httpClientSpy.requestedURLRequests[2].value(forHTTPHeaderField: "Authorization"), "new_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[3].value(forHTTPHeaderField: "Authorization"), "new_token") // Same token!
    }
    
    func test_dispatch_refreshSucceedsWithNonEmptyAccessToken_retriesRequest() {
        let refreshStorage = InMemoryStorage<String>()
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, accessStorage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            refreshStorage: refreshStorage,
            isAuthenticated: { (_, response) in
                response.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: "needs refresh")
            }
        )
        accessStorage.set(model: "valid_token")
        refreshStorage.set(model: "refresh_token")
        var receivedResult: HTTPClient.Result?
        let exp = expectation(description: "Wait for completion")
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }.resume()
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        httpClientSpy.completes(withStatusCode: 200, data: Data("success_data".utf8), at: 1)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 2)
        XCTAssertEqual(accessStorage.get(), "new_token")
        XCTAssertEqual(refreshStorage.get(), "refresh_token") // Remains unchanged since no new refresh token provided
        switch receivedResult {
        case .success(let (data, _)):
            XCTAssertEqual(data, Data("success_data".utf8))
        default:
            XCTFail("Expected success, got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_refreshSucceedsWithEmptyAccessToken_doesNotRetryAndTriggersLogout() {
        let refreshStorage = InMemoryStorage<String>()
        var notAuthenticatedCalled = 0
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, accessStorage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            refreshStorage: refreshStorage,
            isAuthenticated: { (_, response) in
                response.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: "needs refresh")
            },
            onNotAuthenticated: { _ in
                notAuthenticatedCalled = notAuthenticatedCalled + 1
            }
        )
        accessStorage.set(model: "valid_token")
        refreshStorage.set(model: "refresh_token")
        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "")))
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 1)
        XCTAssertEqual(accessStorage.get(), nil)
        XCTAssertEqual(refreshStorage.get(), nil)
        XCTAssertNil(receivedResult)
        XCTAssertEqual(notAuthenticatedCalled, 1)
    }
    
    func test_refreshToken_refreshSucceeds_returnsTokens() {
        let refreshStorage = InMemoryStorage<String>()
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, accessStorage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            refreshStorage: refreshStorage
        )
        let exp = expectation(description: "Wait for completion")
        var receivedTokens: Tokens?
        sut.refreshToken(completion: { tokens in
            receivedTokens = tokens
            exp.fulfill()
        }, compositeTask: CompositeHTTPClientTask())
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedTokens?.accessToken, "new_token")
    }
    
    func test_refreshToken_refreshSucceedsWithEmptyAccessToken_returnsNil() {
        let refreshStorage = InMemoryStorage<String>()
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, accessStorage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            refreshStorage: refreshStorage
        )
        let exp = expectation(description: "Wait for completion")
        var receivedTokens: Tokens?
        sut.refreshToken(completion: { tokens in
            receivedTokens = tokens
            exp.fulfill()
        }, compositeTask: CompositeHTTPClientTask())
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "")))
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedTokens)
    }
    
    func test_refreshToken_refreshFails_returnsNil() {
        let refreshStorage = InMemoryStorage<String>()
        let tokenRefresherSpy = TokenRefresherSpy()
        let (sut, accessStorage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            refreshStorage: refreshStorage
        )
        let exp = expectation(description: "Wait for completion")
        var receivedTokens: Tokens?
        sut.refreshToken(completion: { tokens in
            receivedTokens = tokens
            exp.fulfill()
        }, compositeTask: CompositeHTTPClientTask())
        tokenRefresherSpy.complete(with: .failure(ServiceError.internal))
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedTokens)
    }
    
//    func test_noRaceConditionWhenMultipleRequestsUseSameToken() {
//        let (sut, storage, httpClientSpy, _) = makeSUT()
//        
//        storage.set(model: "valid_token")
//        
//        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
//        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
//        let request3 = URLRequest(url: URL(string: "http://test.com/3")!)
//        
//        let dispatchExp = expectation(description: "Wait for all requests to be dispatched")
//        dispatchExp.expectedFulfillmentCount = 3
//        
//        let exp1 = expectation(description: "Wait for request 1")
//        let exp2 = expectation(description: "Wait for request 2")
//        let exp3 = expectation(description: "Wait for request 3")
//        
//        DispatchQueue.global().async {
//            sut.dispatch(request1) { result in
//                if case .success = result {
//                }
//                exp1.fulfill()
//            }.resume()
//            dispatchExp.fulfill()
//        }
//        
//        DispatchQueue.global().async {
//            sut.dispatch(request2) { result in
//                if case .success = result {
//                }
//                exp2.fulfill()
//            }.resume()
//            dispatchExp.fulfill()
//        }
//        
//        DispatchQueue.global().async {
//            sut.dispatch(request3) { result in
//                if case .success = result {
//                }
//                exp3.fulfill()
//            }.resume()
//            dispatchExp.fulfill()
//        }
//        
//        // Wait until all requests are dispatched
//        wait(for: [dispatchExp], timeout: 2.0)
//        
//        // Now complete the requests after ensuring they exist in `httpClientSpy.messages`
//        httpClientSpy.completes(withStatusCode: 200, data: Data("data1".utf8), at: 0)
//        httpClientSpy.completes(withStatusCode: 200, data: Data("data2".utf8), at: 1)
//        httpClientSpy.completes(withStatusCode: 200, data: Data("data3".utf8), at: 2)
//        
//        // Wait for all requests to complete
//        wait(for: [exp1, exp2, exp3], timeout: 2.0)
//        
//        // Assertions
//        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 3)
//        XCTAssertEqual(httpClientSpy.requestedURLRequests[0].value(forHTTPHeaderField: "Authorization"), "valid_token")
//        XCTAssertEqual(httpClientSpy.requestedURLRequests[1].value(forHTTPHeaderField: "Authorization"), "valid_token")
//        XCTAssertEqual(httpClientSpy.requestedURLRequests[2].value(forHTTPHeaderField: "Authorization"), "valid_token")
//    }
    
    func test_multipleClients_concurrentUnauthenticatedRequests_triggerSingleTokenRefreshAndRetryWithNewToken() {
        // Arrange
        let tokenRefresherSpy = TokenRefresherSpy()
        let storage = InMemoryStorage<String>()
        let refreshStorage = InMemoryStorage<String>()
        let httpClientSpy = HTTPClientSpy()
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        
        let client1 = AuthenticatedHTTPClientDecorator(
            decoratee: httpClientSpy,
            accessTokenStorage: storage,
            refreshTokenStorage: refreshStorage,
            tokenRefresher: tokenRefresherSpy,
            onNotAuthenticated: nil,
            enrichRequestWithToken: { request, token in
                var req = request
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return req
            },
            isAuthenticated: { _, response in response.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        let client2 = AuthenticatedHTTPClientDecorator(
            decoratee: httpClientSpy,
            accessTokenStorage: storage,
            refreshTokenStorage: refreshStorage,
            tokenRefresher: tokenRefresherSpy,
            onNotAuthenticated: nil,
            enrichRequestWithToken: { request, token in
                var req = request
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return req
            },
            isAuthenticated: { _, response in response.statusCode != 401 ? .authenticated : .needsRefresh(onErrorMessage: nil) }
        )
        
        storage.set(model: "initial_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        client1.dispatch(request1) { result in
            if case .success = result {
            }
            exp1.fulfill()
        }.resume()
        
        client2.dispatch(request2) { result in
            if case .success = result {
            }
            exp2.fulfill()
        }.resume()
        
        XCTAssertEqual(httpClientSpy.requestedURLs.count, 2, "Expected two initial requests")
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
        httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 1)
        XCTAssertEqual(tokenRefresherSpy.refreshCalledCount, 1)
        tokenRefresherSpy.complete(with: .success(Tokens(accessToken: "new_token")))
        httpClientSpy.completes(withStatusCode: 200, data: Data(), at: 2)
        httpClientSpy.completes(withStatusCode: 200, data: Data(), at: 3)
        
        // Wait for all requests to complete
        wait(for: [exp1, exp2], timeout: 2.0)
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests[2].value(forHTTPHeaderField: "Authorization"), "Bearer new_token")
        XCTAssertEqual(httpClientSpy.requestedURLRequests[3].value(forHTTPHeaderField: "Authorization"), "Bearer new_token")
    }
    
    func test_concurrentLogoutTriggers_callOnNotAuthenticatedOnlyOnce() {
        let tokenRefresherSpy = TokenRefresherSpy()
        var onNotAuthenticatedCalled = 0
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .logout(message: "Logout") },
            onNotAuthenticated: { _ in onNotAuthenticatedCalled += 1 }
        )
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let exp1 = expectation(description: "Wait for request 1")
        let exp2 = expectation(description: "Wait for request 2")
        
        DispatchQueue.global().async {
            sut.dispatch(request1) { result in
                exp1.fulfill()
            }.resume()
        }
        
        DispatchQueue.global().async {
            sut.dispatch(request2) { result in
                exp2.fulfill()
            }.resume()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            httpClientSpy.completes(withStatusCode: 403, data: Data(), at: 0)
            httpClientSpy.completes(withStatusCode: 403, data: Data(), at: 1)
        }
        
        wait(for: [exp1, exp2], timeout: 2.0)
        
        XCTAssertEqual(onNotAuthenticatedCalled, 1, "Expected onNotAuthenticated to be called only once")
    }
    
    func test_concurrentRefreshFailures_callOnNotAuthenticatedOnlyOnce() {
        let tokenRefresherSpy = TokenRefresherSpy()
        var onNotAuthenticatedCalled = 0
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .needsRefresh(onErrorMessage: nil) },
            onNotAuthenticated: { _ in onNotAuthenticatedCalled += 1 }
        )
        
        storage.set(model: "valid_token")
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        
        let exp1 = expectation(description: "Wait for request 1")
        
        DispatchQueue.global().async {
            sut.dispatch(request1) { result in
            }.resume()
        }
        
        DispatchQueue.global().async {
            sut.dispatch(request2) { result in
            }.resume()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 0)
            httpClientSpy.completes(withStatusCode: 401, data: Data(), at: 1)
            tokenRefresherSpy.complete(with: .failure(.internal))
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 1)
        
        XCTAssertEqual(onNotAuthenticatedCalled, 1, "Expected onNotAuthenticated to be called only once")
    }
    
    func test_multipleAuthenticationFails_doesNotResetsOnNotAuthenticated() {
        var cancellables = Set<AnyCancellable>()
        let tokenRefresherSpy = TokenRefresherSpy()
        var onNotAuthenticatedCalled = 0
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .logout(message: "Logout") },
            onNotAuthenticated: { _ in onNotAuthenticatedCalled += 1 }
        )
        
        let initialSetExp = expectation(description: "Wait for initial set")
        storage.set(model: "valid_token")
            .sink { _ in initialSetExp.fulfill() }
            .store(in: &cancellables)
        wait(for: [initialSetExp], timeout: 1.0)
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        let exp = expectation(description: "Wait for request")
        exp.expectedFulfillmentCount = 3
        
        sut.dispatch(request1) { _ in
            exp.fulfill()
        }.resume()
        
        sut.dispatch(request2) { _ in
            exp.fulfill()
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 403, data: Data())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            httpClientSpy.completes(withStatusCode: 403, data: Data(), at: 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(onNotAuthenticatedCalled, 1, "Expected onNotAuthenticated to be called only once")
    }
    
    func test_accessTokenUpdate_resetsHasHandledUnauthenticated() {
        var cancellables = Set<AnyCancellable>()
        let tokenRefresherSpy = TokenRefresherSpy()
        var onNotAuthenticatedCalled = 0
        let (sut, storage, httpClientSpy, _) = makeSUT(
            tokenRefresher: tokenRefresherSpy,
            isAuthenticated: { _ in .logout(message: "Logout") },
            onNotAuthenticated: { _ in onNotAuthenticatedCalled += 1 }
        )
        
        let initialSetExp = expectation(description: "Wait for initial set")
        storage.set(model: "valid_token")
            .sink { _ in initialSetExp.fulfill() }
            .store(in: &cancellables)
        wait(for: [initialSetExp], timeout: 1.0)
        
        let request1 = URLRequest(url: URL(string: "http://test.com/1")!)
        let request2 = URLRequest(url: URL(string: "http://test.com/2")!)
        let request3 = URLRequest(url: URL(string: "http://test.com/3")!)
        let exp = expectation(description: "Wait for request")
        exp.expectedFulfillmentCount = 4
        
        sut.dispatch(request1) { _ in
            exp.fulfill()
        }.resume()
        
        httpClientSpy.completes(withStatusCode: 403, data: Data())
        XCTAssertEqual(onNotAuthenticatedCalled, 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            storage.set(model: "new_valid_token")
                        .sink { _ in exp.fulfill() }
                        .store(in: &cancellables)
            sut.dispatch(request2) { _ in
                exp.fulfill()
            }.resume()
            httpClientSpy.completes(withStatusCode: 403, data: Data(), at: 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(onNotAuthenticatedCalled, 2)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        tokenRefresher: TokenRefresherSpy = TokenRefresherSpy(),
        storage: InMemoryStorage<String> = InMemoryStorage<String>(),
        refreshStorage: InMemoryStorage<String> = InMemoryStorage<String>(),
        isAuthenticated: @escaping AuthenticatedHTTPClientDecorator.AuthenticationPolicy = { _ in .authenticated },
        onNotAuthenticated: ((String?) -> Void)? = nil,
        queue: DispatchQueue = DispatchQueue(label: "com.wrapkit.tokenLock"),
        httpClientSpy: HTTPClientSpy = HTTPClientSpy(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthenticatedHTTPClientDecorator,
        storage: InMemoryStorage<String>,
        httpClientSpy: HTTPClientSpy,
        tokenRefresherSpy: TokenRefresherSpy
    ) {
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: httpClientSpy,
            accessTokenStorage: storage,
            refreshTokenStorage: refreshStorage,
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
        checkForMemoryLeaks(tokenRefresher, file: file, line: line)
        return (sut, storage, httpClientSpy, tokenRefresher)
    }
    
    class TokenRefresherSpy: TokenRefresher {
        var completion: ((Result<Tokens, ServiceError>) -> Void)?
        var refreshCalledCount: Int = 0
        
        func refresh(completion: @escaping (Result<Tokens, ServiceError>) -> Void) {
            self.completion = completion
            refreshCalledCount += 1
        }
        
        func complete(with result: Result<Tokens, ServiceError>) {
            completion?(result)
        }
    }
}
