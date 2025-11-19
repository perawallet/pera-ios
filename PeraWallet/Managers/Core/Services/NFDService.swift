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

//   NFDService.swift

protocol NonFungibleDomainServiceable {
    func nonFungibleDomainData(name: String) async throws -> [NonFungibleDomainData]
}

final class NonFungibleDomainService: NonFungibleDomainServiceable, NetworkConfigureable {
    
    // MARK: - Properties - NetworkConfigureable
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { update(network: network) }
    }
    
    // MARK: - Properties
    
    private lazy var mobileApiManager = MobileApiManager(network: network)
    
    // MARK: - Updates
    
    private func update(network: CoreApiManager.BaseURL.Network) {
        mobileApiManager.network = network
    }
    
    // MARK: - Actions - NonFungibleDomainServiceable
    
    func nonFungibleDomainData(name: String) async throws(CoreApiManager.ApiError) -> [NonFungibleDomainData] {
        let response = try await mobileApiManager.fetchNonFungibleDomainData(domain: name)
        return response.results.map { NonFungibleDomainData(address: $0.address) }
    }
}
