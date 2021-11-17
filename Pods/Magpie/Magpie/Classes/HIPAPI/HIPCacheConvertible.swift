//
//  HIPCacheConvertible.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol HIPCacheConvertible {
    func getObject<T>(for key: HIPCacheKeyConvertible) -> T?
    func set<T>(object: T, for key: HIPCacheKeyConvertible)
    func getModel<T: Model>(for key: HIPCacheKeyConvertible) -> T?
    func set<T: Model>(model: T, for key: HIPCacheKeyConvertible)
    func remove(for key: HIPCacheKeyConvertible)
}

extension HIPCacheConvertible {
    public func removeAll<T: Sequence>(_ keys: T) where T.Element == HIPCacheKeyConvertible {
        keys.forEach(remove)
    }
}

public protocol HIPCacheKeyConvertible {
    func cacheEncoded() -> String
}

extension HIPCacheKeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func cacheEncoded() -> String {
        return rawValue
    }
}

extension String: HIPCacheKeyConvertible {
    public func cacheEncoded() -> String {
        return self
    }
}
