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

class MockPassKeyService : PassKeyServicing, Mockable {
    
    var mock = Mock()
    
    func getSigningAddress() async throws -> HDWalletAddress? {
        try! mock.call.getSigningAddress() as! HDWalletAddress?
    }
    
    func getSigningWallet() async throws -> (HDWalletSDK, HDWalletAddressDetail)? {
        try! mock.call.getSigningWallet() as! (HDWalletSDK, HDWalletAddressDetail)?
    }
    
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws -> PassKeyCreationResponse {
        try! mock.call.createAndSavePassKey(request: request) as! PassKeyCreationResponse
    }
    
    func getAuthenticationData(request: PassKeyAuthenticationRequest) async throws -> PassKeyAuthenticationResponse {
        try! mock.call.getAuthenticationData(request: request) as! PassKeyAuthenticationResponse
    }
    
    func findAllPassKeys() -> [PassKey] {
        try! mock.call.findAllPassKeys() as! [PassKey]
    }
    
    func deletePassKeysForOriginAndUsername(origin: String, username: String) {
        try! mock.call.deletePassKeysForOriginAndUsername(origin: origin, username: username)
    }
    
    func hasPassKey(origin: String, username: String) -> Bool {
        try! mock.call.hasPassKey(origin: origin, username: username) as! Bool
    }
}
