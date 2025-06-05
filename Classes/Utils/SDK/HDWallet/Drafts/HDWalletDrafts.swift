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
//  HDWalletDrafts.swift

import Foundation
import x_hd_wallet_api

struct HDWalletDeriveChildNodeDraft {
    let extendedKey: Data
    let index: UInt32
    let derivationType: HDWalletDerivationType
}

struct HDWalletDeriveKeyDraft {
    let rootKey: Data
    let bip44Path: [UInt32]
    let isPrivate: Bool
    let derivationType: HDWalletDerivationType
}

struct HDWalletKeyGenDraft {
    let context: HDWalletKeyContext
    let account: UInt32
    let change: UInt32
    let keyIndex: UInt32
    let derivationType: HDWalletDerivationType
}

struct HDWalletSignAlgoTransactionDraft {
    let context: HDWalletKeyContext
    let account: UInt32
    let change: UInt32
    let keyIndex: UInt32
    let prefixEncodedTx: Data
    let derivationType: HDWalletDerivationType
}

struct HDWalletSignDataDraft {
    let context: HDWalletKeyContext
    let account: UInt32
    let change: UInt32
    let keyIndex: UInt32
    let data: Data
    let metadata: DataSigningMetadata
    let derivationType: HDWalletDerivationType
}

struct HDWalletVerifySignatureDraft {
    let signature: Data
    let message: Data
    let publicKey: Data
}

struct HDWalletECDHDraft {
    let context: HDWalletKeyContext
    let account: UInt32
    let change: UInt32
    let keyIndex: UInt32
    let otherPartyPub: Data
    let meFirst: Bool
    let derivationType: HDWalletDerivationType
} 

struct DataSigningMetadata {
    let encoding: Encoding
    let schema: String
}
