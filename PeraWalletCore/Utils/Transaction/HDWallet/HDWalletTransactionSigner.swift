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

//   HDWalletTransactionSigner.swift

import Foundation

public final class HDWalletTransactionSigner: HDWalletTransactionSignable {
    internal var sdk: HDWalletSDK?
    
    private let wallet: HDWalletSeed
    
    public init(wallet: HDWalletSeed) {
        self.wallet = wallet
        
        guard let seed = HDWalletUtils.generateSeed(fromEntropy: wallet.entropy),
              let sdk = HDWalletSDKImp(seed: seed.toHexString()) else {
            self.sdk = nil
            return
        }
        
        self.sdk = sdk
    }
}

// MARK: HDWalletTransactionSignable

extension HDWalletTransactionSigner {
    public func signTransaction(
        _ transaction: Data,
        with addressDetail: HDWalletAddressDetail
    ) throws -> Data {
        guard let sdk = sdk else {
            throw HDWalletError.invalidSeed
        }
        
        let draft = HDWalletSignAlgoTransactionDraft(
            context: .address,
            account: addressDetail.account,
            change: addressDetail.change,
            keyIndex: addressDetail.keyIndex,
            prefixEncodedTx: transaction,
            derivationType: addressDetail.derivationType
        )
        
        do {
            let signature = try sdk.signAlgorandTransaction(draft)
            return signature
        } catch {
            throw HDWalletError.sdkError(error.localizedDescription)
        }
    }
    
    public func signData(
        _ data: Data,
        with addressDetail: HDWalletAddressDetail
    ) throws -> Data {
        guard let sdk = sdk else {
            throw HDWalletError.invalidSeed
        }
        
        let draft = HDWalletSignDataDraft(
            context: .address,
            account: addressDetail.account,
            change: addressDetail.change,
            keyIndex: addressDetail.keyIndex,
            data: data,
            metadata: DataSigningMetadata(encoding: .base64, schema: "msgSchema.json"),
            derivationType: addressDetail.derivationType
        )
        
        do {
            let signature = try sdk.signData(draft)
            return signature
        } catch {
            throw HDWalletError.sdkError(error.localizedDescription)
        }
    }
    
    public func signTransactions(
        _ transactions: [Data],
        with addressDetail: HDWalletAddressDetail
    ) throws -> [Data] {
        try transactions.map { transaction in
            try signTransaction(
                transaction,
                with: addressDetail
            )
        }
    }
    
    public func verifySignature(
        _ signature: Data,
        message: Data,
        publicKey: Data
    ) -> Bool {
        guard let sdk else { return false }
        
        let draft = HDWalletVerifySignatureDraft(
            signature: signature,
            message: message,
            publicKey: publicKey
        )
        
        return sdk.verifySignature(draft)
    }
}
