// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   HDWalletServicing.swift

import Foundation
import MnemonicSwift
import x_hd_wallet_api

protocol HDWalletServicing {
    /// Generates a new 24-word mnemonic phrase
    /// - Returns: The generated mnemonic phrase
    func generateMnemonic() throws -> String
    
    /// Creates a new HD wallet from a entropy
    /// - Parameters:
    ///   - entropy: The entropy to use
    /// - Returns: The created HD wallet
    func createWallet(
        from entropy: Data
    ) throws -> HDWalletSeed
    
    /// Generates a new address for a wallet
    /// - Parameters:
    ///   - wallet: The wallet to generate the address for
    ///   - accountIndex: The account index of the address to generate
    /// - Returns: The generated address
    func generateAddress(
        for wallet: HDWalletSeed,
        at accountIndex: UInt32
    ) throws -> HDWalletAddress
    
    /// Imports a recovered address for a wallet
    /// - Parameters:
    ///   - wallet: The wallet to generate the address for
    ///   - recoveredAddress: The recoveredAddress object
    /// - Returns: The generated address
    func importAddress(
        _ recoveredAddress: RecoveredAddress,
        for wallet: HDWalletSeed
    ) throws -> HDWalletAddress
    
    /// Saves the generated HDWallet and generates a HDWalletAddressDetail instance
    /// - Parameters:
    ///   - session: The session to retrieve the mnemonics
    ///   - storage: The storage that the wallet will be stored
    /// - Returns: HDWalletAddressDetail instance and the Address created to store in the AccountInformation object
    func saveHDWalletAndComposeHDWalletAddressDetail(
        session: Session?,
        storage: HDWalletStorable,
        entropy: Data?
    ) -> (HDWalletAddressDetail?, String?)
    
    /// Creates HDWalletAddressDetail for a new address in an existing HD Wallet
    /// - Parameters:
    ///   - hdWallet: The existing wallet
    ///   - accountIndex: index for the new address
    /// - Returns: HDWalletAddressDetail instance to store in the AccountInformation object
    func createAddressDetail(
        for hdWallet: HDWalletInfoViewModel,
        in accountIndex: UInt32
    ) -> HDWalletAddressDetail
    
    
    /// Recovers the accounts to a hd wallet using the mnemonic
    /// - Parameters:
    ///   - mnemonic: The mnemonic to retrive the wallet
    ///   - api: The api instance to retrive the account fast lookup information
    /// - Returns: HDWalletAddressDetail instance to store in the AccountInformation object
    func recoverAccounts(
        fromMnemonic mnemonic: String,
        api: ALGAPI?
    ) async throws -> [RecoverResult]
    
    /// Retrives the fast lookup information for an address
    /// - Parameters:
    ///   - address: The address to retrive the fast lookup information
    ///   - api: The api instance to retrive the account fast lookup information
    /// - Returns: AccountFastLookup instance with all the relevant information
    func fastLookupAccount(
        address: String,
        api: ALGAPI
    ) async -> AccountFastLookup?
}
