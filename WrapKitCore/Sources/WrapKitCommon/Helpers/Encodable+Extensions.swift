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
            // Safely unwrap optionals to avoid "Optional(...)" in the output
            let value: String
            if let unwrapped = child.value as? String {
                value = unwrapped
            } else if let unwrapped = child.value as? CustomStringConvertible {
                value = unwrapped.description
            } else {
                return nil
            }
            
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
    
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
    
    func toURLFormEncodedString(withRootKey rootKey: String? = nil, withAllowedCharacters allowedCharacters: CharacterSet = .urlQueryAllowed) -> Data? {
            if let rootKey = rootKey {
                // When rootKey is provided, encode as JSON and assign to the key
                guard let jsonData = try? JSONEncoder().encode(self),
                      let jsonString = String(data: jsonData, encoding: .utf8),
                      let encodedJsonString = jsonString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
                    return nil
                }
                return "\(rootKey)=\(encodedJsonString)".data(using: .utf8)
            } else {
                // When no rootKey, convert to dictionary and create form-encoded string
                guard let dict = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self)) as? [String: Any] else {
                    return nil
                }
                
                let pairs = dict.compactMap { key, value -> String? in
                    let stringValue: String
                    switch value {
                    case let str as String:
                        stringValue = str
                    case let num as NSNumber:
                        stringValue = num.stringValue
                    case let bool as Bool:
                        stringValue = bool ? "true" : "false"
                    case is NSNull, nil:
                        stringValue = ""
                    default:
                        // For nested objects, encode as JSON string
                        if let data = try? JSONSerialization.data(withJSONObject: value),
                           let jsonStr = String(data: data, encoding: .utf8) {
                            stringValue = jsonStr
                        } else {
                            return nil
                        }
                    }
                    
                    guard let encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
                        return nil
                    }
                    return "\(key)=\(encodedValue)"
                }
                
                let formString = pairs.joined(separator: "&")
                return formString.data(using: .utf8)
            }
        }
}
