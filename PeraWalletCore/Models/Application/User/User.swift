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

//
//  User.swift

import UIKit

public final class User: Codable {

    // Stores accounts that represent regular accounts or HD wallet addresses. The ones that represent HD wallet addresses will have the hdWalletAddressDetail
    public private(set) var accounts: [AccountInformation] = []
    
    // Default node used to interact with the blockchain
    private(set) var defaultNode: String?

    // Device IDs for mainnet and testnet, used for identification purposes
    private var deviceIDOnMainnet: String?
    private var deviceIDOnTestnet: String?
    
    private var walletNames: [String: String] = [:]
    
    // Keys used for encoding and decoding data
    private enum CodingKeys:
        String,
        CodingKey {
        case accounts
        case walletNames
        case defaultNode
        case legacyDeviceID = "deviceId"
        case deviceIDOnMainnet
        case deviceIDOnTestnet
    }
    public init() {}

    public init(
        accounts: [AccountInformation]
    ) {
        self.accounts = accounts
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accounts = try container.decodeIfPresent([AccountInformation].self, forKey: .accounts) ?? []
        
        self.walletNames = try container.decodeIfPresent([String: String].self, forKey: .walletNames) ?? [:]
        let defaultNode = try container.decodeIfPresent(String.self, forKey: .defaultNode)
        self.defaultNode = defaultNode
        
        let legacyDeviceID = try container.decodeIfPresent(String.self, forKey: .legacyDeviceID)
        let network = User.makeNetwork(from: defaultNode)
        
        if let deviceID = try container.decodeIfPresent(String.self, forKey: .deviceIDOnMainnet) {
            self.deviceIDOnMainnet = deviceID
        } else if network == .mainnet {
            self.deviceIDOnMainnet = legacyDeviceID
        }
        
        if let deviceID = try container.decodeIfPresent(String.self, forKey: .deviceIDOnTestnet) {
            self.deviceIDOnTestnet = deviceID
        } else if network == .testnet {
            self.deviceIDOnTestnet = legacyDeviceID
        }
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encode(walletNames, forKey: .walletNames)
        try container.encodeIfPresent(defaultNode, forKey: .defaultNode)
        try container.encodeIfPresent(deviceIDOnMainnet, forKey: .deviceIDOnMainnet)
        try container.encodeIfPresent(deviceIDOnTestnet, forKey: .deviceIDOnTestnet)
    }
    
    public func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

public struct HDWalletInfoViewModel: Equatable {
    public let walletId: String
    public let walletName: String
    
    public var walletOrderNumber: Int {
        Int(walletName.split(separator: "#").last ?? "") ?? 0
    }
}

extension User {
    // Returns true if the account limit (50) is reached
    public var hasReachedTotalAccountLimit: Bool {
        let limit = 50
        return accounts.count == limit
    }
    
    // Retrieves all accounts that belong to HD Wallets
    public var hdWalletsAccounts: [AccountInformation] {
        accounts.filter { $0.hdWalletAddressDetail != nil }
    }
    
    // Returns true if there the user has any HD Wallet
    public var hasHDWalletsAccounts: Bool {
        !hdWalletsAccounts.isEmpty
    }
    
    // Retrieves an array of HDWalletInfoViewModel objects orderer by name
    public var hdWallets: [HDWalletInfoViewModel] {
        walletNames
            .map { HDWalletInfoViewModel(walletId: $0.key, walletName: $0.value) }
            .sorted { $0.walletName < $1.walletName }
    }
}

extension User {
    // Adds a new account to the User's account list
    public func addAccount(_ account: AccountInformation) {
        accounts.append(account)
        syncronize()
    }

    // Adds multiple accounts to the User's account list
    public func addAccounts(_ accounts: [AccountInformation]) {
        self.accounts.append(contentsOf: accounts)
        syncronize()
    }
    
    // Removes a specific account from the User's account list.
    // If it's an HDWallet removes the Keychain data for address, if it's the last account in a wallet, the wallet is also removed from Keychain.
    public func removeAccount(_ account: AccountInformation, storage: HDWalletStorable) {
        guard let index = index(of: account) else {
            return
        }
        
        removeBackup(from: account.address)
        accounts.remove(at: index)
        
        guard let hdWalletAddressDetail = account.hdWalletAddressDetail else {
            syncronize()
            return
        }
        
        do {
            try storage.deleteAddress(walletId: hdWalletAddressDetail.walletId, address: account.address)
            
            let walletId = hdWalletAddressDetail.walletId
            guard accounts(withWalletId: walletId).isEmpty else {
                syncronize()
                return
            }
            
            try storage.deleteWallet(id: walletId)
            removeWalletName(for: walletId)
        } catch {
            assertionFailure("Error deleting wallet and address from Keychain: \(error)")
        }
        
        syncronize()
    }
    
    // Returns the index of a given account in the accounts array, will return nil if account is not in the accounts array
    public func index(of account: AccountInformation) -> Int? {
        guard let index = accounts.firstIndex(of: account) else {
            return nil
        }
        
        return index
    }
    
    // Returns the index of an account by its address
    public func indexOfAccount(_ address: String) -> Int? {
        return accounts.firstIndex(where: { $0.address == address })
    }
    
    // Retrieves an account at a given index, will return nil if there isn't any account with the given index
    public func account(at index: Int) -> AccountInformation? {
        guard index < accounts.count else {
            return nil
        }
        
        return accounts[index]
    }
    
    // Updates the properties of an existing account
    public func updateAccount(_ account: AccountInformation) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts[index].updateName(account.name)
        accounts[index].type = account.type
        accounts[index].ledgerDetail = account.ledgerDetail
        accounts[index].receivesNotification = account.receivesNotification
        accounts[index].rekeyDetail = account.rekeyDetail
        accounts[index].preferredOrder = account.preferredOrder
        accounts[index].isBackedUp = account.isBackedUp
        accounts[index].hdWalletAddressDetail = account.hdWalletAddressDetail
        
        syncronize()
    }

    // Updates the properties of an existing account with the option to sync changes immediately if necessary
    public func updateLocalAccount(
        _ updatedAccount: Account,
        syncChangesImmediately: Bool = true
    ) {
        guard let localAccountIndex = indexOfAccount(updatedAccount.address) else {
            return
        }

        accounts[localAccountIndex].updateName(updatedAccount.name ?? "")
        
        if updatedAccount.isWatchAccount {
            accounts[localAccountIndex].type = .watch
        }
        
        accounts[localAccountIndex].ledgerDetail = updatedAccount.ledgerDetail
        accounts[localAccountIndex].receivesNotification = updatedAccount.receivesNotification
        accounts[localAccountIndex].rekeyDetail = updatedAccount.rekeyDetail
        accounts[localAccountIndex].preferredOrder = updatedAccount.preferredOrder
        accounts[localAccountIndex].isBackedUp = updatedAccount.isBackedUp
        accounts[localAccountIndex].hdWalletAddressDetail = updatedAccount.hdWalletAddressDetail

        if syncChangesImmediately {
            syncronize()
        }
    }

    // Synchronizes the current user data with the session
    public func syncronize() {
        guard CoreAppConfiguration.shared?.session.authenticatedUser != nil else {
            return
        }
        CoreAppConfiguration.shared?.session.authenticatedUser = self
    }
    
    // Sets the default node for blockchain interactions
    public func setDefaultNode(_ node: AlgorandNode?) {
        defaultNode = node?.network.rawValue
        syncronize()
    }
    
    // Returns the preferred network (mainnet or testnet) based on the default node
    public func preferredAlgorandNetwork() -> ALGAPI.Network? {
        User.makeNetwork(from: defaultNode)
    }
    
    // Retrieves an account by its address
    public func account(address: String) -> AccountInformation? {
        accountFrom(address: address)
    }
    
    // Retrieves all accounts that belong to the HDWallet with the given id
    public func accounts(withWalletId id: String) -> [AccountInformation] {
        accounts.filter { $0.hdWalletAddressDetail?.walletId == id }
    }
    
    // Retrieves an account by its HDWallet ID and address
    public func account(withWalletId id: String, andAddress address: String) -> AccountInformation? {
        accounts.filter { $0.hdWalletAddressDetail?.walletId == id && $0.address == address}.first
    }
}

extension User {
    // Retrieves the number of addresses for an HD Wallet
    public func addresses(forWalletId id: String) -> Int {
        accounts(withWalletId: id).count
    }

    // Retrieves the name of the wallet by its id
    public func walletName(for walletId: String) -> String? {
        walletNames[walletId]
    }
    
    // Generates and saves the name of a new wallet
    public func setWalletName(for walletId: String) {
        walletNames[walletId] = generateHDWalletName()
        syncronize()
    }
    
    // Generate the next available name for a new HD Wallet
    private func generateHDWalletName() -> String {
        let highestWalletNameNumber = walletNames.values
            .compactMap { name in
                name.components(separatedBy: "#")
                    .last?
                    .trimmingCharacters(in: .whitespaces)
            
            }
            .compactMap { Int($0) }
            .max() ?? 0
        return String(format: String(localized: "hd-wallet-setup-wallet-name"), "\(highestWalletNameNumber + 1)")
    }
    
    // Deletes the name of the wallet by its id
    public func removeWalletName(for walletId: String) {
        walletNames[walletId] = nil
        syncronize()
    }
    
    public func nextAccountIndex(forWalletId id: String) -> UInt32 {
        (accounts
            .compactMap { $0.hdWalletAddressDetail }
            .filter { $0.walletId == id }
            .map { $0.account }
            .max() ?? 0) + 1
    }
}

extension User {
    // Returns the account associated with a specific address
    private func accountFrom(address: String) -> AccountInformation? {
        return accounts.first { $0.address == address }
    }

    // Removes backup data associated with a specific account address
    private func removeBackup(from address: String) {
        if let session = CoreAppConfiguration.shared?.session {
            session.backups[address] = nil
        }
    }
}

extension User {
    // Retrieves the device ID based on the network (mainnet or testnet)
    public func getDeviceId(
        on network: ALGAPI.Network
    ) -> String? {
        switch network {
        case .mainnet: return deviceIDOnMainnet
        case .testnet: return deviceIDOnTestnet
        }
    }
    
    // Sets the device ID based on the network (mainnet or testnet)
    public func setDeviceID(
        _ deviceID: String?,
        on network: ALGAPI.Network
    ) {
        switch network {
        case .mainnet: deviceIDOnMainnet = deviceID
        case .testnet: deviceIDOnTestnet = deviceID
        }
        
        NotificationCenter.default.post(
            name: .DeviceIDDidSet,
            object: nil
        )

        syncronize()
    }
}

extension User {
    private static func makeNetwork(
        from rawValue: String?
    ) -> ALGAPI.Network? {
        return rawValue.unwrap(ALGAPI.Network.init(rawValue:))
    }
}
