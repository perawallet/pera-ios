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
        return KeychainAccess.Keychain(service: privateStorageKey).accessibility(.whenUnlocked)
    }
    
    init() {
        
    }
    
    // MARK: - Setting Private Key in Keychain
    func savePrivate(_ data: Data,
                     forAccount account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.set(data, for: dataKey)
    }
    
    func privateData(forAccount account: String) -> Data? {
        let dataKey = privateKey.appending(".\(account)")
        return privateStorage.data(for: dataKey)
    }
}
