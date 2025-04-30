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
//  HDWalletSDKImp.swift

import Foundation
import x_hd_wallet_api

final class HDWalletSDKImp: HDWalletSDK {
    private let api: XHDWalletAPI
    
    required init?(seed: String) {
        guard let api = XHDWalletAPI(seed: seed) else { return nil }
        self.api = api
    }
    
    func derivePublicChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        do {
            return try api.deriveChildNodePublic(
                extendedKey: draft.extendedKey,
                index: draft.index,
                g: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func derivePrivateChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        do {
            return try api.deriveChildNodePrivate(
                extendedKey: draft.extendedKey,
                index: draft.index,
                g: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func deriveKey(_ draft: HDWalletDeriveKeyDraft) throws -> Data {
        do {
            return try api.deriveKey(
                rootKey: api.fromSeed(draft.rootKey),
                bip44Path: draft.bip44Path,
                isPrivate: draft.isPrivate,
                derivationType: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func generateKey(_ draft: HDWalletKeyGenDraft) throws -> Data {
        do {
            return try api.keyGen(
                context: draft.context.toKeyContext,
                account: draft.account,
                change: draft.change,
                keyIndex: draft.keyIndex,
                derivationType: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func signAlgorandTransaction(_ draft: HDWalletSignAlgoTransactionDraft) throws -> Data {
        do {
            return try api.signAlgoTransaction(
                context: draft.context.toKeyContext,
                account: draft.account,
                change: draft.change,
                keyIndex: draft.keyIndex,
                prefixEncodedTx: draft.prefixEncodedTx,
                derivationType: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func signData(_ draft: HDWalletSignDataDraft) throws -> Data {
        do {
            return try api.signData(
                context: draft.context.toKeyContext,
                account: draft.account,
                change: draft.change,
                keyIndex: draft.keyIndex,
                data: draft.data,
                metadata: .init(encoding: draft.metadata.encoding, schema: Schema(filePath: draft.metadata.schema)),
                derivationType: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func verifySignature(_ draft: HDWalletVerifySignatureDraft) -> Bool {
        api.verifyWithPublicKey(
            signature: draft.signature,
            message: draft.message,
            publicKey: draft.publicKey
        )
    }
    
    func validateData(_ data: Data, against metadata: SignMetadata) throws -> Bool {
        do {
            return try api.validateData(data: data, metadata: metadata)
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
    
    func performECDH(_ draft: HDWalletECDHDraft) throws -> Data {
        do {
            return try api.ECDH(
                context: draft.context.toKeyContext,
                account: draft.account,
                change: draft.change,
                keyIndex: draft.keyIndex,
                otherPartyPub: draft.otherPartyPub,
                meFirst: draft.meFirst,
                derivationType: draft.derivationType.toBIP32DerivationType
            )
        } catch {
            throw HDWalletSDKError.sdkError(error.localizedDescription)
        }
    }
}
