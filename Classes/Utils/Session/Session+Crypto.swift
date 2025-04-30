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
//  Session+Crypto.swift

import Foundation
import UIKit

extension Session {
    func mnemonics(forAccount account: String) -> [String] {
        guard let privateKey = privateData(for: account) else {
            return []
        }
        
        var error: NSError?
        let mnemonics = algorandSDK.mnemonicFrom(privateKey, error: &error)
        
        guard error == nil else {
            return []
        }
        
        return mnemonics.components(separatedBy: " ")
    }
    
    func privateKey(forMnemonics mnemonics: String) -> Data? {
        var error: NSError?
        let data = algorandSDK.privateKeyFrom(mnemonics, error: &error)
        
        guard let privateKey = data,
            error == nil else {
            return nil
        }
        
        return privateKey
    }
    
    func address(for account: String) -> String? {
        guard let privateKey = privateData(for: account) else {
            return nil
        }
        
        return address(fromPrivateKey: privateKey)
    }
    
    func address(fromPrivateKey privateKey: Data) -> String? {
        var error: NSError?
        let address = algorandSDK.addressFrom(privateKey, error: &error)
        
        guard error == nil else {
            return nil
        }
        
        return address
    }
    
    func generatePrivateKey() -> Data? {
        return algorandSDK.generatePrivateKey()
    }
}


extension Session {
    
    /// Generates a BIP39 mnemonic phrase for a given address.
    ///
    /// This function creates a 256-bit entropy, generates a mnemonic phrase from it,
    /// and then stores the corresponding private key (entropy) associated with the provided address.
    ///
    /// - Parameter address: The address for which the mnemonic phrase is generated.
    ///
    /// - Returns: An array of strings representing the BIP39 mnemonic phrase. If mnemonic generation fails,
    ///           an empty array is returned.
    ///
    /// - Note: The generated mnemonic is stored securely in association with the address.
    ///
    /// Example:
    /// ```
    /// let mnemonic = makeMnemonicsBIP39(forAddress: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789012345")
    /// ```
    func makeMnemonicsBIP39(forAddress address: String) -> [String] {
        do {
            let entropy = HDWalletUtils.generate256BitEntropy()

            guard
                let mnemonic = HDWalletUtils.generateMnemonic(fromEntropy: entropy)
            else {
                throw MnemonicsError.missingWords
            }

            savePrivate(entropy, for: address)
            
            return mnemonic.components(separatedBy: " ")
        } catch {
            assertionFailure("Failed to generate mnemonic: \(error)")
            return []
        }
    }
}
