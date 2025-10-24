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

//   CurrencyService.swift

import Combine
import pera_wallet_core

struct CurrencyData: Equatable {
    let id: String
    let exchangeRate: String
    let symbol: String
}

protocol CurrencyServiceable: AnyObject {
    var selectedCurrencyData: ReadOnlyPublisher<CurrencyData?> { get }
    var error: AnyPublisher<CurrencyService.ServiceError, Never> { get }
    var selectedCurrency: String { get set }
    var isAlgoPrimaryCurrency: CurrentValueSubject<Bool, Never> { get }
}

final class CurrencyService: CurrencyServiceable, NetworkConfigureable {
    
    enum ServiceError: Error {
        case failedToFetchCurrency(error: CoreApiManager.ApiError)
    }
    
    // MARK: - Properties - CurrencyServiceable
    
    var selectedCurrencyData: ReadOnlyPublisher<CurrencyData?> { selectedCurrencyDataPublisher.readOnlyPublisher() }
    var error: AnyPublisher<CurrencyService.ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }
    
    var selectedCurrency: String = "" {
        didSet { fetchCurrency() }
    }
    
    private(set) var isAlgoPrimaryCurrency: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    // MARK: - Properties - NetworkConfigureable
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { update(network: network) }
    }
    
    // MARK: - Properties
    
    private let selectedCurrencyDataPublisher: CurrentValueSubject<CurrencyData?, Never> = CurrentValueSubject(nil)
    private let isAlgoPrimaryCurrencyPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    private let errorPublisher: PassthroughSubject<ServiceError, Never> = PassthroughSubject()
    private lazy var mobileApiManager = MobileApiManager(network: network)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisers
    
    
    init(services: CoreServiceable) {
        setupCallbacks(blockchainService: services.blockchain)
    }
    
    // MARK: - Setups
    
    private func setupCallbacks(blockchainService: BlockchainServiceable) {
        
        blockchainService.lastBlockNumber.publisher
            .sink { [weak self] _ in self?.fetchCurrency() }
            .store(in: &cancellables)
    }
     
    private func update(network: CoreApiManager.BaseURL.Network) {
        mobileApiManager.network = network
        selectedCurrencyDataPublisher.value = nil
    }
    
    // MARK: - Actions
    
    private func fetchCurrency() {
        Task {
            do {
                let response = try await mobileApiManager.fetchCurrencyData(currencyID: selectedCurrency)
                selectedCurrencyDataPublisher.value = CurrencyData(id: response.currencyId, exchangeRate: response.exchangePrice, symbol: response.symbol)
            } catch let error as CoreApiManager.ApiError {
                errorPublisher.send(.failedToFetchCurrency(error: error))
            }
        }
    }
}
