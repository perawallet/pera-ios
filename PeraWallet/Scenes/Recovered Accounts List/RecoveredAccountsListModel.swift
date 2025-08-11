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

//   RecoveredAccountsListModel.swift

import SwiftUI
import pera_wallet_core

// FIXME: Convert ObservableObject to @Observable macro when min. target will be updated to iOS 17+.
final class RecoveredAccountsListModel: ObservableObject {
    
    struct InputData {
        let authAccount: Account
        let rekeyedAccount: Account
    }
    
    struct AddressViewModel: Identifiable {
        let id: String
        let address: String
        let displayedAddress: String
        let description: String
        let isSelected: Bool
        let accountTypeImageName: String
    }
    
    enum Action: Equatable {
        case showDetails(account: Account, authAccount: Account)
        case endWithSuccess
    }
    
    enum ModelError: Error {
        case noAuthenticatedUser
        case noAccountFound
    }
    
    // MARK: - View Model
    
    @Published private(set) var addressViewModels: [AddressViewModel] = []
    @Published private(set) var isAddressSelected: Bool = false
    @Published private(set) var action: Action?
    @Published private(set) var error: ModelError?
    
    // MARK: - Properties
    
    private let inputData: [InputData]
    private let legacyViewControllerConfiguration: ViewControllerConfiguration
    
    // MARK: - Initialisers
    
    init(inputData: [InputData], legacyViewControllerConfiguration: ViewControllerConfiguration) {
        self.inputData = inputData
        self.legacyViewControllerConfiguration = legacyViewControllerConfiguration
        updateViewModels(inputData: inputData)
    }
    
    // MARK: - View Model - Actions
    
    func toggleSelection(address: String) {
        
        addressViewModels = addressViewModels.map {
            guard $0.address == address else { return $0 }
            return AddressViewModel(id: $0.id, address: $0.address, displayedAddress: $0.displayedAddress, description: $0.description, isSelected: !$0.isSelected, accountTypeImageName: $0.accountTypeImageName)
        }
        
        isAddressSelected = addressViewModels.first { $0.isSelected } != nil
    }
    
    func confirmSelection() {
        
        guard let user = legacyViewControllerConfiguration.session?.authenticatedUser else {
            handle(error: .noAuthenticatedUser)
            return
        }
        
        addressViewModels
            .filter(\.isSelected)
            .map(\.address)
            .compactMap { accountData(address: $0) }
            .map(\.rekeyedAccount)
            .forEach {
                let accountInfo = AccountInformation(
                    address: $0.address,
                    name: $0.address.shortAddressDisplay,
                    isWatchAccount: false,
                    preferredOrder: legacyViewControllerConfiguration.sharedDataController.getPreferredOrderForNewAccount(),
                    isBackedUp: true
                )
                
                if user.account(address: $0.address) != nil {
                    user.updateAccount(accountInfo)
                } else {
                    user.addAccount(accountInfo)
                }
                
                legacyViewControllerConfiguration.analytics.track(.registerAccount(registrationType: .rekeyed))
            }
        
        PeraUserDefaults.shouldShowNewAccountAnimation = true
        action = .endWithSuccess
    }
    
    func requestDetails(address: String) {
        
        guard let accountData = accountData(address: address) else {
            handle(error: .noAccountFound)
            return
        }
        
        action = .showDetails(account: accountData.rekeyedAccount, authAccount: accountData.authAccount)
    }
    
    // MARK: - Handlers
    
    private func updateViewModels(inputData: [InputData]) {
        
        let addedAddresses = legacyViewControllerConfiguration.sharedDataController.sortedAccounts()
            .map(\.value.address)
        
        addressViewModels = inputData
            .map(\.rekeyedAccount)
            .filter { !addedAddresses.contains($0.address) }
            .map { AddressViewModel(id: $0.address, address: $0.address, displayedAddress: $0.address.shortAddressDisplay, description: $0.typeTitle ?? "", isSelected: false, accountTypeImageName: $0.rawTypeImage) }
    }
    
    private func handle(error: ModelError) {
        self.error = error
        legacyViewControllerConfiguration.bannerController?.presentErrorBanner(title: String(localized: "default-error-message"), message: "")
    }
    
    // MARK: - Helpers
    
    private func accountData(address: String) -> InputData? {
        inputData.first { $0.rekeyedAccount.address == address }
    }
}
