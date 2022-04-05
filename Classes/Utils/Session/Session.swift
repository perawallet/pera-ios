// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Session.swift

import Foundation
import KeychainAccess
import MacaroonUtils
import MagpieCore
import UIKit
import SwiftDate

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
    private let currencyPreferenceKey = "com.algorand.algorand.currency.preference"
    private let userInterfacePrefenceKey = "com.algorand.algorand.interface.preference"
    private let announcementStateKey = "com.algorand.algorand.announcement.state"
    
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
    
    var userInterfaceStyle: UserInterfaceStyle {
        get {
            guard let appearance = string(with: userInterfacePrefenceKey, to: .defaults),
                let appearancePreference = UserInterfaceStyle(rawValue: appearance) else {
                    return .system
            }
            return appearancePreference
        }
        set {
            self.save(newValue.rawValue, for: userInterfacePrefenceKey, to: .defaults)
        }
    }
    
    var preferredCurrency: String {
        get {
            return string(with: currencyPreferenceKey, to: .defaults) ?? "ALGO"
        }
        set {
            save(newValue, for: currencyPreferenceKey, to: .defaults)
        }
    }

    var preferredCurrencyDetails: Currency?
    
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

    var announcementStates: [String: AnnouncementMetadata] {
        get {
            guard let data = data(with: announcementStateKey, to: .defaults) else {
                return [:]
            }

            do {
                return try [String: AnnouncementMetadata].decoded(data, using: JSONDecodingStrategy())
            } catch {
                return [:]
            }
        }
        set {
            do {
                let data = try newValue.encoded()
                save(data, for: announcementStateKey, to: .defaults)
            } catch {
                return
            }
        }
    }
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isValid = false

    init() {
        removeOldTermsAndServicesKeysFromDefaults()
    }
}

extension Session {
    func hasAuthentication() -> Bool {
        return authenticatedUser != nil
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
    
    func deletePassword() {
        if let config = applicationConfiguration {
            config.removeValue(entity: ApplicationConfiguration.entityName, with: ApplicationConfiguration.DBKeys.password.rawValue)
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
    }
}

extension Session {
    func accountInformation(from address: String) -> AccountInformation? {
        return applicationConfiguration?.authenticatedUser()?.accounts.first { account -> Bool in
            account.address == address
        }
    }

    func createUser(with accounts: [AccountInformation] = []) {
        authenticatedUser = User(accounts: accounts)
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
    /// <todo> Remove this check in other releases later when the v2 is accepted.
    private func removeOldTermsAndServicesKeysFromDefaults() {
        userDefaults.remove(for: termsAndServicesKey)
        userDefaults.remove(for: termsAndServicesKeyV2)
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
    func reset(
        includingContacts: Bool
    ) {
        authenticatedUser = nil
        applicationConfiguration = nil

        ApplicationConfiguration.clear(entity: ApplicationConfiguration.entityName)
        
        if includingContacts {
            Contact.clear(entity: Contact.entityName)
        }
        
        Node.clear(entity: Node.entityName)

        /// <todo>
        /// Why does it more than one keychain?
        privateStorage.clear()
        
        clear(.defaults)
        clear(.keychain)

        self.isValid = false
    }
}

extension Session {
    private enum Cache {
        static var configuration: ApplicationConfiguration?
    }
}
