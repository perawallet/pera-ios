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

import Scout
import Foundation
import x_hd_wallet_api
@testable import pera_staging
@testable import pera_wallet_core

class ScoutMockHDWalletSDK: HDWalletSDK, Mockable {
    var mock = Mock()
    
    init() { }
    
    required init?(seed: String) { }
    
    func derivePublicChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        try! mock.call.derivePublicChildNode(draft: draft) as! Data
    }
    
    func derivePrivateChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        try! mock.call.derivePrivateChildNode(draft: draft) as! Data
    }
    
    func deriveKey(_ draft: HDWalletDeriveKeyDraft) throws -> Data {
        try! mock.call.deriveKey(draft: draft) as! Data
    }
    
    func generateKey(_ draft: HDWalletKeyGenDraft) throws -> Data {
        try! mock.call.generateKey(draft: draft) as! Data
    }
    
    func signAlgorandTransaction(_ draft: HDWalletSignAlgoTransactionDraft) throws -> Data {
        try! mock.call.signAlgorandTransaction(draft: draft) as! Data
    }
    
    func signData(_ draft: HDWalletSignDataDraft) throws -> Data {
        try! mock.call.signData(draft: draft) as! Data
    }
    
    func rawSign(_ draft: HDWalletSignDataDraft) throws -> Data {
        try! mock.call.rawSign(draft: draft) as! Data
    }
    
    func verifySignature(_ draft: HDWalletVerifySignatureDraft) -> Bool {
        try! mock.call.verifySignature(draft: draft) as! Bool
    }
    
    func validateData(_ data: Data, against metadata: SignMetadata) throws -> Bool {
        try! mock.call.validateData(data: data, metadata: metadata) as! Bool
    }
    
    func performECDH(_ draft: HDWalletECDHDraft) throws -> Data {
        try! mock.call.performECDH(draft: draft) as! Data
    }
    
}
