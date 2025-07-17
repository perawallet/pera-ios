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

//   IndexerApiManager.swift

final class IndexerApiManager {
    
    // MARK: - Properties
    
    var network: CoreApiManager.BaseURL.Network {
        didSet { updateApiManager(network: network) }
    }
    
    private lazy var apiManager = CoreApiManager(baseURL: .indexer(network: network))
    
    // MARK: - Initialisers
    
    init(network: CoreApiManager.BaseURL.Network) {
        self.network = network
    }
    
    // MARK: - Setups
    
    private func updateApiManager(network: CoreApiManager.BaseURL.Network) {
        apiManager.baseURL = .indexer(network: network)
    }
    
    // MARK: - Requests
    
    func fetchAccount(publicKey: String) async throws(CoreApiManager.ApiError) -> AccountResponse {
        let request = AccountRequest(publicKey: publicKey)
        return try await apiManager.perform(request: request)
    }
}
