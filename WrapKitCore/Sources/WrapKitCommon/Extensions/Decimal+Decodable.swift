//
//  Decimal+Decodable.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 11/12/25.
//

import Foundation

@propertyWrapper
struct PreciseDecimal: Codable {
    var wrappedValue: Decimal
    
    init(wrappedValue: Decimal) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self),
           let decimal = Decimal(string: stringValue) {
            self.wrappedValue = decimal
        } else if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = Decimal(intValue)
            return
        } else {
            let doubleValue = try container.decode(Double.self)
            self.wrappedValue = Decimal(doubleValue)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        // Encode as string to preserve precision
        try container.encode(wrappedValue.description)
    }
}
