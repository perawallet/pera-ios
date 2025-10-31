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

final class ScoutMockHDWalletStorage: HDWalletStorable, Mockable {
    
    var mock = Mock()
    
    func save(wallet: HDWalletSeed) throws {
        try! mock.call.save(wallet: wallet)
    }
    
    func wallet(id: String) throws -> HDWalletSeed? {
        try! mock.call.wallet(id: id) as! HDWalletSeed?
    }
    
    func deleteWallet(id: String) throws {
        try! mock.call.deleteWallet(id: id)
    }
    
    func save(address: HDWalletAddress) throws {
        try! mock.call.save(address: address)
    }
    
    func address(walletId: String, address: String) throws -> HDWalletAddress? {
        try! mock.call.address(walletId: walletId, address: address) as! HDWalletAddress?
    }
    
    func addresses(walletId: String) throws -> [HDWalletAddress] {
        try! mock.call.addresses(walletId: walletId) as! [HDWalletAddress]
    }
    
    func deleteAddress(walletId: String, address: String) throws {
        try! mock.call.deleteAddress(walletId: walletId, address: address)
    }
    
    func allHDWalletKeys() -> [String] {
        try! mock.call.allHDWalletKeys() as! [String]
    }
    
}
