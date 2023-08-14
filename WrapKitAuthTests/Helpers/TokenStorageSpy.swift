//
//  TokenStorageSpy.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import WrapKit

class TokenStorageSpy: TokenStorage {
    var accessToken: String?
    var refreshToken: String?
    var setAccessTokenShouldSucceed: Bool

    init(accessToken: String? = nil, refreshToken: String? = nil, setAccessTokenShouldSucceed: Bool = true) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.setAccessTokenShouldSucceed = setAccessTokenShouldSucceed
    }

    func getAccessToken() -> String? {
        return accessToken
    }

    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    @discardableResult
    func set(accessToken: String) -> Bool {
        self.accessToken = accessToken
        return setAccessTokenShouldSucceed
    }
    
    @discardableResult
    func set(refreshToken: String) -> Bool {
        self.refreshToken = refreshToken
        return true
    }

    func clear() -> Bool {
        self.accessToken = nil
        self.refreshToken = nil
        return true
    }
}
