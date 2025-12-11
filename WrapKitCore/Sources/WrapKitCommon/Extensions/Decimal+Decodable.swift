//
//  Decimal+Decodable.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 11/12/25.
//

import Foundation

@propertyWrapper
public struct PreciseDecimal: Codable {
    public private(set) var wrappedValue: Decimal
    
    public init(wrappedValue: Decimal) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self),
           let decimal = Decimal(string: stringValue) {
            self.wrappedValue = decimal
        } else if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = Decimal(intValue)
        } else {
            let doubleValue = try container.decode(Double.self)
            self.wrappedValue = Decimal(doubleValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        // Encode as string to preserve precision
        try container.encode(wrappedValue.description)
    }
}

@propertyWrapper
public struct PreciseDecimalOptional: Codable {
    public private(set) var wrappedValue: Decimal?
    
    public init(wrappedValue: Decimal?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.wrappedValue = nil
        } else if let stringValue = try? container.decode(String.self),
           let decimal = Decimal(string: stringValue) {
            self.wrappedValue = decimal
        } else  if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = Decimal(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self.wrappedValue = Decimal(doubleValue)
        } else {
            self.wrappedValue = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = wrappedValue {
            try container.encode(value.description)
        } else {
            try container.encodeNil()
        }
    }
}
