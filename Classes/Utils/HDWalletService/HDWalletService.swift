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

//   HDWalletService.swift

import Foundation
import MnemonicSwift
import x_hd_wallet_api

final class HDWalletService: HDWalletServicing {
    private let algorandSDK = AlgorandSDK()
    private let sdk: HDWalletSDK?
    private var derivationType: HDWalletDerivationType = .peikert
    
    private static let wordCount = 24
    private static let gapLimit = 5
    
    init(sdk: HDWalletSDK? = nil, derivationType: HDWalletDerivationType = .peikert) {
        self.sdk = sdk
        self.derivationType = derivationType
    }
    
    // MARK: - BIP44 Path Components
    private static let bip44Purpose: UInt32 = 44
    private static let algorandCoinType: UInt32 = 283
    private static let accountIndex: UInt32 = 0
    private static let changeIndex: UInt32 = 0
    private static let addressIndex: UInt32 = 0
    
    func generateMnemonic() throws -> String {
        guard let mnemonic = try? Mnemonic.generateMnemonic(strength: 256) else {
            throw HDWalletError.entropyGenerationFailed
        }
        return mnemonic
    }
    
    func createWallet(
        from entropy: Data
    ) throws -> HDWalletSeed {
        
        // Validate entropy length (should be 32 bytes for BIP39)
        guard entropy.count == 32 else {
            throw HDWalletError.invalidEntropy
        }
        
        return HDWalletSeed(entropy: entropy)
    }
    
    func generateAddress(
        for wallet: HDWalletSeed,
        at accountIndex: UInt32
    ) throws -> HDWalletAddress {
        guard
            let seed = HDWalletUtils.generateSeed(fromEntropy: wallet.entropy),
            let sdk = sdk ?? HDWalletSDKImp(seed: seed.toHexString())
        else {
            throw HDWalletError.invalidSeed
        }
        
        let publicKey = try generatePublicKey(sdk: sdk, accountIndex: accountIndex, addressIndex: Self.addressIndex)
        
        let masterKey = try generateMasterKey(sdk: sdk, seed: seed)
        
        let privateKey = try generatePrivateKey(sdk: sdk, masterKey: masterKey, bip44Path: generateBip44Path(with: accountIndex, and: Self.addressIndex))
        
        var addressError: NSError?
        let address = algorandSDK.addressFromPublicKey(
            publicKey,
            error: &addressError
        )
        
        return HDWalletAddress(
            walletId: wallet.id,
            address: address,
            publicKey: publicKey,
            privateKey: privateKey
        )
    }
    
    func importAddress(
        _ recoveredAddress: RecoveredAddress,
        for wallet: HDWalletSeed
    ) throws -> HDWalletAddress {
        guard
            let seed = HDWalletUtils.generateSeed(fromEntropy: wallet.entropy),
            let sdk = sdk ?? HDWalletSDKImp(seed: seed.toHexString())
        else {
            throw HDWalletError.invalidSeed
        }
        
        let publicKey = try generatePublicKey(sdk: sdk, accountIndex: recoveredAddress.accountIndex, addressIndex: recoveredAddress.addressIndex)
        
        let masterKey = try generateMasterKey(sdk: sdk, seed: seed)
        
        let privateKey = try generatePrivateKey(sdk: sdk, masterKey: masterKey, bip44Path: generateBip44Path(with: recoveredAddress.accountIndex, and: recoveredAddress.addressIndex))
        
        return HDWalletAddress(
            walletId: wallet.id,
            address: recoveredAddress.address,
            publicKey: publicKey,
            privateKey: privateKey
        )
    }
    
    func saveHDWalletAndComposeHDWalletAddressDetail(
        session: Session?,
        storage: any HDWalletStorable,
        entropy: Data?
    ) -> (HDWalletAddressDetail?, String?) {
        do {
            let wallet = try createWallet(from: entropy ?? HDWalletUtils.generate256BitEntropy())
            let initialAddress = try generateAddress(for: wallet, at: 0)
            try storage.save(wallet: wallet)
            try storage.save(address: initialAddress)
            
            let hdWalletAddressDetail = HDWalletAddressDetail(
                walletId: wallet.id,
                account: Self.accountIndex,
                change: Self.changeIndex,
                keyIndex: Self.addressIndex
            )
            
            return (hdWalletAddressDetail, initialAddress.address)
	
        } catch {
            assertionFailure(error.localizedDescription)
            return (nil, nil)
        }
    }
    
    func createAddressDetail(
        for hdWallet: HDWalletInfoViewModel,
        in accountIndex: UInt32
    ) -> HDWalletAddressDetail {
        HDWalletAddressDetail(
            walletId: hdWallet.walletId,
            account: accountIndex,
            change: Self.changeIndex,
            keyIndex: Self.addressIndex
        )
    }
    
    func recoverAccounts(
        fromMnemonic mnemonic: String,
        api: ALGAPI?
    ) async throws -> [RecoverResult] {
        guard
            let seed = HDWalletUtils.generateSeed(fromMnemonic: mnemonic),
            let sdk = sdk ?? HDWalletSDKImp(seed: seed.toHexString())
        else {
            throw HDWalletError.invalidSeed
        }
        
        var recoveredAccounts: [RecoverResult] = []
        var firstAddress: RecoverResult?
        
        var emptyAccountCounter = 0
        var accountIndex: UInt32 = 0
        
        while emptyAccountCounter < Self.gapLimit {
            var addressIndex: UInt32 = 0
            var emptyAddressCounter = 0
            
            while emptyAddressCounter < Self.gapLimit {
                
                let publicKey = try generatePublicKey(sdk: sdk, accountIndex: accountIndex, addressIndex: addressIndex)
                
                var addressError: NSError?
                let address = algorandSDK.addressFromPublicKey(
                    publicKey,
                    error: &addressError
                )
                
                if accountIndex == 0 && addressIndex == 0 {
                    firstAddress = RecoverResult(address: address, accountIndex: 0, addressIndex: 0, algoValue: .empty, usdValue: .empty)
                }
                
                // check account transaction history
                if addressError == nil, let api {
                    if
                        let lookup = await fastLookupAccount(address: address, api: api),
                        lookup.accountExists
                    {
                        recoveredAccounts.append(RecoverResult(address: address, accountIndex: accountIndex, addressIndex: addressIndex, algoValue: lookup.algoValue, usdValue: lookup.usdValue))
                        emptyAddressCounter = 0
                        emptyAccountCounter = 0
                    } else {
                        emptyAddressCounter += 1
                    }
                } else {
                    emptyAddressCounter += 1
                }
                addressIndex += 1
            }
            
            addressIndex = 0
            emptyAddressCounter = 0
            accountIndex += 1
            emptyAccountCounter += 1
        }
        
        // if there are no accounts with transaction history, retrieve the first one
        if
            recoveredAccounts.isEmpty,
            let firstAddress
        {
            recoveredAccounts.append(firstAddress)
        }
        
        return recoveredAccounts
    }
    
    
    func fastLookupAccount(address: String, api: ALGAPI) async -> AccountFastLookup? {
        return await withCheckedContinuation { continuation in
            api.fetchAccountFastLookup(address) { result in
                switch result {
                case .success(let lookup):
                    continuation.resume(returning: lookup)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    static func calculateDerivationPath(
        with accountIndex: UInt32 = HDWalletService.accountIndex,
        and index: UInt32 = HDWalletService.addressIndex
    ) -> String {
        // Example with accountIndex 0 and addressIndex 0: m/44'/283'/0'/0/0
        return "m/\(Self.bip44Purpose)'/\(Self.algorandCoinType)'/\(accountIndex)'/\(Self.changeIndex)/\(index)"
    }
    
    // Generate BIP44 path: m/44'/283'/accountIndex'/0/index
    private func generateBip44Path(
        with accountIndex: UInt32,
        and index: UInt32
    ) -> [UInt32]{
        [
            Self.bip44Purpose,      // Purpose: BIP44
            Self.algorandCoinType,  // Coin type: Algorand
            accountIndex,           // Account index
            Self.changeIndex,       // Change (external addresses)
            index                   // Address index
        ]
    }
    
    // Generate public key
    private func generatePublicKey(
        sdk: HDWalletSDK,
        accountIndex: UInt32,
        addressIndex: UInt32
    ) throws -> Data {
        let keyGenDraft = HDWalletKeyGenDraft(
            context: .address,
            account: accountIndex,
            change: Self.changeIndex,
            keyIndex: addressIndex,
            derivationType: derivationType
        )
        return try sdk.generateKey(keyGenDraft)
    }
    
    // Generate master key using BIP32 derivation
    private func generateMasterKey(
        sdk: HDWalletSDK,
        seed: Data
    ) throws -> Data {
        let rootKeyDraft = HDWalletDeriveKeyDraft(
            rootKey: seed,
            bip44Path: [],
            isPrivate: true,
            derivationType: derivationType
        )
        
        return try sdk.deriveKey(rootKeyDraft)
    }
    
    // Generate private key using BIP44 path: m/44'/283'/accountIndex'/0/index
    private func generatePrivateKey(
        sdk: HDWalletSDK,
        masterKey: Data,
        bip44Path: [UInt32]
    ) throws -> Data {
        let deriveKeyDraft = HDWalletDeriveKeyDraft(
            rootKey: masterKey,
            bip44Path: bip44Path,
            isPrivate: true,
            derivationType: derivationType
        )
        
        return try sdk.deriveKey(deriveKeyDraft)
    }
}

enum HDWalletError: Error, Equatable {
    case invalidEntropy
    case invalidSeed
    case invalidPublicKey
    case entropyGenerationFailed
    case sdkError(String)
    case fastLookupFailed
}

struct RecoverResult {
    let address: String
    let accountIndex: UInt32
    let addressIndex: UInt32
    let algoValue: String
    let usdValue: String
    
}
