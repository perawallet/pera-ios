//
//  UserDefaults+Additions.swift

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
