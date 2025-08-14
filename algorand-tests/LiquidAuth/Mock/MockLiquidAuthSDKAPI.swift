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
import CryptoKit
import LiquidAuthSDK
@testable import pera_staging
@testable import pera_wallet_core

class MockLiquidAuthSDKAPI : LiquidAuthSDKAPI, Mockable {
    
    var mock = Mock()
    
    var signalService: LiquidAuthSDK.SignalService {
        get {
            mock.get.signalService
        }
    }
    
    func decodeBase64Url(_ url: String) -> Data? {
        try! mock.call.decodeBase64Url(url) as! Data?
    }
    
    func decodeBase64UrlToJSON(_ url: String) -> String? {
        try! mock.call.decodeBase64UrlToJSON(url) as! String?
    }
    
    func postAttestationOptions(origin: String, username: String) async throws -> Data {
        try! mock.call.postAttestationOptions(origin: origin, username: username) as! Data
    }
    
    func postAttestationResult(origin: String, credential: [String : Any], liquidExt: [String : Any]) async throws -> Data {
        try! mock.call.postAttestationResult(origin: origin, credential: credential, liquidExt: liquidExt) as! Data
    }
    
    func postAssertionOptions(origin: String, credentialId: String) async throws -> Data {
        try! mock.call.postAssertionOptions(origin: origin, credentialId: credentialId) as! Data
    }
    
    func postAssertionResult(origin: String, credential: String, liquidExt: [String : Any]) async throws -> Data {
        try! mock.call.postAssertionResult(origin: origin, credential: credential, liquidExt: liquidExt) as! Data
    }
    
    func getAssertionObject(rpIdHash: Data, userPresent: Bool, userVerified: Bool, backupEligible: Bool, backupState: Bool, signCount: UInt32) -> Data {
        try! mock.call.getAssertionObject(rpIdHash: rpIdHash, userPresent: userPresent, userVerified: userVerified,
                                          backupEligible: backupEligible, backupState: backupState, signCount: signCount) as! Data
    }
    
    func getAttestationObject(credentialId: Data, keyPair: P256.Signing.PrivateKey, rpIdHash: Data) throws -> Data {
        try! mock.call.getAttestationObject(credentialId: credentialId, keyPair: keyPair, rpIdHash: rpIdHash) as! Data
    }
    
    
}

