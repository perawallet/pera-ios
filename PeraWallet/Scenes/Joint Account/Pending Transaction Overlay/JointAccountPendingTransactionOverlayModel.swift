// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountPendingTransactionOverlayModel.swift

import Combine
import pera_wallet_core

struct SignRequestInfo {
    let address: String
    let status: SignRequestStatus?
}

protocol JointAccountPendingTransactionOverlayModelable {
    @MainActor var viewModel: JointAccountPendingTransactionOverlayModel.ViewModel { get }
    @MainActor func cancelTransaction()
    func stopPolling()
}

final class JointAccountPendingTransactionOverlayModel: JointAccountPendingTransactionOverlayModelable {
    
    enum SignatureStatus {
        case signed
        case declined
        case pending
    }
    
    enum TransactionStatus {
        case inProgress
        case success
        case cancelled
    }
    
    enum ModelError: Error {
        case unableToFetchData(error: Error)
        case cancelTransactionFailed(error: Error)
    }
    
    struct AccountModel: Identifiable {
        let id: UUID
        let address: String
        let avatar: ImageType
        let title: String
        let subtitle: String?
        let signatureStatus: SignatureStatus
    }
    
    final class ViewModel: ObservableObject {
        @Published fileprivate(set) var numberOfSignaturesText: String = ""
        @Published fileprivate(set) var deadline: Date = Date()
        @Published fileprivate(set) var threshold: Int = 0
        @Published fileprivate(set) var transactionState: TransactionStatus = .inProgress
        @Published fileprivate(set) var accounts: [AccountModel] = []
        @Published fileprivate(set) var isCancelProcessStarted: Bool = false
        @Published fileprivate(set) var error: ModelError?
    }
    
    // MARK: - Properties
    
    private let signRequestID: String
    private let accountsService: AccountsServiceable
    private let pollingService = PollingService(timeInterval: .seconds(6))
    private let legacyBannerController: BannerController?
    private let proposerAddress: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties - JointAccountPendingTransactionOverlayViewModelable
    
    @MainActor let viewModel: ViewModel = ViewModel()
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServiceable, legacyBannerController: BannerController?, signRequestID: String, proposerAddress: String, signaturesInfo: [SignRequestInfo], threshold: Int, deadline: Date) {
        
        self.accountsService = accountsService
        self.legacyBannerController = legacyBannerController
        self.signRequestID = signRequestID
        self.proposerAddress = proposerAddress
        
        let participants = signaturesInfo.map(\.address)
        let localAccounts = accountsService.accounts.value.filter { participants.contains($0.address) }
        
        let accountsModels = signaturesInfo
            .sorted { $0.address < $1.address }
            .map { accountModel(address: $0.address, signRequestStatus: $0.status, localAccounts: localAccounts) }
        
        Task { @MainActor in
            viewModel.threshold = threshold
            viewModel.deadline = deadline
            update(accounts: accountsModels)
            
            setupCallbacks()
        }
        
        startPoolingForData()
    }
    
    // MARK: - Setups
    
    @MainActor
    private func setupCallbacks() {
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] in self?.show(error: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Updates
    
    @MainActor
    private func update(accounts: [AccountModel]) {
        let signatureCount = accounts.filter { $0.signatureStatus == .signed }.count
        viewModel.numberOfSignaturesText = String(localized: "inbox-joint-account-sign-request-signed-transactions-\(signatureCount)-\(viewModel.threshold)")
        viewModel.accounts = accounts
    }
    
    // MARK: - Actions - JointAccountPendingTransactionOverlayModelable
    
    @MainActor
    func cancelTransaction() {
        
        viewModel.isCancelProcessStarted = true
        
        let responses: [AccountsService.JointAccountSignResponse] = [.declined(address: proposerAddress)]
        
        Task {
            do {
                try await accountsService.signJointAccountTransaction(signRequestId: signRequestID, responses: responses)
            } catch {
                viewModel.error = .cancelTransactionFailed(error: error)
                viewModel.isCancelProcessStarted = false
            }
        }
    }
    
    func stopPolling() {
        Task {
            await pollingService.stop()
        }
    }
    
    // MARK: - Actions
    
    private func startPoolingForData() {
        Task {
            await pollingService.start { await self.fetchData() }
        }
    }
    
    @MainActor
    private func fetchData() async {
        do {
            let result = try await accountsService.searchJointAccountSignTransaction(signRequestID: signRequestID)
            handle(searchResult: result)
        } catch {
            viewModel.error = .unableToFetchData(error: error)
        }
    }
    
    private func fetchContactData(address: String) -> ContactDataProvider.ContactData? {
        guard let contact = try? ContactsManager.fetchContact(address: address) else { return nil }
        return ContactDataProvider.data(contact: contact)
    }
    
    private func show(error: ModelError) {
        
        let title = String(localized: "title-error")
        let message: String
        
        switch error {
        case .unableToFetchData:
            message = String(localized: "error-joint-account-pending-transaction-unable-to-fetch-data")
        case .cancelTransactionFailed:
            message = String(localized: "error-joint-account-pending-transaction-cancel-transaction-failed")
        }
        
        legacyBannerController?.presentErrorBanner(title: title, message: message)
    }
    
    // MARK: - Handlers
    
    @MainActor
    private func handle(searchResult: JointAccountsSignRequestSearchResponse) {
        
        guard let result = searchResult.results.first else { return }
        
        if let status = result.status {
            switch status {
            case .pending, .ready, .submitting:
                viewModel.transactionState = .inProgress
            case .confirmed:
                viewModel.transactionState = .success
            case .failed, .expired, .declined:
                viewModel.transactionState = .cancelled
            }
        }
        
        guard let transactionLists = result.transactionLists else { return }
        
        let updates = transactionLists
            .flatMap(\.responses)
            .reduce(into: [String: SignRequestStatus]()) { $0[$1.address] = $1.response }
        
        let accounts = viewModel.accounts.map {
            let transactionResponse = updates[$0.address]
            let signatureStatus = viewModelSignatureStatus(signRequestStatus: transactionResponse)
            return AccountModel(id: $0.id, address: $0.address, avatar: $0.avatar, title: $0.title, subtitle: $0.subtitle, signatureStatus: signatureStatus)
        }
        
        update(accounts: accounts)
    }
    
    private func viewModelSignatureStatus(signRequestStatus: SignRequestStatus?) -> SignatureStatus {
        switch signRequestStatus {
        case .signed: .signed
        case .declined: .declined
        case .none: .pending
        }
    }
    
    private func accountModel(address: String, signRequestStatus: SignRequestStatus?, localAccounts: Set<PeraAccount>) -> AccountModel {
        
        let signatureStatus = viewModelSignatureStatus(signRequestStatus: signRequestStatus)
        let title: String
        let subtitle: String?
        let avatar: ImageType
        
        if let contactData = fetchContactData(address: address) {
            title = contactData.title
            subtitle = contactData.subtitle
            avatar = contactData.image
        } else if let localAccount = localAccounts.first(where: { $0.address == address }) {
            title = localAccount.titles.primary
            subtitle = localAccount.titles.secondary
            avatar = .placeholderGroupIconData
        } else {
            title = address.shortAddressDisplay
            subtitle = nil
            avatar = .placeholderGroupIconData
        }
        
        return AccountModel(id: UUID(), address: address, avatar: avatar, title: title, subtitle: subtitle, signatureStatus: signatureStatus)
    }
}
