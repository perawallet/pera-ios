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
    @MainActor func signWithLedger(identifier: UUID)
}

final class JointAccountPendingTransactionOverlayModel: JointAccountPendingTransactionOverlayModelable {
    
    enum SignatureStatus: Equatable {
        case signed
        case declined
        case pending(isSignatureNeeded: Bool)
        case expired
    }
    
    enum TransactionStatus {
        case inProgress(canCancelTransaction: Bool)
        case success
        case cancelled
        case failed(errorMessage: String)
    }
    
    enum ModelError: Error {
        case unableToFetchData(error: Error)
        case cancelTransactionFailed(error: Error)
        case unableToFindLedgerAccount
    }
    
    enum Action {
        case signWithLedger(_ signerAddress: String)
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
        @Published fileprivate(set) var transactionState: TransactionStatus = .inProgress(canCancelTransaction: false)
        @Published fileprivate(set) var accounts: [AccountModel] = []
        @Published fileprivate(set) var isCancelProcessStarted: Bool = false
        @Published fileprivate(set) var action: Action?
        @Published fileprivate(set) var error: ModelError?
    }
    
    // MARK: - Properties
    
    private let signRequestID: String
    private let accountsService: AccountsServiceable
    private let pollingService = PollingService(timeInterval: .seconds(6))
    private let legacyBannerController: BannerController?
    private let proposerAddress: String
    private let isCancelTransactionAvailable: Bool
    private let isSignWithLedgerActionAvailable: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties - JointAccountPendingTransactionOverlayViewModelable
    
    @MainActor let viewModel: ViewModel = ViewModel()
    
    // MARK: - Initialisers
    
    @MainActor
    init(signRequestMetadata: SignRequestMetadata, isCancelTransactionAvailable: Bool, isSignWithLedgerActionAvailable: Bool, accountsService: AccountsServiceable, legacyBannerController: BannerController?) {
        
        self.accountsService = accountsService
        self.legacyBannerController = legacyBannerController
        self.signRequestID = signRequestMetadata.signRequestID
        self.proposerAddress = signRequestMetadata.proposerAddress
        self.isCancelTransactionAvailable = isCancelTransactionAvailable
        self.isSignWithLedgerActionAvailable = isSignWithLedgerActionAvailable
        
        let participants = signRequestMetadata.signaturesInfo.map(\.address)
        let localAccounts = accountsService.accounts.value.filter { participants.contains($0.address) }
        
        let accountsModels = signRequestMetadata.signaturesInfo
            .sorted { $0.address < $1.address }
            .map { accountModel(address: $0.address, signRequestStatus: $0.status, localAccounts: localAccounts) }
        
        viewModel.transactionState = .inProgress(canCancelTransaction: isCancelTransactionAvailable)
        viewModel.threshold = signRequestMetadata.threshold
        viewModel.deadline = signRequestMetadata.deadline
        
        update(accounts: accountsModels)
        setupCallbacks()
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
    
    @MainActor
    func signWithLedger(identifier: UUID) {
        
        guard let address = viewModel.accounts.first(where: { $0.id == identifier })?.address else {
            viewModel.error = .unableToFindLedgerAccount
            return
        }
        
        viewModel.action = .signWithLedger(address)
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
        case .unableToFindLedgerAccount:
            message = String(localized: "error-joint-account-pending-transaction-unable-to-find-ledger-account")
        }
        
        legacyBannerController?.presentErrorBanner(title: title, message: message)
    }
    
    // MARK: - Handlers
    
    @MainActor
    private func handle(searchResult: JointAccountsSignRequestSearchResponse) {
        
        guard let result = searchResult.results.first else { return }
        var isTransactionInProgress = false
        
        if let status = result.status {
            switch status {
            case .pending, .ready, .submitting:
                viewModel.transactionState = .inProgress(canCancelTransaction: isCancelTransactionAvailable)
                isTransactionInProgress = true
            case .confirmed:
                viewModel.transactionState = .success
            case .failed:
                if let reason = result.failReasonDisplay {
                    viewModel.transactionState = .failed(errorMessage: reason)
                } else {
                    viewModel.transactionState = .cancelled
                }
            case .expired, .declined:
                viewModel.transactionState = .cancelled
            }
        }
        
        guard let transactionLists = result.transactionLists else { return }
        
        let updates = transactionLists
            .flatMap(\.responses)
            .reduce(into: [String: SignRequestStatus]()) { $0[$1.address] = $1.response }
        
        let accounts = viewModel.accounts.map {
            let address = $0.address
            let transactionResponse = updates[address]
            let isSignatureNeeded = isSignWithLedgerActionAvailable && accountsService.accounts.value.first { $0.address == address }?.type == .ledger
            let signatureStatus = viewModelSignatureStatus(signRequestStatus: transactionResponse, isTransactionInProgress: isTransactionInProgress, isSignatureNeeded: isSignatureNeeded)
            return AccountModel(id: $0.id, address: $0.address, avatar: $0.avatar, title: $0.title, subtitle: $0.subtitle, signatureStatus: signatureStatus)
        }
        
        update(accounts: accounts)
    }
    
    private func viewModelSignatureStatus(signRequestStatus: SignRequestStatus?, isTransactionInProgress: Bool, isSignatureNeeded: Bool) -> SignatureStatus {
        switch signRequestStatus {
        case .signed: .signed
        case .declined: .declined
        case .none: isTransactionInProgress ? .pending(isSignatureNeeded: isSignatureNeeded) : .expired
        }
    }
    
    private func accountModel(address: String, signRequestStatus: SignRequestStatus?, localAccounts: Set<PeraAccount>) -> AccountModel {
        
        let title: String
        let subtitle: String?
        let avatar: ImageType
        let isSignatureNeeded: Bool
        
        if let contactData = fetchContactData(address: address) {
            title = contactData.title
            subtitle = contactData.subtitle
            avatar = contactData.image
            isSignatureNeeded = false
        } else if let localAccount = localAccounts.first(where: { $0.address == address }) {
            title = localAccount.titles.primary
            subtitle = localAccount.titles.secondary
            avatar = .icon(data: AccountIconProvider.iconData(account: localAccount))
            isSignatureNeeded = isSignWithLedgerActionAvailable && localAccount.type == .ledger
        } else {
            title = address.shortAddressDisplay
            subtitle = nil
            avatar = .placeholderGroupIconData
            isSignatureNeeded = false
        }
        
        let signatureStatus = viewModelSignatureStatus(signRequestStatus: signRequestStatus, isTransactionInProgress: true, isSignatureNeeded: isSignatureNeeded)
        return AccountModel(id: UUID(), address: address, avatar: avatar, title: title, subtitle: subtitle, signatureStatus: signatureStatus)
    }
}
