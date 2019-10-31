//
//  Codable+Any.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 31.10.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AnyCodable: Codable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(NSNull())
        } else if let boolValue = try? container.decode(Bool.self) {
            self.init(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self.init(intValue)
        } else if let uintValue = try? container.decode(UInt.self) {
            self.init(uintValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self.init(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self.init(stringValue)
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self.init(arrayValue.map { $0.value })
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            self.init(dictionaryValue.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull, is Void:
            try container.encodeNil()
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let intValue as Int:
            try container.encode(intValue)
        case let int8Value as Int8:
            try container.encode(int8Value)
        case let int16Value as Int16:
            try container.encode(int16Value)
        case let int32Value as Int32:
            try container.encode(int32Value)
        case let int64Value as Int64:
            try container.encode(int64Value)
        case let uintValue as UInt:
            try container.encode(uintValue)
        case let uint8Value as UInt8:
            try container.encode(uint8Value)
        case let uint16Value as UInt16:
            try container.encode(uint16Value)
        case let uint32Value as UInt32:
            try container.encode(uint32Value)
        case let uint64Value as UInt64:
            try container.encode(uint64Value)
        case let floatValue as Float:
            try container.encode(floatValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let dateValue as Date:
            try container.encode(dateValue)
        case let urlValue as URL:
            try container.encode(urlValue)
        case let arrayValue as [Any?]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictionaryValue as [String: Any?]:
            try container.encode(dictionaryValue.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}
