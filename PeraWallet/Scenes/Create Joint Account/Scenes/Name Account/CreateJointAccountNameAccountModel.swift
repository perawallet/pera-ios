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

//   CreateJointAccountNameAccountModel.swift

import Combine
import pera_wallet_core

protocol CreateJointAccountNameAccountModelable {
    @MainActor var viewModel: CreateJointAccountNameAccountViewModel { get }
    @MainActor func createJointAccount()
    func isAccountDuplicate() -> Bool
}

final class CreateJointAccountNameAccountModel: CreateJointAccountNameAccountModelable {
    
    // MARK: - Properties - CreateJointAccountNameAccountModelable
    
    @MainActor let viewModel: CreateJointAccountNameAccountViewModel = CreateJointAccountNameAccountViewModel()
    
    // MARK: - Properties
    
    private let participantAddresses: [String]
    private let threshold: Int
    private let accountService: AccountsServiceable
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(participantAddresses: [String], threshold: Int, accountService: AccountsServiceable) {
        self.participantAddresses = participantAddresses
        self.threshold = threshold
        self.accountService = accountService
        
        Task { @MainActor in
            setupCallbacks()
            setupInitialName()
        }
    }
    
    // MARK: - Setups
    
    @MainActor
    private func setupCallbacks() {
        viewModel.$name
            .map { !$0.isEmpty }
            .sink { [weak self] in self?.viewModel.update(isValidName: $0) }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func setupInitialName() {
        let nextAccountNumber = accountService.accounts.value.filter { $0.type == .joint }.count + 1
        viewModel.name = String(localized: "create-joint-account-name-account-text-field-initial-name-\(nextAccountNumber)")
    }
    
    // MARK: - Actions
    
    @MainActor
    func createJointAccount() {
        
        viewModel.update(isWaitingForResponse: true)
        
        Task {
            do {
                try await handleCreateAccountFlow()
            } catch let error as CoreApiManager.ApiError {
                viewModel.update(error: .unableToCreateJointAccount(error))
                viewModel.update(isWaitingForResponse: false)
            }
        }
    }
    
    @MainActor
    private func handleCreateAccountFlow() async throws(AccountsService.ActionError) {
        try await accountService.createJointAccount(participants: participantAddresses, threshold: threshold, name: viewModel.name)
        PeraUserDefaults.shouldShowNewAccountAnimation = true
        viewModel.update(action: .success)
    }
    
    func isAccountDuplicate() -> Bool { accountService.hasJointAccount(with: participantAddresses) }
}

