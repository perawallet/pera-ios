//
//  Headers.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation

public struct Headers {
    fileprivate typealias Table = [String: Header]

    private var table: Table = [:]
    
    init() { }

    init(_ rawHeaders: [AnyHashable: Any]?) {
        guard let someRawHeaders = rawHeaders else { return }

        for rawHeader in someRawHeaders {
            if let key = rawHeader.key as? String {
                let value = rawHeader.value as? String

                switch key {
                case HTTPHeader.accept:
                    table[key] = AcceptHeader(value ?? "")
                case HTTPHeader.acceptEncoding:
                    table[key] = AcceptEncodingHeader(value ?? "")
                case HTTPHeader.acceptLanguage:
                    table[key] = AcceptLanguageHeader(value ?? "")
                case HTTPHeader.authorization:
                    table[key] = AuthorizationHeader(value)
                case HTTPHeader.contentLength:
                    table[key] = ContentLengthHeader(value ?? "")
                case HTTPHeader.contentType:
                    table[key] = ContentTypeHeader(value ?? "")
                default:
                    table[key] = CustomHeader(key: key, value: value)
                }
            }
        }
    }
}

extension Headers {
    public subscript (key: String) -> String? {
        return table[key]?.value
    }

    public mutating func insert(_ newHeader: Header) {
        table[newHeader.key] = newHeader
    }

    @discardableResult
    public mutating func remove(for key: String) -> Header? {
        return table.removeValue(forKey: key)
    }
}

extension Headers {
    /// <note>
    /// The left-side headers will override the right-side headers if they have fields in common.
    public static func >> (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        newHeaders.table = lhs.table.merging(rhs.table) { lhsValue, _ in return lhsValue }
        return newHeaders
    }

    /// <note>
    /// The right-side headers will override the left-side headers if they have fields in common.
    public static func << (lhs: Headers, rhs: Headers) -> Headers {
        var newHeaders = Headers()
        newHeaders.table = lhs.table.merging(rhs.table) { _, rhsValue in return rhsValue }
        return newHeaders
    }
}

extension Headers {
    public struct Index {
        fileprivate let wrapped: Table.Index
    }
}

extension Headers: Collection {
    public typealias Element = Header
    
    public var startIndex: Headers.Index {
        return Index(wrapped: table.startIndex)
    }
    public var endIndex: Headers.Index {
        return Index(wrapped: table.endIndex)
    }
    
    public subscript (index: Headers.Index) -> Element {
        return table[index.wrapped].value
    }
    
    public func index(after i: Headers.Index) -> Headers.Index {
        return Index(wrapped: table.index(after: i.wrapped))
    }
}

extension Headers: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Header...) {
        table = Table(elements.map { ($0.key, $0) }) { $1 }
    }
}

extension Headers: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        {
          \(table.map({ $0.value.debugDescription }).joined(separator: ",\n  "))
        }
        """
        }
}

extension Headers.Index: Comparable {
    public static func == (lhs: Headers.Index, rhs: Headers.Index) -> Bool {
        return lhs.wrapped == rhs.wrapped
    }

    public static func < (lhs: Headers.Index, rhs: Headers.Index) -> Bool {
        return  lhs.wrapped < rhs.wrapped
    }
}

public protocol Header: Printable {
    var key: String { get }
    var value: String? { get }
}

extension Header {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(key):\(value?.debugDescription ?? "<nil>")"
    }
}

public struct AcceptHeader: Header {
    public let key = HTTPHeader.accept
    public let value: String?

    public init(_ value: String) {
        self.value = value
    }

    public static func json() -> Self {
        return Self("application/json")
    }

    public static func formUrlEncoded() -> Self {
        return Self("application/x-www-form-urlencoded")
    }
}

public struct AcceptEncodingHeader: Header {
    public let key = HTTPHeader.acceptEncoding
    public let value: String?

    public init(_ value: String) {
        self.value = value
    }

    public static func gzip() -> Self {
        return Self("gzip;q=1.0, *;q=0.5")
    }
}

public struct AcceptLanguageHeader: Header {
    public let key = HTTPHeader.acceptLanguage
    public let value: String?

    init(_ value: String) {
        self.value = value
    }
}

public struct AuthorizationHeader: Header {
    public let key = HTTPHeader.authorization
    public let value: String?

    public init(_ value: String? = nil) {
        self.value = value
    }

    public static func token(_ value: String?) -> Self {
        let tokenValue = value.map { "Token \($0)" }
        return Self(tokenValue)
    }

    public static func bearer(_ value: String?) -> Self {
        let bearerValue = value.map { "Bearer \($0)" }
        return Self(bearerValue)
    }

    public static func basic(_ value: String?) -> Self {
        let basicValue = value.map { "Basic \($0)" }
        return Self(basicValue)
    }
}

public struct ContentLengthHeader: Header {
    public let key = HTTPHeader.contentLength
    public let value: String?

    public init(_ count: Int) {
        self.value = "\(count)"
    }

    public init(_ value: String) {
        self.value = value
    }
}

public struct ContentTypeHeader: Header {
    public let key = HTTPHeader.contentType
    public let value: String?

    public init(_ value: String) {
        self.value = value
    }

    public static func json() -> Self {
        return Self("application/json")
    }

    public static func formUrlEncoded() -> Self {
        return Self("application/x-www-form-urlencoded")
    }
}

public struct CustomHeader: Header {
    public let key: String
    public let value: String?

    public init(
        key: String,
        value: String?
    ) {
        self.key = key
        self.value = value
    }
}

public enum HTTPHeader {
    public static let accept = "Accept"
    public static let acceptEncoding = "Accept-Encoding"
    public static let acceptLanguage = "Accept-Language"
    public static let authorization = "Authorization"
    public static let contentLength = "Content-Length"
    public static let contentType = "Content-Type"
}
