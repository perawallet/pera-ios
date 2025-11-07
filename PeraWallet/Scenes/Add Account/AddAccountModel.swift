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

//   AddAccountModel.swift

import Combine
import pera_wallet_core
import SwiftUI

final class AddAccountViewModel: ObservableObject {
    
    enum RowIdentifier {
        case addAccount
        case addJointAccount
        case importWallet
        case watchAccount
        case createUniversalWallet
        case createAlgo256Wallet
    }
    
    struct MenuOptionModel: Identifiable {
        let id: RowIdentifier
        let icon: ImageResource
        let title: LocalizedStringKey
        let description: LocalizedStringKey
        let isNewBadgeVisible: Bool
    }
    
    @Published var isMenuExpanded: Bool = false
    @Published fileprivate(set) var menuRows: [MenuOptionModel] = []
    @Published fileprivate(set) var termsAndConditionsText: AttributedString = ""
}

protocol AddAccountModelable {
    var viewModel: AddAccountViewModel { get }
}

final class AddAccountModel: AddAccountModelable {
    
    // MARK: - Properties
    
    private let legacyConfiguration: ViewControllerConfiguration
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Properties - AddAccountModelable
    
    let viewModel: AddAccountViewModel = AddAccountViewModel()
    
    // MARK: - Initialisers
    
    init(legacyConfiguration: ViewControllerConfiguration) {
        self.legacyConfiguration = legacyConfiguration
        setupInitialData()
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupInitialData() {
        let termsAndServices = AlgorandWeb.termsAndServices.rawValue
        let privacyPolicy = AlgorandWeb.privacyPolicy.rawValue
        let markdown = String(localized: "add-account-terms-and-conditions-\(termsAndServices)-privacy-policy-\(privacyPolicy)")
        guard let termsAndConditionsText = try? AttributedString(markdown: markdown) else { return }
        viewModel.termsAndConditionsText = termsAndConditionsText
    }
    
    private func setupCallbacks() {
        
        viewModel.$isMenuExpanded
            .map { [weak self] in
                guard let self else { return [] }
                return $0 ? self.collapsedMenuOptions() + self.expandedMenuOptions() : self.collapsedMenuOptions()
            }
            .sink { [weak self] in self?.viewModel.menuRows = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - AddAccountModelable
    
    func handleAction(rowID: AddAccountViewModel.RowIdentifier) {
        
    }
    
    // MARK: - Factories
    
    private func collapsedMenuOptions() -> [AddAccountViewModel.MenuOptionModel] {
        
        var result: [AddAccountViewModel.MenuOptionModel] = [
            AddAccountViewModel.MenuOptionModel(
                id: .addAccount,
                icon: .Icons.walletAdd,
                title: "add-account-option-add-account-title",
                description: "add-account-option-add-account-description",
                isNewBadgeVisible: false
            )
        ]
        
        if legacyConfiguration.featureFlagService.isEnabled(.jointAccountEnabled) {
            result.append(AddAccountViewModel.MenuOptionModel(
                id: .addJointAccount,
                icon: .Icons.group,
                title: "add-account-option-add-joint-account-title",
                description: "add-account-option-add-joint-account-description",
                isNewBadgeVisible: true)
            )
        }
        
        result.append(
            AddAccountViewModel.MenuOptionModel(
                id: .importWallet,
                icon: .Icons.walletImport,
                title: "add-account-option-import-account-title",
                description: "add-account-option-import-account-description",
                isNewBadgeVisible: false)
        )
        return result
    }
    
    private func expandedMenuOptions() -> [AddAccountViewModel.MenuOptionModel] {
        [
            AddAccountViewModel.MenuOptionModel(
                id: .watchAccount,
                icon: .Icons.watchAccount,
                title: "add-account-option-watch-account-title",
                description: "add-account-option-watch-account-description",
                isNewBadgeVisible: false
            ),
            AddAccountViewModel.MenuOptionModel(
                id: .createUniversalWallet,
                icon: .Icons.walletUniversal,
                title: "add-account-option-create-universal-wallet-title",
                description: "add-account-option-create-universal-wallet-description",
                isNewBadgeVisible: false
            ),
            AddAccountViewModel.MenuOptionModel(
                id: .createAlgo256Wallet,
                icon: .Icons.wallet,
                title: "add-account-option-create-algo25-wallet-title",
                description: "add-account-option-create-algo25-wallet-description",
                isNewBadgeVisible: false
            )
        ]
    }
}
