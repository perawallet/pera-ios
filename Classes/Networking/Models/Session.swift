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
    
    private let privateStorageKey = "com.algorand.algorand.token.private"
    private let privateKey = "com.algorand.algorand.token.private.key"
    
    private var privateStorage: KeychainAccess.Keychain {
        return KeychainAccess.Keychain(service: privateStorageKey).accessibility(.whenUnlocked)
    }
    
    var authenticatedUser: User? {
        didSet {
            guard let user = authenticatedUser,
                let data = user.encoded() else {
                return
            }
            
            save(data, for: StorableKeys.authenticatedUser.rawValue, to: .defaults)
        }
    }
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isExpired = true
    
    init() {
        awakeAuthenticatedUser()
    }
    
    private func awakeAuthenticatedUser() {
        guard let userData = data(with: StorableKeys.authenticatedUser.rawValue, to: .defaults) else {
            return
        }
        
        authenticatedUser = try? JSONDecoder().decode(User.self, from: userData)
    }
}

// MARK: - App Password
extension Session {
    func saveApp(password: String) {
        self.save(password, for: StoreKeys.appPassword.rawValue, to: .defaults)
    }
    
    func isPasswordMatching(with password: String) -> Bool {
        if let savedPassword = self.string(with: StoreKeys.appPassword.rawValue, to: .defaults) {
            return savedPassword == password
        }
        return false
    }
    
    func hasPassword() -> Bool {
        return self.string(with: StoreKeys.appPassword.rawValue, to: .defaults) != nil
    }
}

// MARK: - Setting Private Key in Keychain
extension Session {
    func savePrivate(_ data: Data,
                     forAccount account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.set(data, for: dataKey)
    }
    
    func privateData(forAccount account: String) -> Data? {
        let dataKey = privateKey.appending(".\(account)")
        return privateStorage.data(for: dataKey)
    }
    
    func removePrivateData(for account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.remove(for: dataKey)
    }
}

// MARK: - Common Methods
extension Session {
    func reset() {
        self.remove(with: StoreKeys.appPassword.rawValue, from: .defaults)
        try? privateStorage.removeAll()
        self.clear(.defaults)
        self.clear(.keychain)
        self.authenticatedUser = nil
        self.isExpired = true
    }
}
