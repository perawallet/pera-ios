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

//   AlgodApiManager.swift

final class AlgodApiManager {
    
    // MARK: - Properties
    
    var network: CoreApiManager.BaseURL.Network {
        didSet { updateApiManager(network: network) }
    }
    
    private lazy var apiManager = CoreApiManager(baseURL: .algod(network: network))
    
    // MARK: - Initialisers
    
    init(network: CoreApiManager.BaseURL.Network) {
        self.network = network
    }
    
    
    private func updateApiManager(network: CoreApiManager.BaseURL.Network) {
        apiManager.baseURL = .algod(network: network)
    }
    
    // MARK: - Requests
    
    func waitForNextBlock(afterBlockNumber blockNumber: Int) async throws -> WaitForBlockResponse {
        let request = WaitForBlockRequest(blockNumber: blockNumber)
        return try await apiManager.perform(request: request)
    }
}
