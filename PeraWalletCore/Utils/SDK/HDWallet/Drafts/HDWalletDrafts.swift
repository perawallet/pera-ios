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

public struct HDWalletDeriveChildNodeDraft {
    public let extendedKey: Data
    public let index: UInt32
    public let derivationType: HDWalletDerivationType
}

public struct HDWalletDeriveKeyDraft {
    public let rootKey: Data
    public let bip44Path: [UInt32]
    public let isPrivate: Bool
    public let derivationType: HDWalletDerivationType
}

public struct HDWalletKeyGenDraft {
    public let context: HDWalletKeyContext
    public let account: UInt32
    public let change: UInt32
    public let keyIndex: UInt32
    public let derivationType: HDWalletDerivationType
}

public struct HDWalletSignAlgoTransactionDraft {
    public let context: HDWalletKeyContext
    public let account: UInt32
    public let change: UInt32
    public let keyIndex: UInt32
    public let prefixEncodedTx: Data
    public let derivationType: HDWalletDerivationType
}

public struct HDWalletSignDataDraft {
    public let context: HDWalletKeyContext
    public let account: UInt32
    public let change: UInt32
    public let keyIndex: UInt32
    public let data: Data
    public let metadata: DataSigningMetadata
    public let derivationType: HDWalletDerivationType
}

public struct HDWalletVerifySignatureDraft {
    public let signature: Data
    public let message: Data
    public let publicKey: Data
}

public struct HDWalletECDHDraft {
    public let context: HDWalletKeyContext
    public let account: UInt32
    public let change: UInt32
    public let keyIndex: UInt32
    public let otherPartyPub: Data
    public let meFirst: Bool
    public let derivationType: HDWalletDerivationType
}

public struct DataSigningMetadata {
    public let encoding: Encoding
    public let schema: String
}
