//
//  Query.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.03.2019.
//

import Foundation

public protocol Query: Printable {
    func encoded() throws -> [URLQueryItem]
}

extension Query {
    func encodedString() throws -> String? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = try encoded()
        return urlComponents.query
    }
}

extension Query {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        do {
            return try encodedString() ?? "<nil>"
        } catch {
            return "<invalid>"
        }
    }
}

extension Dictionary: Query where Key == String, Value == URLParamValueEncodable? {
    public func encoded() throws -> [URLQueryItem] {
        return try encoded(URLEncodingStrategy())
    }

    public func encoded(_ encodingStrategy: URLEncodingStrategy) throws -> [URLQueryItem] {
        var encoder = QueryEncoder()
        encoder.encodingStrategy = encodingStrategy
        return try encoder.encode(self)
    }
}

public protocol ObjectQuery: Query {
    associatedtype SomeObjectQueryKeyedParam: ObjectQueryKeyedParamConvertible

    var queryParams: [SomeObjectQueryKeyedParam] { get }
    var encodingStrategy: URLEncodingStrategy { get }
}

extension ObjectQuery {
    public var encodingStrategy: URLEncodingStrategy {
        return URLEncodingStrategy()
    }

    public func encoded() throws -> [URLQueryItem] {
        var encoder = QueryEncoder()
        encoder.encodingStrategy = encodingStrategy
        return try encoder.encode(queryParams)
    }
}

public protocol ObjectQueryKeyedParamConvertible: Printable {
    associatedtype Key: CodingKey

    var key: Key { get }
    var encodingValue: URLParamValueEncodable? { get }
    var encodingPolicy: ObjectQueryEncodingPolicy { get }
}

public struct ObjectQueryKeyedParam<Key: CodingKey>: ObjectQueryKeyedParamConvertible {
    public let key: Key
    public let encodingValue: URLParamValueEncodable?
    public let encodingPolicy: ObjectQueryEncodingPolicy

    public init(
        _ key: Key,
        _ encodingValue: URLParamValueEncodable?,
        _ encodingPolicy: ObjectQueryEncodingPolicy = .setAlways
    ) {
        self.key = key
        self.encodingValue = encodingValue
        self.encodingPolicy = encodingPolicy
    }
}

extension ObjectQueryKeyedParam {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key.stringValue):\(encodingValue?.debugDescription ?? "<nil>")(\(encodingPolicy.debugDescription)"
    }
}

public enum ObjectQueryEncodingPolicy: String, Printable {
    case setAlways = "always" /// <note> Set null if the value is nil.
    case setIfPresent = "ifPresent" /// <note> Ignore if the value is nil.
}

private struct QueryEncoder {
    var encodingStrategy: URLEncodingStrategy = URLEncodingStrategy()

    func encode<Param: ObjectQueryKeyedParamConvertible>(_ queryParams: [Param]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in queryParams {
            do {
                switch param.encodingPolicy {
                case .setAlways:
                    queryItems.append(try encode(param))
                case .setIfPresent:
                    if param.encodingValue != nil {
                        queryItems.append(try encode(param))
                    }
                }
            } catch {
                throw RequestEncodingError(reason: .invalidURLQueryEncoding(key: param.key.stringValue))
            }
        }
        return queryItems
    }

    func encode(_ queryParams: [String: URLParamValueEncodable?]) throws -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        for param in queryParams {
            do {
                let value = try param.value.map { escape(try $0.urlEncoded(encodingStrategy)) }
                queryItems.append(URLQueryItem(name: escape(param.key), value: value))
            } catch {
                throw RequestEncodingError(reason: .invalidURLQueryEncoding(key: param.key))
            }
        }
        return queryItems
    }
}

extension QueryEncoder {
    private func encode<Param: ObjectQueryKeyedParamConvertible>(_ param: Param) throws -> URLQueryItem {
        let key = escape(param.key.stringValue)
        let value = try param.encodingValue.urlEncoded(encodingStrategy)
        return URLQueryItem(name: key, value: value.map { escape($0) })
    }
}

extension QueryEncoder {
    private func escape(_ string: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("+")
        return string.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
}
