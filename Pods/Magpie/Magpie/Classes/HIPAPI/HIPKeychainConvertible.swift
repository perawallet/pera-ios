//
//  HIPKeychainConvertible.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol HIPKeychainConvertible {
    init(identifier: String)

    func getString(for key: HIPKeychainKeyConvertible) throws -> String?
    func set(_ string: String, for key: HIPKeychainKeyConvertible) throws
    func getData(for key: HIPKeychainKeyConvertible) throws -> Data?
    func set(_ data: Data, for key: HIPKeychainKeyConvertible) throws
    func getModel<T: Model>(for key: HIPKeychainKeyConvertible) throws -> T?
    func set<T: Model>(_ model: T, for key: HIPKeychainKeyConvertible) throws
    func remove(for key: HIPKeychainKeyConvertible) throws
    func removeAll() throws
}

extension HIPKeychainConvertible {
    public func removeAll<T: Sequence>(_ keys: T) throws where T.Element == HIPKeychainKeyConvertible {
        try keys.forEach(remove)
    }
}

public protocol HIPKeychainKeyConvertible {
    func keychainEncoded() -> String
}

extension HIPKeychainKeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func keychainEncoded() -> String {
        return rawValue
    }
}

extension String: HIPKeychainKeyConvertible {
    public func keychainEncoded() -> String {
        return self
    }
}
