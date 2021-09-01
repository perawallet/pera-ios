//
//  HIPCache.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPCache: HIPCacheConvertible {
    private let userDefaults = UserDefaults.standard

    public init() { }

    public func getObject<T>(for key: HIPCacheKeyConvertible) -> T? {
        return userDefaults.object(forKey: key.cacheEncoded()) as? T
    }

    public func set<T>(object: T, for key: HIPCacheKeyConvertible) {
        userDefaults.set(object, forKey: key.cacheEncoded())
        userDefaults.synchronize()
    }

    public func getModel<T: Model>(for key: HIPCacheKeyConvertible) -> T? {
        if let data: Data = getObject(for: key) {
            return try? T.decoded(data)
        }
        return nil
    }

    public func set<T: Model>(model: T, for key: HIPCacheKeyConvertible) {
        if let data = try? model.encoded() {
            set(object: data, for: key)
        }
    }

    public func remove(for key: HIPCacheKeyConvertible) {
        userDefaults.removeObject(forKey: key.cacheEncoded())
        userDefaults.synchronize()
    }
}
