//
//  Body.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Body: Printable {
    func encoded() throws -> Data
}

extension Body {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        let data = try? encoded()
        return data?.utf8Description ?? "<invalid>"
    }
}

extension Data: Body {
    public func encoded() throws -> Data {
        return self
    }
}

/// <mark> application/json
public protocol JSONBody: Body, Encodable {
    var encodingStrategy: JSONEncodingStrategy { get }
}

extension JSONBody {
    public var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy()
    }

    /// <mark> Body
    public func encoded() throws -> Data {
        do {
            return try encoded(encodingStrategy)
        } catch let error {
            throw RequestEncodingError(reason: .invalidJSONBodyEncoding(underlyingError: error))
        }
    }
}

extension Array: Body, JSONBody where Element: Encodable { }

extension Dictionary: Body, JSONBody where Key == String, Value: Encodable { }

public protocol JSONArrayBody: JSONBody, JSONBodyParamConvertible {
    var bodyParams: [JSONBodyParamConvertible] { get }
}

extension JSONArrayBody {
    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for param in bodyParams {
            try param.encoded(in: &container)
        }
    }

    /// <mark> JSONBodyValueConvertible
    public func encoded(in container: inout UnkeyedEncodingContainer) throws {
        try container.encode(self)
    }

    public func encoded<T: CodingKey>(for key: T, in container: inout KeyedEncodingContainer<T>) throws {
        try container.encode(self, forKey: key)
    }
}

public protocol JSONBodyParamConvertible: Printable {
    func encoded(in container: inout UnkeyedEncodingContainer) throws
    func encoded<T: CodingKey>(for key: T, in container: inout KeyedEncodingContainer<T>) throws
}

public protocol JSONObjectBody: JSONBody, JSONBodyParamConvertible {
    associatedtype SomeJSONBodyKeyedParam : JSONBodyKeyedParamConvertible

    var bodyParams: [SomeJSONBodyKeyedParam] { get }
}

extension JSONObjectBody {
    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SomeJSONBodyKeyedParam.Key.self)

        for param in bodyParams {
            try param.encoded(in: &container)
        }
    }

    /// <mark> JSONBodyParamConvertible
    public func encoded(in container: inout UnkeyedEncodingContainer) throws {
        try container.encode(self)
    }

    public func encoded<T: CodingKey>(for key: T, in container: inout KeyedEncodingContainer<T>) throws {
        try container.encode(self, forKey: key)
    }
}

public protocol JSONBodyKeyedParamConvertible: Printable {
    associatedtype Key: CodingKey

    var key: Key { get }

    func encoded(in container: inout KeyedEncodingContainer<Key>) throws
}

public struct JSONBodyKeyedParam<Key: CodingKey>: JSONBodyKeyedParamConvertible {
    public let key: Key
    public let param: JSONBodyParam

    public init(
        _ key: Key,
        _ value: AnyEncodable? = nil,
        _ encodingPolicy: JSONBodyEncodingPolicy = .setAlways
    ) {
        self.key = key
        self.param = JSONBodyParam(value, encodingPolicy)
    }

    public init<T: Encodable>(
        _ key: Key,
        _ value: T?,
        _ encodingPolicy: JSONBodyEncodingPolicy = .setAlways
    ) {
        self.key = key
        self.param = JSONBodyParam(value, encodingPolicy)
    }

    /// <mark> JSONBodyKeyedValueConvertible
    public func encoded(in container: inout KeyedEncodingContainer<Key>) throws {
        try param.encoded(for: key, in: &container)
    }
}

extension JSONBodyKeyedParam {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key.debugDescription):\(param.debugDescription)"
    }
}

public struct JSONBodyParam: JSONBodyParamConvertible {
    public let value: AnyEncodable?
    public let encodingPolicy: JSONBodyEncodingPolicy

    public init(
        _ value: AnyEncodable? = nil,
        _ encodingPolicy: JSONBodyEncodingPolicy = .setAlways
    ) {
        self.value = value
        self.encodingPolicy = encodingPolicy
    }

    public init<T: Encodable>(
        _ value: T?,
        _ encodingPolicy: JSONBodyEncodingPolicy
    ) {
        if let v = value {
            self.value = AnyEncodable(v)
        } else {
            self.value = nil
        }
        self.encodingPolicy = encodingPolicy
    }

    /// <mark> JSONBodyValueConvertible
    public func encoded(in container: inout UnkeyedEncodingContainer) throws {
        switch encodingPolicy {
            case .setAlways:
                if let v = value {
                    try container.encode(v)
                } else {
                    try container.encodeNil()
                }
            case .setIfPresent:
                if let v = value {
                    try container.encode(v)
                }
        }
    }

    public func encoded<T: CodingKey>(for key: T, in container: inout KeyedEncodingContainer<T>) throws {
        switch encodingPolicy {
            case .setAlways:
                if let v = value {
                    try container.encode(v, forKey: key)
                } else {
                    try container.encodeNil(forKey: key)
                }
            case .setIfPresent:
                if let v = value {
                    try container.encode(v, forKey: key)
                }
        }
    }
}

extension JSONBodyParam {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(value?.debugDescription ?? "<nil>")(\(encodingPolicy.debugDescription))"
    }
}

public enum JSONBodyEncodingPolicy: String, Printable {
    case setAlways = "always" /// <note> Set null if the value is nil.
    case setIfPresent = "ifPresent" /// <note> Ignore if the value is nil.
}

/// <mark> application/x-www-form-urlencoded
public protocol FormURLEncodedBodyParamConvertible: Printable {
    var key: String { get }
    var value: URLParamValueEncodable? { get }
}

extension FormURLEncodedBodyParamConvertible {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key):\(value?.debugDescription ?? "<nil>")"
    }
}

public protocol FormURLEncodedBody: Body {
    var bodyParams: [FormURLEncodedBodyParamConvertible] { get }
    var encodingStrategy: URLEncodingStrategy { get }
}

extension FormURLEncodedBody {
    public var encodingStrategy: URLEncodingStrategy {
        return URLEncodingStrategy()
    }
}

extension FormURLEncodedBody {
    /// <mark> Body
    public func encoded() throws -> Data {
        let encoder = FormURLEncodedBodyEncoder()
        encoder.encodingStrategy = encodingStrategy
        return try encoder.encode(bodyParams)
    }
}

public struct FormURLEncodedBodyParam: FormURLEncodedBodyParamConvertible {
    public let key: String
    public let value: URLParamValueEncodable?
}

private class FormURLEncodedBodyEncoder {
    var encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()

    private static let allowedCharacters: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(" ")
        allowed.remove("+")
        allowed.remove("/")
        allowed.remove("?")
        return allowed
    }()

    func encode(_ urlEncodedParams: [FormURLEncodedBodyParamConvertible]) throws -> Data {
        var encodedUrlEncodedParams: [String] = []

        for param in urlEncodedParams {
            let escapedKey = escape(param.key)

            if let value = param.value {
                encodedUrlEncodedParams.append("\(escapedKey)=\(escape(try value.urlEncoded(encodingStrategy)))")
            } else {
                if let encodedNil = encodingStrategy.nullity.encoded() {
                    encodedUrlEncodedParams.append("\(escapedKey)=\(encodedNil)")
                } else {
                    throw RequestEncodingError(reason: .invalidFormURLBodyEncoding(key: param.key))
                }
            }
        }
        return Data(encodedUrlEncodedParams.joined(separator: "&").utf8)
    }
}

extension FormURLEncodedBodyEncoder {
    private func escape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: Self.allowedCharacters)!
            .replacingOccurrences(of: " ", with: "+")
    }
}
