//
//  Session.swift
//  algorand
//
//  Created by Omer Emre Aslan on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import KeychainAccess

class Session: Storable {
    typealias Object = Any
    
    private let privateStorageKey = "com.algorand.token.private"
    private let privateKey = "com.algorand.token.private.key"
    
    private var privateStorage: KeychainAccess.Keychain {
        return KeychainAccess.Keychain(
            service: privateStorageKey)
            .accessibility(.whenUnlocked)
    }
    
    init() {
        
    }
    
    // MARK: - Setting Private Key in Keychain
    func savePrivate(_ data: Data) {
        privateStorage.set(data, for: privateKey)
    }
    
    func privateData() -> Data? {
        return privateStorage.data(for: privateKey)
    }
}
