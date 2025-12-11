//
//  Decimal+Decodable.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 11/12/25.
//

import Foundation

@propertyWrapper
public struct PreciseDecimal: Decodable, Hashable, Equatable {
    public var wrappedValue: Decimal
    
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
}

@propertyWrapper
public struct PreciseDecimalOptional: Decodable, Hashable, Equatable {
    public var wrappedValue: Decimal?
    
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
}
