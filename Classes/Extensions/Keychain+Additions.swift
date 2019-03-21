//
//  Keychain+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import KeychainAccess

extension KeychainAccess.Keychain {
    
    func clear() {
        try? self.removeAll()
    }
    
    func remove(for key: String) {
        try? self.remove(key)
    }
    
    func data(for key: String) -> Data? {
        guard let data = try? self.getData(key) else {
            return nil
        }
        
        return data
    }
    
    func set(_ data: Data?, for key: String) {
        guard let data = data else {
            return
        }
        
        try? self.set(data, key: key)
    }
    
    func string(for key: String) -> String? {
        do {
            return try self.getString(key)
        } catch {
            return nil
        }
    }
    
    func set(_ string: String?, for key: String) {
        guard let value = string else {
            return
        }
        
        do {
            try self.set(value, key: key)
        } catch {
            return
        }
    }
}
