//
//  Storable.swift
//  algorand
//
//  Created by Omer Emre Aslan on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

enum Store {
    case defaults
}

protocol Storable {
    associatedtype Object
    
    func save(_ string: String, for key: String, to store: Store)
    func save(_ data: Data, for key: String, to store: Store)
    
    func object(with key: String, to store: Store) -> Object?
    func string(with key: String, to store: Store) -> String?
    func data(with key: String, to store: Store) -> Data?
    
    func remove(with key: String, from store: Store)
    func clear(_ store: Store)
}

extension Storable {
    
    var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func save(_ string: String, for key: String, to store: Store) {
        switch store {
        case .defaults:
            userDefaults.set(string, for: key)
        }
    }
    
    func save(_ data: Data, for key: String, to store: Store) {
        switch store {
        case .defaults:
            userDefaults.set(data, for: key)
        }
    }
    
    func object(with key: String, to store: Store) -> Object? {
        return nil
    }
    
    func string(with key: String, to store: Store) -> String? {
        switch store {
        case .defaults:
            return userDefaults.string(forKey: key)
        }
    }
    
    func data(with key: String, to store: Store) -> Data? {
        switch store {
        case .defaults:
            return userDefaults.data(forKey: key)
        }
    }
    
    func remove(with key: String, from store: Store) {
        switch store {
        case .defaults:
            userDefaults.remove(for: key)
        }
    }
    
    func clear(_ store: Store) {
        switch store {
        case .defaults:
            userDefaults.clear()
        }
    }
}
