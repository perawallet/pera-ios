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
        get {
            return applicationConfiguration?.authenticatedUser()
        }
        
        set {
            guard let userData = newValue?.encoded() else {
                return
            }
            
            if let config = applicationConfiguration {
                config.update(entity: ApplicationConfiguration.entityName,
                              with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData])
            } else {
                ApplicationConfiguration.create(entity: ApplicationConfiguration.entityName,
                                                with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData])
            }
            
            Cache.configuration = nil
            Cache.configuration = applicationConfiguration
            
            NotificationCenter.default.post(
                name: Notification.Name.AuthenticatedUserUpdate,
                object: self,
                userInfo: nil
            )
        }
    }
    
    enum Cache {
        static var configuration: ApplicationConfiguration?
    }
    
    var applicationConfiguration: ApplicationConfiguration? {
        get {
            if Cache.configuration == nil {
                let entityName = ApplicationConfiguration.entityName
                guard ApplicationConfiguration.hasResult(entity: entityName) else {
                    return nil
                }
                
                let result = ApplicationConfiguration.fetchAllSyncronous(entity: entityName)
                
                switch result {
                case .result(let object):
                    guard let configuration = object as? ApplicationConfiguration else {
                        return nil
                    }
                    
                    Cache.configuration = configuration
                    
                    return Cache.configuration
                    
                case .results(let objects):
                    guard let configuration = objects.first(where: { appConfig -> Bool in
                        if appConfig is ApplicationConfiguration {
                            return true
                        }
                        return false
                    }) as? ApplicationConfiguration else {
                        return nil
                    }
                    
                    Cache.configuration = configuration
                    
                    return Cache.configuration
                case .error:
                    return nil
                }
            }
            
            return Cache.configuration
        }
        
        set {
            Cache.configuration = newValue
        }
    }
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isValid = false
}

// MARK: - App Password
extension Session {
    func saveApp(password: String) {
        if let config = applicationConfiguration {
            config.update(entity: ApplicationConfiguration.entityName,
                          with: [ApplicationConfiguration.DBKeys.password.rawValue: password])
        } else {
            ApplicationConfiguration.create(entity: ApplicationConfiguration.entityName,
                                            with: [ApplicationConfiguration.DBKeys.password.rawValue: password])
        }
    }
    
    func isPasswordMatching(with password: String) -> Bool {
        guard let config = applicationConfiguration else {
            return false
        }

        return config.password == password
    }
    
    func hasPassword() -> Bool {
        guard let config = applicationConfiguration else {
            return false
        }
        
        return config.password != nil
    }
    
    func isDefaultNodeActive() -> Bool {
        guard let config = applicationConfiguration else {
            return false
        }
        
        return config.isDefaultNodeActive
    }
    
    func setDefaultNodeActive(_ isActive: Bool) {
        if let config = applicationConfiguration {
            config.update(entity: ApplicationConfiguration.entityName,
                          with: [ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: NSNumber(value: isActive)])
        }
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
        applicationConfiguration = nil
        ApplicationConfiguration.clear(entity: ApplicationConfiguration.entityName)
        Contact.clear(entity: Contact.entityName)
        Node.clear(entity: Node.entityName)
        try? privateStorage.removeAll()
        self.clear(.defaults)
        self.clear(.keychain)
        self.isValid = false
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.invalidateAccountManagerFetchPolling()
        }
    }
}
