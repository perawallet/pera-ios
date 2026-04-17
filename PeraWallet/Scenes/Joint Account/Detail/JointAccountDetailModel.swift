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

//   JointAccountDetailModel.swift

import Combine
import pera_wallet_core

protocol JointAccountDetailModelable {
    var viewModel: JointAccountDetailViewModel { get }
}

final class JointAccountDetailViewModel: ObservableObject {
    
    struct AccountModel: Identifiable, Equatable {
        let id: String
        let image: ImageType
        let title: String
        let subtitle: String?
    }
    
    enum ModelError: Error {
        case unableToFetchData(error: Error)
    }
    
    @Published fileprivate(set) var title: String = ""
    @Published fileprivate(set) var subtitle: String?
    @Published fileprivate(set) var addressCount: Int = 0
    @Published fileprivate(set) var threshold: Int = 0
    @Published fileprivate(set) var accountModels: [AccountModel] = []
    @Published fileprivate(set) var error: ModelError?
}

final class JointAccountDetailModel: JointAccountDetailModelable {
    
    // MARK: - Properties
    
    private let account: Account
    private let accountsService: AccountsServiceable
    private let legacyBannerController: BannerController?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties - JointAccountInviteConfirmationOverlayModelable
    
    var viewModel: JointAccountDetailViewModel = JointAccountDetailViewModel()
    
    // MARK: - Initializers
    
    init(account: Account, accountsService: AccountsServiceable, legacyBannerController: BannerController?) {
        self.account = account
        self.accountsService = accountsService
        self.legacyBannerController = legacyBannerController
        
        Task { @MainActor in
            viewModel.title = account.primaryDisplayName
            viewModel.subtitle = account.secondaryDisplayName
            if let jointAccountParticipants = account.jointAccountParticipants {
                viewModel.addressCount = jointAccountParticipants.count
            }
            setupCallbacks()
            await self.fetchData()
        }
    }
    
    // MARK: - Setups
    
    @MainActor
    private func setupCallbacks() {
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] in self?.show(error: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @MainActor
    private func fetchData() async {
        do {
            let result = try await accountsService.fetchJointAccountDetail(address: account.address)
            handle(detailResult: result)
        } catch {
            viewModel.error = .unableToFetchData(error: error)
        }
    }
    
    @MainActor
    private func handle(detailResult: JointAccountDetailRequestResponse) {
        viewModel.threshold = detailResult.threshold
        viewModel.addressCount = detailResult.participantAddresses.count
        viewModel.accountModels = detailResult.participantAddresses.compactMap(makeAccountModel)
    }
    
    @MainActor
    private func makeAccountModel(from address: String) -> JointAccountDetailViewModel.AccountModel {
        if let enrichedAccount = accountsService.accounts.value.first(where: { $0.address == address }) {
            return JointAccountDetailViewModel.AccountModel(
                id: enrichedAccount.address,
                image: .icon(data: AccountIconProvider.iconData(account: enrichedAccount)),
                title: enrichedAccount.titles.primary,
                subtitle: enrichedAccount.titles.secondary
            )
        }
        if let account = accountsService.account(address: address) {
            return JointAccountDetailViewModel.AccountModel(
                id: account.address,
                image: .uiImage(account.typeImage),
                title: account.primaryDisplayName,
                subtitle: account.secondaryDisplayName
            )
        }
        if let contact = try? ContactsManager.fetchContact(address: address) {
            return JointAccountDetailViewModel.AccountModel(
                id: address,
                image: .placeholderUserIconData,
                title: contact.name ?? address.shortAddressDisplay,
                subtitle: address.shortAddressDisplay
            )
        }
        return JointAccountDetailViewModel.AccountModel(
            id: address,
            image: .placeholderUserIconData,
            title: address.shortAddressDisplay,
            subtitle: nil
        )
    }
    
    private func show(error: JointAccountDetailViewModel.ModelError) {
        
        let title = String(localized: "title-error")
        let message: String
        
        switch error {
        case .unableToFetchData:
            message = String(localized: "error-joint-account-pending-transaction-unable-to-fetch-data")
        }
        
        legacyBannerController?.presentErrorBanner(title: title, message: message)
    }
}
