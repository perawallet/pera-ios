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
//  HDWalletSDK.swift

import Foundation
import x_hd_wallet_api

protocol HDWalletSDK {
    /// Initializes the wallet with a seed
    /// - Parameter seed: The seed to initialize the wallet
    /// - Returns: An instance of the wallet, or `nil` if initialization fails
    init?(seed: String)
    
    /// Derives a public child node
    /// - Parameter draft: The draft containing details for derivation
    /// - Returns: The derived public child node data
    /// - Throws: An error if the derivation fails
    func derivePublicChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data
    
    /// Derives a private child node
    /// - Parameter draft: The draft containing details for derivation
    /// - Returns: The derived private child node data
    /// - Throws: An error if the derivation fails
    func derivePrivateChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data
    
    /// Derives a key
    /// - Parameter draft: The draft containing details for key derivation
    /// - Returns: The derived key data
    /// - Throws: An error if the key derivation fails
    func deriveKey(_ draft: HDWalletDeriveKeyDraft) throws -> Data
    
    /// Generates a key
    /// - Parameter draft: The draft containing details for key generation
    /// - Returns: The generated key data
    /// - Throws: An error if key generation fails
    func generateKey(_ draft: HDWalletKeyGenDraft) throws -> Data
    
    func signAlgorandTransaction(_ draft: HDWalletSignAlgoTransactionDraft) throws -> Data
    func signData(_ draft: HDWalletSignDataDraft) throws -> Data
    func verifySignature(_ draft: HDWalletVerifySignatureDraft) -> Bool
    func validateData(_ data: Data, against metadata: SignMetadata) throws -> Bool
    func performECDH(_ draft: HDWalletECDHDraft) throws -> Data
}
