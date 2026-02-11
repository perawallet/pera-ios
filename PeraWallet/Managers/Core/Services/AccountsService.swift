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

//   AccountsService.swift

import Combine
import pera_wallet_core

protocol AccountsServiceable {
    
    var accounts: ReadOnlyPublisher<Set<PeraAccount>> { get }
    var error: AnyPublisher<AccountsService.ServiceError, Never> { get }
    
    func createJointAccount(participants: [String], threshold: Int, name: String) async throws(AccountsService.ActionError)
    func createJointAccountSignTransactionRequest(jointAccountAddress: String, proposerAddress: String, rawTransactionLists: [[String]], responses: [JointAccountSignRequestResponse]) async throws(AccountsService.ActionError)
    func hasJointAccount(with participantAddresses: [String]) -> Bool
    func signJointAccountTransaction(signRequestId: String, responses: [AccountsService.JointAccountSignResponse]) async throws(AccountsService.ActionError)
    @MainActor func localAccount(address: String) -> AccountInformation?
    @MainActor func localAccount(peraAccount: PeraAccount) -> AccountInformation?
    @MainActor func account(peraAccount: PeraAccount) -> Account?
    @MainActor func account(address: String) -> Account?
}

final class AccountsService: AccountsServiceable, NetworkConfigureable {
    
    enum ServiceError: Error {
        case failedToFetchAccounts(error: CoreApiManager.ApiError)
        case unexpectedError(error: Error)
    }
    
    enum ActionError: Error {
        case unableToCreateLocalAccount(error: Error)
        case unableToCreateJointAccountTransaction(error: CoreApiManager.ApiError)
        case unableToSignJointAccountTransaction(error: CoreApiManager.ApiError)
        case noDeviceID
    }
    
    enum JointAccountSignResponse {
        case signed(address: String, signatures: [[String]])
        case declined(address: String)
    }
    
    // MARK: - Properties - AccountsServicable
    
    var accounts: ReadOnlyPublisher<Set<PeraAccount>> { accountsPublisher.readOnlyPublisher() }
    var error: AnyPublisher<ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }
    
    // MARK: - Properties - NetworkConfigureable

    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { updateManagers(network: network) }
    }
    
    // MARK: - Properties
    
    private let accountsPublisher: CurrentValueSubject<Set<PeraAccount>, Never> = CurrentValueSubject([])
    private let errorPublisher: PassthroughSubject<ServiceError, Never> = PassthroughSubject()
    private let legacySessionManager: Session
    private let legacySharedDataController: SharedDataController
    private let accountDataProvider: AccountDataProvider
    private lazy var indexerApiManager = IndexerApiManager(network: network)
    private lazy var mobileApiManager = MobileApiManager(network: network)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Legacy Properties
    
    @MainActor private var localAccounts: [AccountInformation] { AppDelegate.shared?.appConfiguration.session.authenticatedUser?.accounts ?? [] }
    
    // MARK: - Initialisers
    
    init(services: CoreServiceable, legacySessionManager: Session, legacySharedDataController: SharedDataController, legacyFeatureFlagService: FeatureFlagServicing) {
        self.legacySessionManager = legacySessionManager
        self.legacySharedDataController = legacySharedDataController
        accountDataProvider = AccountDataProvider(legacySessionManager: legacySessionManager, legacyFeatureFlagService: legacyFeatureFlagService)
        setupCallbacks(blockchainService: services.blockchain)
    }
    
    // MARK: - Setups
    
    private func setupCallbacks(blockchainService: BlockchainServiceable) {
        blockchainService.lastBlockNumber.publisher
            .sink { [weak self] _ in self?.fetchAccounts() }
            .store(in: &cancellables)
    }
    
    private func updateManagers(network: CoreApiManager.BaseURL.Network) {
        indexerApiManager.network = network
        reset()
    }
    
    // MARK: - Actions
    
    func createJointAccount(participants: [String], threshold: Int, name: String) async throws(ActionError) {
        do {
            let deviceID = try fetchDeviceID()
            let response = try await mobileApiManager.createJointAccount(participants: participants, threshold: threshold, deviceID: deviceID)
            try LegacyBridgeAccountManager.addLocalAccount(session: legacySessionManager, sharedDataController: legacySharedDataController, address: response.address, name: name, isWatchAccount: false, participants: participants)
        } catch {
            throw .unableToCreateLocalAccount(error: error)
        }
    }
    
    func hasJointAccount(with participantAddresses: [String]) -> Bool {
        let jointAccounts = legacySessionManager.authenticatedUser?.accounts.filter({ $0.type == .joint })
        return jointAccounts?.contains(where: { accountInformation in
            accountInformation.jointAccountParticipants?.sorted() == participantAddresses.sorted()
        }) ?? false
    }
    
    func createJointAccountSignTransactionRequest(jointAccountAddress: String, proposerAddress: String, rawTransactionLists: [[String]], responses: [JointAccountSignRequestResponse]) async throws(ActionError) {
        do {
            let _ = try await mobileApiManager.createJointAccountTransactionSignRequest(
                jointAccountAddress: jointAccountAddress,
                proposerAddress: proposerAddress,
                type: .async,
                rawTransactionLists: rawTransactionLists,
                responses: responses
            )
        } catch {
            throw .unableToCreateJointAccountTransaction(error: error)
        }
    }
    
    func signJointAccountTransaction(signRequestId: String, responses: [JointAccountSignResponse]) async throws(ActionError) {
        
        let apiResponses = try responses.map { response throws(ActionError) in
            try apiSignRequestResponse(responseType: response)
        }
        
        do {
            let _ = try await mobileApiManager.signJointAccountTransaction(signRequestId: signRequestId, responses: apiResponses)
        } catch {
            throw .unableToSignJointAccountTransaction(error: error)
        }
    }
    
    private func fetchAccounts() {
        
        Task {
            
            let localAccounts = await localAccounts
            let accountsData = try await withThrowingTaskGroup(of: (AccountResponse?, AccountInformation).self) { taskGroup in
                
                for localAccount in localAccounts {
                    
                    taskGroup.addTask {
                        do {
                            let response = try await self.indexerApiManager.fetchAccount(publicKey: localAccount.address)
                            return (response, localAccount)
                        } catch let CoreApiManager.ApiError.invalidHTTPStatusCode(code, _) where code == 404 {
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
                .reduce(into: Set<PeraAccount>()) { result, data in
                    let account = account(response: data.0, localAccount: data.1, allLocalAccounts: localAccounts)
                    result.insert(account)
                }
        }
    }
    
    private func reset() {
        accountsPublisher.value.removeAll()
    }
    
    // MARK: - Legacy Actions
    
    @MainActor
    func localAccount(address: String) -> AccountInformation? {
        localAccounts.first { $0.address == address }
    }
    
    @MainActor
    func localAccount(peraAccount: PeraAccount) -> AccountInformation? {
        localAccount(address: peraAccount.address)
    }
    
    @MainActor
    func account(peraAccount: PeraAccount) -> Account? {
        guard let localAccount = localAccount(peraAccount: peraAccount) else { return nil }
        return Account(localAccount: localAccount)
    }
    
    @MainActor
    func account(address: String) -> Account? {
        guard let localAccount = localAccount(address: address) else { return nil }
        return Account(localAccount: localAccount)
    }
    
    // MARK: - Handlers
    
    private func account(response: AccountResponse?, localAccount: AccountInformation, allLocalAccounts: [AccountInformation]) -> PeraAccount {
        
        let accountType = accountDataProvider.accountType(localAccount: localAccount)
        let authorizedAccountType = accountDataProvider.authorizationType(indexerAccount: response?.account, localAccounts: allLocalAccounts)
        let amount: Double
        
        if let response {
            amount = response.account.amount.fromMicroToValue()
        } else {
            amount = 0.0
        }
        
        return PeraAccount(
            address: localAccount.address,
            type: accountType,
            authType: authorizedAccountType,
            amount: amount,
            titles: AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: authorizedAccountType),
            sortingIndex: localAccount.preferredOrder
        )
    }
    
    private func apiSignRequestResponse(responseType: JointAccountSignResponse) throws(ActionError) -> JointAccountSignRequestResponse {
        
        let signerAddress: String
        let transactionResponse: JointAccountSignRequestResponse.Response
        var transactionSignatures: [[String]]?
        var deviceID: String?
        
        switch responseType {
        case let .signed(address, signatures):
            signerAddress = address
            transactionResponse = .signed
            transactionSignatures = signatures
        case let .declined(address):
            signerAddress = address
            transactionResponse = .declined
            deviceID = try fetchDeviceID()
        }
        
        return JointAccountSignRequestResponse(address: signerAddress, response: transactionResponse, signatures: transactionSignatures, deviceId: deviceID)
    }
    
    // MARK: - Helpers
    
    private func fetchDeviceID() throws(ActionError) -> String {
        guard let deviceID = legacySessionManager.authenticatedUser?.getDeviceId(on: network.legacyNetwork) else { throw .noDeviceID }
        return deviceID
    }
}
