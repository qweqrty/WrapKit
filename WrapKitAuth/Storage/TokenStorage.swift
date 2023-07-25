//
//  TokenStorage.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public protocol TokenStorage {
    func getAccessToken() -> String?
    
    func getRefreshToken() -> String?
    
    @discardableResult
    func set(accessToken: String) -> Bool
    
    @discardableResult
    func set(refreshToken: String) -> Bool
    
    func clear() -> Bool
}
