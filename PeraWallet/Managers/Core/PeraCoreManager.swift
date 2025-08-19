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

//   PeraCoreManager.swift

import pera_wallet_core

protocol CoreServiceable {
    var blockchain: BlockchainServiceable { get }
}

final class PeraCoreManager: CoreServiceable {
    
    // MARK: - Properties
    
    static let shared = PeraCoreManager()
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { updateServices(network: network) }
    }
    
    // MARK: - Legacy Properties
    
    var legacySessionManager: Session!
    
    // MARK: - Services
    
    private(set) lazy var accounts: AccountsServiceable = AccountsService(services: self, legacySessionManager: legacySessionManager)
    private(set) lazy var blockchain: BlockchainServiceable = BlockchainService()
    
    // MARK: - Initialisers
    
    private init() {}
    
    private func updateServices(network: CoreApiManager.BaseURL.Network) {
        accounts.network = network
        blockchain.network = network
    }
}
