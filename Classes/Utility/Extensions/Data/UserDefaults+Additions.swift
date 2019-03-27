//
//  UserDefaults+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func set(_ object: Any, for key: String) {
        set(object, forKey: key)
    }
    
    func remove(for key: String) {
        removeObject(forKey: key)
    }
    
    func clear() {
        let defaultsDictionary = dictionaryRepresentation()
        
        defaultsDictionary.keys.forEach { key in
            removeObject(forKey: key)
        }
    }
}
