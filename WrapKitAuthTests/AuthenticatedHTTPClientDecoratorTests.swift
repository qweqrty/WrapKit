//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_dispatchRequest_enrichesRequestWithToken() {
        let (sut, clientSpy, tokenStorageSpy) = makeSUT(enrichRequestWithToken: { request, token in
            var request = request
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        })
        tokenStorageSpy.set(accessToken: "test-token")
        let request = URLRequest(url: makeURL())
        
        _ = sut.dispatch(request, completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLRequests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }

    func test_dispatchRequest_failsWithNotAuthenticatedError_whenAuthenticationPolicyFails() {
        let (sut, clientSpy, _) = makeSUT(authenticationPolicy: { _ in return false })
        
        expect(sut, toCompleteWith: .failure(AuthenticatedHTTPClientDecorator.NotAuthenticated())) {
            clientSpy.completes(withStatusCode: 200, data: Data())
        }
    }

    func test_dispatchRequest_succeeds_whenAuthenticationPolicyPasses() {
        let (sut, clientSpy, _) = makeSUT()
        let response = (data: Data(), response: HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        expect(sut, toCompleteWith: .success(response)) {
            clientSpy.completes(withStatusCode: 200, data: Data())
        }
    }

    func test_dispatchRequest_refreshesToken_whenAuthenticationPolicyFailsAndRefreshTokenAvailable() {
        let refreshToken = "refresh-token"
        let accessToken = "new-access-token"
        let (sut, clientSpy, tokenStorageSpy) = makeSUT(
            refresh: { _, completion in completion(.init(accessToken: accessToken)) },
            authenticationPolicy: { _ in return false }
        )
        tokenStorageSpy.set(refreshToken: refreshToken)
        
        _ = sut.dispatch(URLRequest(url: makeURL()), completion: { _ in })
        clientSpy.completes(withStatusCode: 200, data: Data())
        
        XCTAssertEqual(tokenStorageSpy.getAccessToken(), accessToken)
    }

    func test_dispatchRequest_doesNotRefreshToken_whenAuthenticationPolicyFailsAndNoRefreshToken() {
        let (sut, clientSpy, tokenStorageSpy) = makeSUT(
            authenticationPolicy: { _ in return false }
        )
        
        _ = sut.dispatch(URLRequest(url: makeURL()), completion: { _ in })
        clientSpy.completes(withStatusCode: 200, data: Data()) // Simulating successful response
        
        XCTAssertNil(tokenStorageSpy.getRefreshToken())
    }

}

extension AuthenticatedHTTPClientDecoratorTests {
    private func makeSUT(
        refresh: TokenService.Refresh? = nil,
        enrichRequestWithToken: @escaping AuthenticatedHTTPClientDecorator.EnrichRequestWithToken = { request, token in
            var request = request
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        },
        authenticationPolicy: @escaping AuthenticatedHTTPClientDecorator.AuthenticationPolicy = { _ in return true },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (AuthenticatedHTTPClientDecorator, HTTPClientSpy, TokenStorageSpy) {
        let tokenStorageSpy = TokenStorageSpy()
        let clientSpy = HTTPClientSpy()
        let tokenService = TokenService(storage: tokenStorageSpy, refresh: refresh)
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: clientSpy,
            tokenService: tokenService,
            enrichRequestWithToken: enrichRequestWithToken,
            isAuthenticated: authenticationPolicy
        )
        return (sut, clientSpy, tokenStorageSpy)
    }
    
    private func expect(_ sut: AuthenticatedHTTPClientDecorator, toCompleteWith expectedResult: HTTPClient.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.dispatch(URLRequest(url: makeURL())) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse.data, expectedResponse.data, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.statusCode, expectedResponse.response.statusCode, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.url, expectedResponse.response.url, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.mimeType, expectedResponse.response.mimeType, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }.resume()

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
