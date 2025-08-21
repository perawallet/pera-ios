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

import Foundation
import CryptoKit

<<<<<<<< HEAD:PeraWalletCore/LiquidAuth/Data/PassKeyAuthenticationResponse.swift
public struct PassKeyAuthenticationResponse {
    public let credentialId: String
    public let address: String
    public let keyPair: P256.Signing.PrivateKey
========
public struct AccountAssetFetchDraft {
    public let publicKey: PublicKey
    public let assetID: AssetID
    
    public init(publicKey: PublicKey, assetID: AssetID) {
        self.publicKey = publicKey
        self.assetID = assetID
    }
>>>>>>>> main:PeraWalletCore/API/Drafts/Account/AccountAssetFetchDraft.swift
}

