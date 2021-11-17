//
//  Model.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol Model: Codable, Printable {
    var isFault: Bool { get }

    static var encodingStrategy: JSONEncodingStrategy { get }
    static var decodingStrategy: JSONDecodingStrategy { get }

    func encoded() throws -> Data
    static func decoded(_ data: Data) throws -> Self
}

extension Model {
    public var isFault: Bool {
        return false
    }

    public static var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy()
    }
    public static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy()
    }

    public func encoded() throws -> Data {
        return try encoded(Self.encodingStrategy)
    }

    public static func decoded(_ data: Data) throws -> Self {
        return try decoded(data, using: Self.decodingStrategy)
    }
}

extension Model {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        do {
            let data = try encoded()
            return "[\(type(of: self))] \(data.utf8Description)"
        } catch {
            return "<invalid>"
        }
    }
}

public struct NoModel: Model { }

extension Array: Model where Element: Model {
    public func encoded() throws -> Data {
        return try encoded(Element.encodingStrategy)
    }

    public static func decoded(_ data: Data) throws -> Self {
        return try decoded(data, using: Element.decodingStrategy)
    }
}
