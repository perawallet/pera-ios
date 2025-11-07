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

//   HDWalletStorage.swift

import Foundation
import KeychainAccess

public final class HDWalletStorage: HDWalletStorable {
    private let keychain: Keychain
    private let walletPrefix = "wallet."
    private let addressPrefix = "address."
    
    public init(
        keychain: Keychain = Keychain(service: "com.algorand.algorand.hdwallet")
    ) {
        self.keychain = keychain
    }
    
    public func save(wallet: HDWalletSeed) throws {
        let data = try JSONEncoder().encode(wallet)
        try keychain.set(
            data,
            key: walletKey(id: wallet.id)
        )
    }
    
    public func wallet(id: String) throws -> HDWalletSeed? {
        guard let data = try keychain.getData(walletKey(id: id)) else { return nil }
        return try JSONDecoder().decode(
            HDWalletSeed.self,
            from: data
        )
    }
    
    public func deleteWallet(id: String) throws {
        try keychain.remove(walletKey(id: id))
    }
    
    public func save(address: HDWalletAddress) throws {
        let data = try JSONEncoder().encode(address)
        let addressKey = addressKey(
            walletId: address.walletId,
            address: address.address
        )
        try keychain.set(
            data,
            key: addressKey
        )
    }
    
    public func address(
        walletId: String,
        address: String
    ) throws -> HDWalletAddress? {
        let addressKey = addressKey(
            walletId: walletId,
            address: address
        )
        guard let data = try keychain.getData(addressKey) else { return nil }
        
        return try JSONDecoder().decode(
            HDWalletAddress.self,
            from: data
        )
    }
    
    public func addresses(walletId: String) throws -> [HDWalletAddress] {
        let prefix = addressPrefix + walletId + "."
        let addresses = keychain.allKeys().filter { $0.hasPrefix(prefix) }.compactMap { key -> HDWalletAddress? in
            guard let data = try? keychain.getData(key) else { return nil }
            
            return try? JSONDecoder().decode(
                HDWalletAddress.self,
                from: data
            )
        }
        return addresses
    }
    
    public func deleteAddress(
        walletId: String,
        address: String
    ) throws {
        let addressKey = addressKey(
            walletId: walletId,
            address: address
        )
        try keychain.remove(addressKey)
    }
}

extension HDWalletStorage {
    private func walletKey(id: String) -> String {
        walletPrefix + id
    }
    
    private func addressKey(
        walletId: String,
        address: String
    ) -> String {
        addressPrefix + walletId + "." + address
    }
    
    public var allHDWalletKeys: [String] {
        keychain.allKeys()
    }
}
