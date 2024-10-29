//
//  Encodable+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/12/23.
//

import Foundation

public extension Encodable {
    func urlEncodedString() -> String? {
        let mirror = Mirror(reflecting: self)

        let urlEncodedComponents = mirror.children.compactMap { child -> String? in
            guard let label = child.label else { return nil }
            let value = "\(child.value)"
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(label)=\(encodedValue)"
        }

        return urlEncodedComponents.joined(separator: "&")
    }
    
    /// Converts the Encodable object to URL-encoded `Data` for `application/x-www-form-urlencoded` requests.
    func asUrlEncodedData() -> Data? {
        // Encode the object into dictionary format using JSONEncoder
        guard let jsonData = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        // Map each key-value pair into "key=value" and join with "&"
        let parameterArray = dictionary.compactMap { (key, value) -> String? in
            guard let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return "\(escapedKey)=\(escapedValue)"
        }
        
        let urlEncodedString = parameterArray.joined(separator: "&")
        return urlEncodedString.data(using: .utf8)
    }
    
    func toURLFormEncodedString(withRootKey rootKey: String? = nil, withAllowedCharacters allowedCharacters: CharacterSet = .urlQueryAllowed) -> Data? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        guard let encodedJsonString = jsonString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        if let rootKey = rootKey {
            return "\(rootKey)=\(encodedJsonString)".data(using: .utf8)
        } else {
            return encodedJsonString.data(using: .utf8)
        }
    }
}
