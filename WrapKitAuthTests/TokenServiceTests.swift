//
//  TokenServiceTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

final class TokenServiceTests: XCTestCase {
    func test_getAccessToken_completesWithToken_whenAccessStored() {
        XCTAssertEqual(resultFor(accessToken: "accessToken", refreshToken: nil, refresh: nil), "accessToken")
        XCTAssertEqual(resultFor(accessToken: "accessToken", refreshToken: "refreshToken", refresh: { refreshToken, completion  in
            completion(.init(accessToken: "anotherToken"))
        }), "accessToken")
        XCTAssertEqual(resultFor(accessToken: "accessToken", refreshToken: nil, refresh: { refreshToken, completion  in
            completion(.init(accessToken: "anotherToken"))
        }), "accessToken")
    }
    
    func test_getAccessToken_refreshesAccessToken_whenRefreshStored() {
        XCTAssertEqual(resultFor(accessToken: nil, refreshToken: "refreshToken", refresh: { refreshToken, completion  in
            completion(.init(accessToken: "accessToken"))
        }), "accessToken")
    }

    func test_getAccessToken_completesWithNil_ifNoTokensStored() {
        XCTAssertEqual(resultFor(accessToken: nil, refreshToken: nil, refresh: { refreshToken, completion  in
            completion(.init(accessToken: "accessToken"))
        }), nil)
    }
    
    func test_getAccessToken_completesWithNil_ifNoRefreshFunctionalityProvided() {
        XCTAssertEqual(resultFor(accessToken: nil, refreshToken: "refreshToken", refresh: nil), nil)
    }
}

extension TokenServiceTests {
    private func makeSUT(
        refresh: ((TokenService.RefreshTokenRequest, ((TokenService.RefreshTokenResponse?) -> Void)) -> Void)?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (TokenService, TokenStorage) {
        let storage = TokenStorageSpy()
        let sut = TokenService(
            storage: storage,
            refresh: refresh
        )
        return (sut, storage)
    }
    
    func resultFor(accessToken: String?, refreshToken: String?, refresh: TokenService.Refresh?, file: StaticString = #file, line: UInt = #line) -> String? {
        let exp = expectation(description: "await completion")
        let (sut, spy) = makeSUT(refresh: refresh, file: file, line: line)
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
}
