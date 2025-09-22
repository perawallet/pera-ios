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
@testable import pera_staging
@testable import pera_wallet_core

final class MockPassKeyService : PassKeyServicing, Mockable {
    
    var mock = Mock()
    
    var allPassKeys: [PassKey] {
        try! mock.call.findAllPassKeys() as! [PassKey]
    }
    
    func findAllSigningAccounts() async throws(LiquidAuthError) -> [AccountInformation] {
        try! mock.call.findAllSigningAccounts() as! [AccountInformation]
    }
    
    func makeSigningSDK(account: AccountInformation) async throws(LiquidAuthError) -> HDWalletSDK? {
        try! mock.call.makeSigningSDK(account: account) as! HDWalletSDK?
    }
    
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws(LiquidAuthError) -> PassKeyCreationResponse {
        try! mock.call.createAndSavePassKey(request: request) as! PassKeyCreationResponse
    }
    
    func makeAuthenticationData(request: PassKeyAuthenticationRequest) async throws(LiquidAuthError) -> PassKeyAuthenticationResponse {
        try! mock.call.makeAuthenticationData(request: request) as! PassKeyAuthenticationResponse
    }
    
    func deletePassKeysForOriginAndUsername(origin: String, username: String) {
        try! mock.call.deletePassKeysForOriginAndUsername(origin: origin, username: username)
    }
    
    func hasPassKey(origin: String, username: String) -> Bool {
        try! mock.call.hasPassKey(origin: origin, username: username) as! Bool
    }
}
