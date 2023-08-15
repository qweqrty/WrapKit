//
//  TokenServie.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public final class TokenService {
    public typealias Refresh = ((RefreshTokenRequest, @escaping ((RefreshTokenResponse?) -> Void)) -> Void)
    
    public struct RefreshTokenRequest: Encodable {
        public let refreshToken: String
        
        public init(refreshToken: String) {
            self.refreshToken = refreshToken
        }
    }

    public struct RefreshTokenResponse: Decodable {
        public let accessToken: String
        
        public init(accessToken: String) {
            self.accessToken = accessToken
        }
    }
    
    public let refresh: Refresh?
    public let storage: TokenStorage
    
    public init(
        storage: TokenStorage,
        refresh: Refresh?
    ) {
        self.storage = storage
        self.refresh = refresh
    }
    
    public func getAccessToken(completion: @escaping ((String?) -> Void)) {
        if let accessToken = storage.getAccessToken() {
            completion(accessToken)
        } else if let refreshToken = storage.getRefreshToken(), let refresh = refresh {
            refresh(.init(refreshToken: refreshToken)) { [weak self, completion] response in
                if let accessToken = response?.accessToken {
                    let isSuccessfullySetToken = self?.storage.set(accessToken: accessToken) ?? false
                    completion(isSuccessfullySetToken ? accessToken : nil)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
}
