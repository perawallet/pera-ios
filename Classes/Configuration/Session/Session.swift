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
    private let rewardsPrefenceKey = "com.algorand.algorand.rewards.preference"
    /// <todo> Remove this key in other releases later when the v2 is accepted.
    private let termsAndServicesKey = "com.algorand.algorand.terms.services"
    private let termsAndServicesKeyV2 = "com.algorand.algorand.terms.services.v2"
    private let accountsQRTooltipKey = "com.algorand.algorand.accounts.qr.tooltip"
    private let notificationLatestTimestamp = "com.algorand.algorand.notification.latest.timestamp"
    
    let algorandSDK = AlgorandSDK()
    
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
                config.update(
                    entity: ApplicationConfiguration.entityName,
                    with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData]
                )
            } else {
                ApplicationConfiguration.create(
                    entity: ApplicationConfiguration.entityName,
                    with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData]
                )
            }
            
            Cache.configuration = nil
            Cache.configuration = applicationConfiguration
            NotificationCenter.default.post(name: .AuthenticatedUserUpdate, object: self, userInfo: nil)
        }
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
    
    var rewardDisplayPreference: RewardPreference {
        get {
            guard let rewardPreference = string(with: rewardsPrefenceKey, to: .defaults),
                let rewardDisplayPreference = RewardPreference(rawValue: rewardPreference) else {
                    return .allowed
            }
            return rewardDisplayPreference
        }
        set {
            self.save(newValue.rawValue, for: rewardsPrefenceKey, to: .defaults)
        }
    }
    
    var notificationLatestFetchTimestamp: TimeInterval? {
        get {
            return userDefaults.double(forKey: notificationLatestTimestamp)
        }
        set {
            if let timestamp = newValue {
                userDefaults.set(timestamp, forKey: notificationLatestTimestamp)
            }
        }
    }
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isValid = false
    
    var verifiedAssets: [VerifiedAsset]?
    
    var assetDetails: [Int64: AssetDetail] = [:]
    
    var accounts = [Account]()
    
    init() {
        removeOldTermsAndServicesKeyFromDefaults()
    }
}

extension Session {
    enum RewardPreference: String {
        case allowed = "allowed"
        case disabled = "disabled"
    }
}

extension Session {
    func savePassword(_ password: String) {
        if let config = applicationConfiguration {
            config.update(entity: ApplicationConfiguration.entityName, with: [ApplicationConfiguration.DBKeys.password.rawValue: password])
        } else {
            ApplicationConfiguration.create(
                entity: ApplicationConfiguration.entityName,
                with: [ApplicationConfiguration.DBKeys.password.rawValue: password]
            )
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
            return true
        }
        return config.isDefaultNodeActive
    }
    
    func setDefaultNodeActive(_ isActive: Bool) {
        if let config = applicationConfiguration {
            config.update(
                entity: ApplicationConfiguration.entityName,
                with: [ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: NSNumber(value: isActive)]
            )
        }
    }
    
    func updateName(_ name: String, for accountAddress: String) {
        guard let accountInformation = authenticatedUser?.account(address: accountAddress) else {
            return
        }
        accountInformation.updateName(name)
        authenticatedUser?.updateAccount(accountInformation)
        
        guard let account = account(from: accountAddress),
            let index = index(of: account) else {
            return
        }
        
        account.name = name
        accounts[index] = account
    }
}

extension Session {
    func account(from accountInformation: AccountInformation) -> Account? {
        return accounts.first { account -> Bool in
            account.address == accountInformation.address
        }
    }
    
    func account(from address: String) -> Account? {
        return accounts.first { account -> Bool in
            account.address == address
        }
    }
    
    func accountInformation(from address: String) -> AccountInformation? {
        return applicationConfiguration?.authenticatedUser()?.accounts.first { account -> Bool in
            account.address == address
        }
    }
    
    func index(of account: Account) -> Int? {
        guard let index = accounts.firstIndex(of: account) else {
            return nil
        }
        return index
    }
    
    func addAccount(_ account: Account) {
        guard let index = index(of: account) else {
            accounts.append(account)
            NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": account])
            return
        }
        
        accounts[index].update(with: account)
        NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": accounts[index]])
    }
    
    func updateAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts[index].update(with: account)
        NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": accounts[index]])
    }
    
    func removeAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts.remove(at: index)
        NotificationCenter.default.post(name: .AccountUpdate, object: self)
    }
    
    func canSignTransaction(for selectedAccount: inout Account) -> Bool {
        /// Check whether auth address exists for the selected account.
        if let authAccountAddress = selectedAccount.authAddress {
            if let authAccount = accounts.first(where: { account -> Bool in
                authAccountAddress == account.address
            }) {
                selectedAccount.ledgerDetail = authAccount.ledgerDetail
                return true
            }
            
            NotificationBanner.showError(
                "title-error".localized,
                message: "ledger-rekey-error-add-auth".localized(params: authAccountAddress.shortAddressDisplay())
            )
            return false
        }
        
        /// Check whether ledger details of the selected ledger account exists.
        if selectedAccount.isLedger() {
            if selectedAccount.ledgerDetail == nil {
                NotificationBanner.showError("title-error".localized, message: "ledger-rekey-error-not-found".localized)
                return false
            }
            return true
        }
        
        /// Check whether private key of the selected account exists.
        if privateData(for: selectedAccount.address) == nil {
            NotificationBanner.showError("title-error".localized, message: "ledger-rekey-error-not-found".localized)
            return false
        }
        
        return true
    }
}

extension Session {
    func savePrivate(_ data: Data, for account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.set(data, for: dataKey)
    }
    
    func privateData(for account: String) -> Data? {
        let dataKey = privateKey.appending(".\(account)")
        return privateStorage.data(for: dataKey)
    }
    
    func removePrivateData(for account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.remove(for: dataKey)
    }
}

// MARK: Terms and Services
extension Session {
    func acceptTermsAndServices() {
        save(true, for: termsAndServicesKeyV2, to: .defaults)
    }
    
    func isTermsAndServicesAccepted() -> Bool {
        return bool(with: termsAndServicesKeyV2, to: .defaults)
    }
    
    /// <todo> Remove this check in other releases later when the v2 is accepted.
    private func removeOldTermsAndServicesKeyFromDefaults() {
        let isOldTermsAndServicesAccepted = bool(with: termsAndServicesKey, to: .defaults)
        if isOldTermsAndServicesAccepted {
            userDefaults.remove(for: termsAndServicesKey)
        }
    }
}

extension Session {
    func setAccountQRTooltipDisplayed() {
        save(true, for: accountsQRTooltipKey, to: .defaults)
    }
    
    func isAccountQRTooltipDisplayed() -> Bool {
        return bool(with: accountsQRTooltipKey, to: .defaults)
    }
}

extension Session {
    func reset(isContactIncluded: Bool) {
        let termsAndServicesAccepted = isTermsAndServicesAccepted()
        
        authenticatedUser = nil
        accounts.removeAll()
        applicationConfiguration = nil
        ApplicationConfiguration.clear(entity: ApplicationConfiguration.entityName)
        
        if isContactIncluded {
            Contact.clear(entity: Contact.entityName)
        }
        
        Node.clear(entity: Node.entityName)
        try? privateStorage.removeAll()
        self.clear(.defaults)
        self.clear(.keychain)
        self.isValid = false
        
        if termsAndServicesAccepted {
            acceptTermsAndServices()
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.invalidateAccountManagerFetchPolling()
        }
    }
}

extension Session {
    private enum Cache {
        static var configuration: ApplicationConfiguration?
    }
}
