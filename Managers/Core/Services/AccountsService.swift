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

//   AccountsService.swift

import Combine

protocol AccountsServicable {
    var accounts: ReadOnlyPublisher<[PeraAccount]> { get }
    var error: AnyPublisher<AccountsService.ServiceError, Never> { get }
    var network: CoreApiManager.BaseURL.Network { get set }
}

final class AccountsService: AccountsServicable {
    
    enum ServiceError: Error {
        case failedToFetchAccounts(error: CoreApiManager.ApiError)
        case unexpectedError(error: Error)
    }
    
    // MARK: - AccountsServicable Properties
    
    var accounts: ReadOnlyPublisher<[PeraAccount]> { accountsPublisher.readOnlyPublisher() }
    var error: AnyPublisher<ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }

    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { updateManagers(network: network) }
    }
    
    // MARK: - Properties
    
    private let accountsPublisher: CurrentValueSubject<[PeraAccount], Never> = CurrentValueSubject([])
    private let errorPublisher: PassthroughSubject<ServiceError, Never> = PassthroughSubject()
    private let accountDataProvider: AccountDataProvider
    private lazy var indexerApiManager = IndexerApiManager(network: network)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Legacy Properties
    
    @MainActor private var localAccounts: [AccountInformation] { AppDelegate.shared?.appConfiguration.session.authenticatedUser?.accounts ?? [] }
    
    // MARK: - Initialisers
    
    init(services: CoreServicable, legacySessionManager: Session) {
        accountDataProvider = AccountDataProvider(legacySessionManager: legacySessionManager)
        setupCallbacks(blockchainService: services.blockchain)
    }
    
    // MARK: - Setups
    
    private func setupCallbacks(blockchainService: BlockchainServicable) {
        blockchainService.lastBlockNumber.publisher
            .sink { [weak self] _ in self?.fetchAccounts() }
            .store(in: &cancellables)
    }
    
    private func updateManagers(network: CoreApiManager.BaseURL.Network) {
        indexerApiManager.network = network
        reset()
    }
    
    // MARK: - Actions
    
    private func fetchAccounts() {
        
        Task {
            
            let localAccounts = await localAccounts
            let accountsData = try await withThrowingTaskGroup(of: (AccountResponse?, AccountInformation).self) { taskGroup in
                
                for localAccount in localAccounts {
                    
                    taskGroup.addTask {
                        do {
                            let response = try await self.indexerApiManager.fetchAccount(publicKey: localAccount.address)
                            return (response, localAccount)
                        } catch let CoreApiManager.ApiError.invalidHTTPStatusCode(code) where code == 404 {
                            return (nil, localAccount)
                        } catch let error as CoreApiManager.ApiError {
                            self.errorPublisher.send(.failedToFetchAccounts(error: error))
                            return (nil, localAccount)
                        } catch {
                            self.errorPublisher.send(.unexpectedError(error: error))
                            return (nil, localAccount)
                        }
                    }
                }
                
                return try await taskGroup.reduce(into: [(AccountResponse?, AccountInformation)]()) { result, data in
                    result.append(data)
                }
            }
            
            accountsPublisher.value = accountsData
                .map { response, localAccount in
                    PeraAccount(
                        address: localAccount.address,
                        type: accountDataProvider.accountType(localAccount: localAccount),
                        authType: accountDataProvider.authorizationType(indexerAccount: response?.account, localAccounts: localAccounts)
                    )
                }
        }
    }
    
    private func reset() {
        accountsPublisher.value.removeAll()
    }
}
