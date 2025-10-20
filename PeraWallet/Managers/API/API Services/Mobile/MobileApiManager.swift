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

//   MobileApiManager.swift

final class MobileApiManager {
    
    // MARK: - Properties
    
    var network: CoreApiManager.BaseURL.Network {
        didSet { updateApiManagers(network: network) }
    }
    
    private lazy var apiManagerV1 = CoreApiManager(baseURL: .mobile(network: network, version: .v1), keyDecodingStrategy: .convertFromSnakeCase, keyEncodingStrategy: .convertToSnakeCase)
    private lazy var apiManagerV2 = CoreApiManager(baseURL: .mobile(network: network, version: .v2), keyDecodingStrategy: .convertFromSnakeCase, keyEncodingStrategy: .convertToSnakeCase)
    
    // MARK: - Initialisers
    
    init(network: CoreApiManager.BaseURL.Network) {
        self.network = network
    }
    
    // MARK: - Setups
    
    private func updateApiManagers(network: CoreApiManager.BaseURL.Network) {
        apiManagerV1.baseURL = .mobile(network: network, version: .v1)
        apiManagerV2.baseURL = .mobile(network: network, version: .v2)
    }
    
    // MARK: - Requests
    
    func fetchCurrencyData(currencyID: String) async throws(CoreApiManager.ApiError) -> CurrencyDataResponse {
        let request = CurrencyDataRequest(currencyID: currencyID)
        return try await apiManagerV1.perform(request: request)
    }
    
    func fetchNonFungibleDomainData(domain: String) async throws(CoreApiManager.ApiError) -> NameServiceSearchResponse {
        let request = NameServiceSearchRequest(name: domain)
        return try await apiManagerV1.perform(request: request)
    }
    
    func createJointAccount(participants: [String], threshold: Int) async throws(CoreApiManager.ApiError) -> MultiSigAccountObject {
        let jointAccountObject = MultiSigAccountObject(address: "", participantAddresses: participants, threshold: threshold, version: 1)
        let request = CreateJointAccountRequest(jointAccountObject: jointAccountObject)
        return try await apiManagerV1.perform(request: request)
    }
}
