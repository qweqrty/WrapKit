//
//  TokenStorageSpy.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import WrapKitAuth

class TokenStorageSpy: TokenStorage {
    private var accessToken: String?
    private var refreshToken: String?
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    func set(accessToken: String) -> Bool {
        self.accessToken = accessToken
        return true
    }
    
    func set(refreshToken: String) -> Bool {
        self.refreshToken = refreshToken
        return true
    }
    
    func clear() -> Bool {
        accessToken = nil
        refreshToken = nil
        return true
    }
}
