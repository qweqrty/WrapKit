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
}
