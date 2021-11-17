//
//  URLSerializer.swift
//  Magpie
//
//  Created by Karasuluoglu on 12.12.2019.
//

import Foundation

public struct URLEncodingStrategy {
    public let nullity: NullityEncodingStrategy
    public let boolean: BooleanEncodingStrategy

    public init(
        nullity: NullityEncodingStrategy = .default,
        boolean: BooleanEncodingStrategy = .default
    ) {
        self.nullity = nullity
        self.boolean = boolean
    }
}

extension URLEncodingStrategy {
    public enum NullityEncodingStrategy {
        case `default` /// <sample> nil
        case empty /// <sample> ""
        case dash /// <sample> "-"
        case nullString /// <sample> "null"
        case other(String) /// <sample> "{string}"
    }

    public enum BooleanEncodingStrategy {
        case `default` /// <sample> "true" or "false"
        case number /// <sample> "1" or "0"
        case other(forTrue: String, forFalse: String) /// <sample> "{string}"
    }
}

extension URLEncodingStrategy: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "[URL Encoding] nullity:\(nullity.debugDescription) boolean:\(boolean.debugDescription)"
    }
}

extension URLEncodingStrategy.NullityEncodingStrategy {
    func encoded() -> String? {
        switch self {
        case .default:
            return nil
        case .empty:
            return ""
        case .dash:
            return "-"
        case .nullString:
            return "null"
        case .other(let string):
            return string
        }
    }
}

extension URLEncodingStrategy.NullityEncodingStrategy: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(encoded() ?? "<nil>")"
    }
}

extension URLEncodingStrategy.BooleanEncodingStrategy: Printable {
    /// <mark> CustomDeubugStringConvertible
    public var debugDescription: String {
        switch self {
        case .default:
            return "true/false"
        case .number:
            return "1/0"
        case .other(let forTrue, let forFalse):
            return "\(forTrue)/\(forFalse)"
        }
    }
}

public protocol URLParamValueEncodable: Printable {
    func urlEncoded(_ encodingStrategy: URLEncodingStrategy) throws -> String
}

extension URLParamValueEncodable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(self)"
    }
}

extension String: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        return self
    }
}

extension Int: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        return String(self)
    }
}

extension Float: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        return String(self)
    }
}

extension Double: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        return String(self)
    }
}

extension Bool: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        switch encodingStrategy.boolean {
        case .default:
            return self ? "true" : "false"
        case .number:
            return self ? "1" : "0"
        case .other(let trueDescription, let falseDescription):
            return self ? trueDescription : falseDescription
        }
    }
}

extension Array: URLParamValueEncodable where Element: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()) throws -> String {
        let encodedElements = try map { try $0.urlEncoded(encodingStrategy) }
        return "[\(encodedElements.joined(separator: ","))]"
    }
}

extension Dictionary: URLParamValueEncodable where Key == String, Value: URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy) throws -> String {
        let encodedElements = try map { "\($0.key):\(try $0.value.urlEncoded(encodingStrategy))" }
        return "{\(encodedElements.joined(separator: ","))}"
    }
}

extension Optional where Wrapped == URLParamValueEncodable {
    public func urlEncoded(_ encodingStrategy: URLEncodingStrategy) throws -> String? {
        switch self {
        case .some(let value):
            return try value.urlEncoded(encodingStrategy)
        case .none:
            return encodingStrategy.nullity.encoded()
        }
    }
}
