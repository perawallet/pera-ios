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

import Combine

protocol BlockchainServiceable {
    var lastBlockNumber: ReadOnlyPublisher<Int> { get }
    var error: AnyPublisher<BlockchainService.ServiceError?, Never> { get }
    var network: CoreApiManager.BaseURL.Network { get set }
}

final class BlockchainService: BlockchainServiceable {
    
    enum ServiceError: Error {
        case failedToFetchLastBlockNumber(blockNumber: Int)
    }
    
    // MARK: - BlockchainServicable Properties
    
    var lastBlockNumber: ReadOnlyPublisher<Int> { lastBlockNumberPublisher.readOnlyPublisher() }
    var error: AnyPublisher<ServiceError?, Never> { errorPublisher.eraseToAnyPublisher() }
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { update(network: network) }
    }
    
    // MARK: - Properties
    
    private let lastBlockNumberPublisher: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)
    private let errorPublisher: PassthroughSubject<BlockchainService.ServiceError?, Never> = PassthroughSubject()
    private lazy var algodApiManager = AlgodApiManager(network: network)
    
    // MARK: - Initialisers
    
    init() {
        waitForNextBlock(blockNumber: 0)
    }
    
    // MARK: - Setups
    
    private func update(network: CoreApiManager.BaseURL.Network) {
        algodApiManager.network = network
        lastBlockNumberPublisher.value = 0
    }
    
    // MARK: - Actions
    
    private func waitForNextBlock(blockNumber: Int) {
        Task {
            do {
                let response = try await algodApiManager.waitForNextBlock(afterBlockNumber: blockNumber)
                lastBlockNumberPublisher.value = response.lastRound
                waitForNextBlock(blockNumber: lastBlockNumberPublisher.value)
            } catch {
                errorPublisher.send(.failedToFetchLastBlockNumber(blockNumber: blockNumber))
                waitForNextBlock(blockNumber: lastBlockNumberPublisher.value)
            }
        }
    }
}
