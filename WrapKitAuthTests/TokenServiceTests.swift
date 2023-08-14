//
//  TokenServiceTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

class TokenServiceTests: XCTestCase {
    
    func test_getAccessToken_returnsStoredAccessToken() {
        let accessToken = "accessToken"
        let result = resultFor(accessToken: accessToken, refreshToken: nil, refresh: nil)
        XCTAssertEqual(result, accessToken)
    }
    
    func test_getAccessToken_completesWithRefreshedToken_ifNoStoredAccessTokenAndRefreshSucceeds() {
        let refreshToken = "refreshToken"
        let result = resultFor(accessToken: nil, refreshToken: refreshToken, refresh: refresh)
        XCTAssertEqual(result, "newAccessToken")
    }
    
    func test_getAccessToken_completesWithNil_ifNoTokensStoredAndRefreshIsNil() {
        let result = resultFor(accessToken: nil, refreshToken: nil, refresh: nil)
        XCTAssertNil(result)
    }

    func test_getAccessToken_completesWithNil_ifSettingRefreshedTokenFails() {
        let refreshToken = "refreshToken"
        let result = resultFor(accessToken: nil, refreshToken: refreshToken, refresh: refresh, setAccessTokenShouldSucceed: false)
        XCTAssertNil(result)
    }
    
    func test_getAccessToken_completesWithNil_ifNoStoredAccessTokenAndRefreshFails() {
        let refreshToken = "refreshToken"
        let result = resultFor(accessToken: nil, refreshToken: refreshToken, refresh: failingRefresh)
        XCTAssertNil(result)
    }

    func test_getAccessToken_completesWithNil_ifNoStoredAccessTokenAndNoRefreshToken() {
        let result = resultFor(accessToken: nil, refreshToken: nil, refresh: refresh)
        XCTAssertNil(result)
    }
}

extension TokenServiceTests {
    private func makeSUT(
        refresh: TokenService.Refresh?,
        setAccessTokenShouldSucceed: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (TokenService, TokenStorageSpy) {
        let storage = TokenStorageSpy(setAccessTokenShouldSucceed: setAccessTokenShouldSucceed)
        let sut = TokenService(
            storage: storage,
            refresh: refresh
        )
        return (sut, storage)
    }

    func resultFor(accessToken: String?, refreshToken: String?, refresh: TokenService.Refresh?, setAccessTokenShouldSucceed: Bool = true, file: StaticString = #file, line: UInt = #line) -> String? {
        let exp = expectation(description: "await completion")
        let (sut, spy) = makeSUT(refresh: refresh, setAccessTokenShouldSucceed: setAccessTokenShouldSucceed, file: file, line: line)
        var output: String?

        if let accessToken = accessToken {
            spy.set(accessToken: accessToken)
        }

        if let refreshToken = refreshToken {
            spy.set(refreshToken: refreshToken)
        }

        sut.getAccessToken { token in
            output = token
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
        return output
    }

    private var refresh: TokenService.Refresh {
        return { request, completion in
            completion(.init(accessToken: "newAccessToken"))
        }
    }
    
    private var failingRefresh: TokenService.Refresh {
        return { request, completion in
            completion(nil)
        }
    }
}
