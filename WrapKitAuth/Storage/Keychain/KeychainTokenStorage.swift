//
//  KeychainTokenStorage.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import KeychainSwift

public class KeychainTokenStorage: TokenStorage {
    private static let AccessTokenKey = "AccessToken"
    private static let RefreshTokenKey = "RefreshToken"
    
    private let keychain = KeychainSwift() // MARK: - Implicit
    
    public init() { }
    
    public func getAccessToken() -> String? {
        return keychain.get(Self.AccessTokenKey)
    }
    
    public func getRefreshToken() -> String? {
        return keychain.get(Self.RefreshTokenKey)
    }
    
    public func set(accessToken: String) -> Bool {
        return keychain.set(accessToken, forKey: Self.AccessTokenKey)
    }
    
    public func set(refreshToken: String) -> Bool {
        return keychain.set(refreshToken, forKey: Self.RefreshTokenKey)
    }
    
    public func clear() -> Bool {
        return keychain.delete(Self.AccessTokenKey) && keychain.delete(Self.RefreshTokenKey)
    }
}
