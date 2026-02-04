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

//   InboxModel.swift

import Combine
import pera_wallet_core

final class InboxViewModel {
    
    enum RowType: Hashable {
        case jointAccountImport(model: JointAccountImportRequestModel)
        case jointAccountSend(model: JointAccountSignRequestModel)
        case asset(model: AlgorandStandardAssetInboxModel)
    }
    
    struct JointAccountImportRequestModel: Hashable, Identifiable {
        let id: String
        let isUnread: Bool
        let title: AttributedString
        let timestamp: Date
    }
    
    struct JointAccountSignRequestModel: Hashable, Identifiable {
        let id: String
        let title: AttributedString
        let timestamp: Date
        let signedTransactionsText: String
        let deadline: Date
    }
    
    struct AlgorandStandardAssetInboxModel: Hashable, Identifiable {
        let id: String
        let icon: ImageType
        let title: String
        let primaryAccesory: String
    }
    
    enum Action {
        case moveToImportJointAccountScene(jointAccountAddress: String, subtitle: String, threshold: Int, accountModels: [JointAccountInviteConfirmationOverlayViewModel.AccountModel])
        case moveToRequestSendScene
        case moveToAssetDetailsScene(address: String, requestCount: Int)
    }
    
    enum ErrorMessage {
        case unableToParseImportRequest
        case unableToParseSendRequest
        case unableToIgnoreTransaction
    }
    
    @Published fileprivate(set) var rows: [RowType] = []
    @Published fileprivate(set) var action: Action?
    @Published fileprivate(set) var errorMessage: ErrorMessage?
}

protocol InboxModelable {
    var viewModel: InboxViewModel { get }
    func requestAction(identifier: InboxRowIdentifier)
    func ignoreJointAccountInvitation(address: String) async -> Bool
    func markMessagesAsRead()
}

final class InboxModel: InboxModelable {
    
    // MARK: - Properties - InboxModelable
    
    let viewModel: InboxViewModel = InboxViewModel()
    
    // MARK: - Properties
    
    private let inboxService: InboxServiceable
    private let accountsService: AccountsServiceable
    private let accountDataProvider: AccountDataProvider
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisers
    
    init(inboxService: InboxServiceable, accountsService: AccountsServiceable, legacySessionManager: Session, legacyFeatureFlagService: FeatureFlagServicing) {
        self.inboxService = inboxService
        self.accountsService = accountsService
        accountDataProvider = AccountDataProvider(legacySessionManager: legacySessionManager, legacyFeatureFlagService: legacyFeatureFlagService)
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        Publishers.CombineLatest3(inboxService.jointAccountImportRequests.publisher.removeDuplicates(), inboxService.jointAccountSignRequests.publisher.removeDuplicates(), inboxService.algorandStandardAssetInboxes.publisher.removeDuplicates())
            .map {
                let jointAccountImports = $0
                    .compactMap { [weak self] in self?.jointAccountImportRequestViewModel(model: $0) }
                    .map { InboxViewModel.RowType.jointAccountImport(model: $0) }
                
                let jointAccountSigns = $1
                    .compactMap { [weak self] in self?.jointAccountSignRequestViewModel(model: $0) }
                    .map { InboxViewModel.RowType.jointAccountSend(model: $0) }
                
                let algorandStandardAssetInboxes = $2
                    .filter { $0.requestCount > 0 }
                    .compactMap { [weak self] in self?.algorandStandardAssetInboxModel(model: $0) }
                    .map { InboxViewModel.RowType.asset(model: $0) }
                
                return jointAccountImports + jointAccountSigns + algorandStandardAssetInboxes
            }
            .sink { [weak self] in self?.viewModel.rows = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - InboxModelable
    
    func requestAction(identifier: InboxRowIdentifier) {
        
        switch identifier {
        case let .import(uniqueIdentifier):
            handleInboxAction(identifier: uniqueIdentifier)
        case .sendRequest:
            break // FIXME: Send requset feature will be implemented later
        case let .asset(uniqueIdentifier):
            guard let assetData = inboxService.algorandStandardAssetInboxes.value.first(where: { $0.address == uniqueIdentifier }) else { return }
            viewModel.action = .moveToAssetDetailsScene(address: assetData.address, requestCount: assetData.requestCount)
        }
    }
    
    func ignoreJointAccountInvitation(address: String) async -> Bool {
        do {
            try await inboxService.ignoreAccountImportRequest(jointAccountAddress: address)
            return true
        } catch {
            viewModel.errorMessage = .unableToIgnoreTransaction
            return false
        }
    }
    
    func markMessagesAsRead() {
        PeraUserDefaults.watchedJointAccountInvitations = inboxService.jointAccountImportRequests.value.map(\.address)
    }
    
    // MARK: - Handlers
    
    private func jointAccountImportRequestViewModel(model: MultiSigAccountObject) -> InboxViewModel.JointAccountImportRequestModel? {
        
        let title: AttributedString
        
        do {
            title = try AttributedString(localizedMarkdown: "inbox-joint-account-import-request-title-\(model.address.shortAddressDisplay)")
        } catch {
            viewModel.errorMessage = .unableToParseImportRequest
            return nil
        }
        
        let watchedJointAccountInvitations = PeraUserDefaults.watchedJointAccountInvitations ?? []
        let isUnread = !watchedJointAccountInvitations.contains(model.address)
        
        return InboxViewModel.JointAccountImportRequestModel(id: model.address, isUnread: isUnread, title: title, timestamp: model.creationDatetime)
    }
    
    private func jointAccountSignRequestViewModel(model: SignRequestObject) -> InboxViewModel.JointAccountSignRequestModel? {
        nil // FIXME: Send requset feature will be implemented later
    }
    
    private func algorandStandardAssetInboxModel(model: ASAInboxMeta) -> InboxViewModel.AlgorandStandardAssetInboxModel? {
        guard let account = accountsService.accounts.value.first(where: { $0.address == model.address }) else { return nil }
        let iconData = AccountIconProvider.iconData(account: account)
        let title = String(localized: "incoming-asa-accounts-screen-cell-title-\(model.requestCount)")
        return InboxViewModel.AlgorandStandardAssetInboxModel(id: model.address, icon: .icon(data: iconData), title: title, primaryAccesory: account.titles.primary)
    }
    
    private func accountModel(address: String) -> JointAccountInviteConfirmationOverlayViewModel.AccountModel {
        
        if let contact = try? ContactsManager.fetchContact(address: address), let contactData = ContactDataProvider.data(contact: contact) {
            return JointAccountInviteConfirmationOverlayViewModel.AccountModel(id: address, image: contactData.image, title: contactData.title, subtitle: contactData.subtitle)
        }
        
        let account = accountsService.accounts.value.first(where: { $0.address == address })
        let title = account?.titles.primary ?? address.shortAddressDisplay
        let subtitle = account?.titles.secondary
        
        return JointAccountInviteConfirmationOverlayViewModel.AccountModel(id: address, image: .placeholderIconData, title: title, subtitle: subtitle)
    }
    
    private func handleInboxAction(identifier: String) {
        guard let importRequest = inboxService.jointAccountImportRequests.value.first(where: { $0.address == identifier }) else { return }
        let accountModels = importRequest.participantAddresses.compactMap { [weak self] in self?.accountModel(address: $0) }
        viewModel.action = .moveToImportJointAccountScene(jointAccountAddress: importRequest.address, subtitle: importRequest.address.shortAddressDisplay, threshold: importRequest.threshold, accountModels: accountModels)
    }
}
