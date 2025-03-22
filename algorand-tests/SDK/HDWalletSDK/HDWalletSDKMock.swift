// Copyright 2022 Pera Wallet, LDA

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
//   AlgorandSDKTests.swift

import Foundation
@testable import pera_staging
@testable import x_hd_wallet_api

final class HDWalletSDKMock: HDWalletSDK {
    var initWithSeedCalled = false
    var derivePublicChildNodeCalled = false
    var derivePrivateChildNodeCalled = false
    var deriveKeyCalled = false
    var generateKeyCalled = false
    var signAlgorandTransactionCalled = false
    var signDataCalled = false
    var verifySignatureCalled = false
    var validateDataCalled = false
    var performECDHCalled = false
    
    var seedProvided: String?
    var lastDeriveChildNodeDraft: HDWalletDeriveChildNodeDraft?
    var lastDeriveKeyDraft: HDWalletDeriveKeyDraft?
    var lastKeyGenDraft: HDWalletKeyGenDraft?
    var lastSignAlgoTransactionDraft: HDWalletSignAlgoTransactionDraft?
    var lastSignDataDraft: HDWalletSignDataDraft?
    var lastVerifySignatureDraft: HDWalletVerifySignatureDraft?
    var lastValidateDataInput: (data: Data, metadata: SignMetadata)?
    var lastECDHDraft: HDWalletECDHDraft?
    
    var derivePublicChildNodeResult: Result<Data, Error> = .success(Data())
    var derivePrivateChildNodeResult: Result<Data, Error> = .success(Data())
    var deriveKeyResult: Result<Data, Error> = .success(Data())
    var generateKeyResult: Result<Data, Error> = .success(Data())
    var signAlgorandTransactionResult: Result<Data, Error> = .success(Data())
    var signDataResult: Result<Data, Error> = .success(Data())
    var verifySignatureResult: Bool = true
    var validateDataResult: Result<Bool, Error> = .success(true)
    var performECDHResult: Result<Data, Error> = .success(Data())
    
    required init?(seed: String) {
        initWithSeedCalled = true
        seedProvided = seed
    }
    
    func derivePublicChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        derivePublicChildNodeCalled = true
        lastDeriveChildNodeDraft = draft
        switch derivePublicChildNodeResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func derivePrivateChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        derivePrivateChildNodeCalled = true
        lastDeriveChildNodeDraft = draft
        switch derivePrivateChildNodeResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func deriveKey(_ draft: HDWalletDeriveKeyDraft) throws -> Data {
        deriveKeyCalled = true
        lastDeriveKeyDraft = draft
        switch deriveKeyResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func generateKey(_ draft: HDWalletKeyGenDraft) throws -> Data {
        generateKeyCalled = true
        lastKeyGenDraft = draft
        switch generateKeyResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func signAlgorandTransaction(_ draft: HDWalletSignAlgoTransactionDraft) throws -> Data {
        signAlgorandTransactionCalled = true
        lastSignAlgoTransactionDraft = draft
        switch signAlgorandTransactionResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func signData(_ draft: HDWalletSignDataDraft) throws -> Data {
        signDataCalled = true
        lastSignDataDraft = draft
        switch signDataResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func verifySignature(_ draft: HDWalletVerifySignatureDraft) -> Bool {
        verifySignatureCalled = true
        lastVerifySignatureDraft = draft
        return verifySignatureResult
    }
    
    func validateData(_ data: Data, against metadata: SignMetadata) throws -> Bool {
        validateDataCalled = true
        lastValidateDataInput = (data, metadata)
        switch validateDataResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func performECDH(_ draft: HDWalletECDHDraft) throws -> Data {
        performECDHCalled = true
        lastECDHDraft = draft
        switch performECDHResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
} 
