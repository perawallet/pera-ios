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

//   InboxService.swift


import Combine
import pera_wallet_core

protocol InboxServiceable {
    
    var jointAccountImportRequests: ReadOnlyPublisher<[MultiSigAccountObject]> { get }
    var jointAccountSignRequests: ReadOnlyPublisher<[SignRequestObject]> { get }
    var algorandStandardAssetInboxes: ReadOnlyPublisher<[ASAInboxMeta]> { get }
    var error: AnyPublisher<InboxService.ServiceError, Never> { get }
    
    func ignoreAccountImportRequest(jointAccountAddress: String) async throws(InboxService.ActionError)
    func acceptAccountImportRequest(jointAccountAddress: String, name: String) async throws(InboxService.ActionError)
}

final class InboxService: InboxServiceable, NetworkConfigureable {
    
    enum ActionError: Error {
        case noDeviceID
        case addressNotFound
        case failedIgnoreAccountImportRequest(error: CoreApiManager.ApiError)
        case failedAcceptAccountImportRequest(createAccountError: AccountsService.ActionError)
        case failedAcceptAccountImportRequest(deleteInboxMessageError: CoreApiManager.ApiError)
    }
    
    enum ServiceError: Error {
        case noDeviceID
        case failedFetchInbox(error: CoreApiManager.ApiError)
        case unexpectedError(error: Error)
    }
    
    // MARK: - Constants
    
    private let pollingTimeInterval: Duration = .seconds(6)
    
    // MARK: - Properties - NetworkConfigureable
    
    var network: CoreApiManager.BaseURL.Network = .mainNet {
        didSet { update(network: network) }
    }
    
    // MARK: - Properties - InboxServiceable
    
    var jointAccountImportRequests: ReadOnlyPublisher<[MultiSigAccountObject]> { jointAccountImportRequestsPublisher.readOnlyPublisher() }
    var jointAccountSignRequests: ReadOnlyPublisher<[SignRequestObject]> { jointAccountSignRequestsPublisher.readOnlyPublisher() }
    var algorandStandardAssetInboxes: ReadOnlyPublisher<[ASAInboxMeta]> { algorandStandardAssetInboxesPublisher.readOnlyPublisher() }
    var error: AnyPublisher<ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }
    
    // MARK: - Properties
    
    private let legacySessionManager: Session
    private let legacyFeatureFlagService: FeatureFlagServicing
    private let accountService: AccountsServiceable
    private let tasksManager = CancellableTasksManager()
    private let jointAccountImportRequestsPublisher: CurrentValueSubject<[MultiSigAccountObject], Never> = CurrentValueSubject([])
    private let jointAccountSignRequestsPublisher: CurrentValueSubject<[SignRequestObject], Never> = CurrentValueSubject([])
    private let algorandStandardAssetInboxesPublisher: CurrentValueSubject<[ASAInboxMeta], Never> = CurrentValueSubject([])
    private let errorPublisher: PassthroughSubject<ServiceError, Never> = PassthroughSubject()
    
    private var cachedAddresses: [String] = []
    private var cancellables: Set<AnyCancellable> = []
    private lazy var mobileApiManager = MobileApiManager(network: network)
    
    // MARK: - Updates
    
    private func update(network: CoreApiManager.BaseURL.Network) {
        mobileApiManager.network = network
        Task {
            await fetchInboxRequestNow()
        }
    }
    
    // MARK: - Initialisers
    
    init(services: CoreServiceable, legacySessionManager: Session, legacyFeatureFlagService: FeatureFlagServicing) {
        self.legacySessionManager = legacySessionManager
        self.legacyFeatureFlagService = legacyFeatureFlagService
        self.accountService = services.accounts
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        accountService.accounts.publisher
            .removeDuplicates()
            .sink { [weak self] in self?.handle(accounts: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - InboxServiceable
    
    func ignoreAccountImportRequest(jointAccountAddress: String) async throws(ActionError) {
        
        let deviceID = try fetchDeviceID()
        
        do {
            _ = try await mobileApiManager.cancelJointAccountImportRequest(deviceID: deviceID, jointAccountAddress: jointAccountAddress)
        } catch {
            throw .failedIgnoreAccountImportRequest(error: error)
        }
    }
    
    func acceptAccountImportRequest(jointAccountAddress: String, name: String) async throws(ActionError) {
        
        let deviceID = try fetchDeviceID()
        guard let jointAccountImportData = jointAccountImportRequests.value.first(where: { $0.address == jointAccountAddress }) else { throw .addressNotFound }
        
        do {
            try await accountService.createJointAccount(participants: jointAccountImportData.participantAddresses, threshold: jointAccountImportData.threshold, name: name)
        } catch {
            throw .failedAcceptAccountImportRequest(createAccountError: error)
        }
        
        do {
            _ = try await mobileApiManager.cancelJointAccountImportRequest(deviceID: deviceID, jointAccountAddress: jointAccountAddress)
        } catch {
            throw .failedAcceptAccountImportRequest(deleteInboxMessageError: error)
        }
        
        await fetchInboxRequestNow()
    }
    
    // MARK: - Actions
    
    private func performInboxRequestInLoop() {
        
        guard !cachedAddresses.isEmpty else {
            Task {
                await scheduleNextInboxRequest()
            }
            return
        }
        
        let deviceID: String
        
        do {
            deviceID = try fetchDeviceID()
        } catch {
            errorPublisher.send(.noDeviceID)
            return
        }
        
        Task {
            do {
                let response = try await mobileApiManager.fetchInbox(deviceID: deviceID, addresses: cachedAddresses)
                handle(inboxResponse: response)
            } catch let error as CoreApiManager.ApiError {
                errorPublisher.send(.failedFetchInbox(error: error))
            } catch {
                errorPublisher.send(.unexpectedError(error: error))
            }
            await scheduleNextInboxRequest()
        }
    }
    
    private func scheduleNextInboxRequest() async {
        
        await tasksManager.cancelAll()
        
        let task = Task {
            do {
                try await Task.sleep(for: pollingTimeInterval)
                performInboxRequestInLoop()
            } catch {
            }
        }
        
        _ = await tasksManager.add(task: task)
    }
    
    private func fetchInboxRequestNow() async {
        await tasksManager.cancelAll()
        performInboxRequestInLoop()
    }
    
    // MARK: - Handlers
    
    private func handle(accounts: Set<PeraAccount>) {
        
        cachedAddresses = accounts
            .filter { $0.type != .watch }
            .map(\.address)
        
        Task {
            await fetchInboxRequestNow()
        }
    }
    
    private func handle(inboxResponse: InboxCreateResponse) {
        
        if legacyFeatureFlagService.isEnabled(.jointAccountEnabled) {
            jointAccountImportRequestsPublisher.value = inboxResponse.jointAccountImportRequests
            jointAccountSignRequestsPublisher.value = inboxResponse.jointAccountSignRequests
        }
        
        algorandStandardAssetInboxesPublisher.value = inboxResponse.asaInboxes
    }
    
    // MARK: - Helpers
    
    private func fetchDeviceID() throws(ActionError) -> String {
        guard let deviceID = legacySessionManager.authenticatedUser?.getDeviceId(on: network.legacyNetwork) else { throw .noDeviceID }
        return deviceID
    }
}

private extension CoreApiManager.BaseURL.Network {
    
    var legacyNetwork: ALGAPI.Network {
        switch self {
        case .mainNet: .mainnet
        case .testNet: .testnet
        }
    }
}
