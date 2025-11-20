// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   LegacyBridgeAccountManager.swift

import pera_wallet_core

enum LegacyBridgeAccountManager {
    
    enum ManagerError: Error {
        case unableToCreateUniversalWallet
        case unableToCreateLocalAccount
    }
    
    static func createUniversalWalletAccount(hdWalletService: HDWalletServicing, session: Session?, hdWalletStorage: HDWalletStorable,
                                             sharedDataController: SharedDataController, pushNotificationController: PushNotificationController) throws(ManagerError) -> AccountInformation {
        
        let (hdWalletAddressDetail, address) = hdWalletService.saveHDWalletAndComposeHDWalletAddressDetail(
            session: session,
            storage: hdWalletStorage,
            entropy: nil
        )
        
        guard let hdWalletAddressDetail, let address else { throw .unableToCreateUniversalWallet }
        
        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false,
            hdWalletAddressDetail: hdWalletAddressDetail
        )
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }
        session?.authenticatedUser?.setWalletName(for: hdWalletAddressDetail.walletId)

        return account
    }
    
    static func createUniversalWalletAccount(legacyConfiguration: ViewControllerConfiguration, pushNotificationController: PushNotificationController) throws(ManagerError) -> AccountInformation {
        try createUniversalWalletAccount(
            hdWalletService: legacyConfiguration.hdWalletService,
            session: legacyConfiguration.session,
            hdWalletStorage: legacyConfiguration.hdWalletStorage,
            sharedDataController: legacyConfiguration.sharedDataController,
            pushNotificationController: pushNotificationController
        )
    }
    
    static func addLocalAccount(session: Session, sharedDataController: SharedDataController, address: String, name: String, isWatchAccount: Bool, participants: [String]) throws(ManagerError) {
        guard let authenticatedUser = session.authenticatedUser else { throw .unableToCreateLocalAccount }
        let accountInformation = AccountInformation(address: address, name: name, isWatchAccount: isWatchAccount, preferredOrder: sharedDataController.getPreferredOrderForNewAccount(), isBackedUp: false, jointAccountParticipants: participants)
        authenticatedUser.addAccount(accountInformation)
    }
    
    static func createAlgo25Account(session: Session, pushNotificationController: PushNotificationController) -> AccountInformation? {
        
        let tempKey = "temp"
        
        guard let privateKey = session.generatePrivateKey() else { return nil }
        session.savePrivate(privateKey, for: tempKey)
        guard let address = session.address(for: tempKey) else { return nil }
        
        let account = AccountInformation(address: address, name: address.shortAddressDisplay, isWatchAccount: false, isBackedUp: false)
        
        session.savePrivate(privateKey, for: address)
        session.removePrivateData(for: tempKey)
        
        if let authenticatedUser = session.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session.authenticatedUser = user
        }
        
        return account
    }
}
