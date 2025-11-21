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
    var accounts: AccountsServiceable { get }
    var blockchain: BlockchainServiceable { get }
}

final class PeraCoreManager: CoreServiceable {
    
    // MARK: - Properties
    
    static let shared = PeraCoreManager()
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { updateServices(network: network) }
    }
    
    // MARK: - Legacy Properties
    
    var legacySessionManager: Session! {
        didSet { updateDataFromLegacySessionManagerInServices() }
    }
    
    var legacySharedDataController: SharedDataController!
    var legacyFeatureFlagService: FeatureFlagServicing!
    
    // MARK: - Services
    
    private(set) lazy var accounts: AccountsServiceable = AccountsService(services: self, legacySessionManager: legacySessionManager, legacySharedDataController: legacySharedDataController, legacyFeatureFlagService: legacyFeatureFlagService)
    private(set) lazy var blockchain: BlockchainServiceable = BlockchainService()
    private(set) lazy var currencies: CurrencyServiceable = CurrencyService(services: self)
    private(set) lazy var nfd: NonFungibleDomainServiceable = NonFungibleDomainService()
    private(set) lazy var inbox: InboxServiceable = InboxService(services: self, legacySessionManager: legacySessionManager, legacyFeatureFlagService: legacyFeatureFlagService)
    
    // MARK: - Initialisers
    
    private init() {}
    
    // MARK: - Updates
    
    private func updateServices(network: CoreApiManager.BaseURL.Network) {
        [accounts, blockchain, currencies, nfd, inbox]
            .compactMap { $0 as? NetworkConfigureable }
            .forEach { $0.network = network }
    }
    
    // MARK: - Legacy Handlers
    
    private func updateDataFromLegacySessionManagerInServices() {
        currencies.selectedCurrency = legacySessionManager.preferredCurrencyID.remoteValue
        currencies.isAlgoPrimaryCurrency.value = legacySessionManager.preferredCurrencyID.isAlgo
    }
}
