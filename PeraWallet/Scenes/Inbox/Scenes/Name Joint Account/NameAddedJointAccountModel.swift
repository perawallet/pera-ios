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

//   NameAddedJointAccountModel.swift

import Combine

final class NameAddedJointAccountModel: CreateJointAccountNameAccountModelable {
    
    // MARK: - Properties
    
    private let jointAccountAddress: String
    private let inboxService: InboxServiceable
    private let accountsService: AccountsServiceable
    private var cancellables = Set<AnyCancellable>()
    
    var isAccountDuplicate: Bool = false
    
    @MainActor private var writableViewModel: CreateJointAccountNameAccountViewModelWritable { viewModel as CreateJointAccountNameAccountViewModelWritable }
    
    // MARK: - Properties - CreateJointAccountNameAccountModelable
    
    @MainActor private(set) var viewModel: CreateJointAccountNameAccountViewModel = CreateJointAccountNameAccountViewModel()
    
    // MARK: - Initialisers
    
    init(jointAccountAddress: String, inboxService: InboxServiceable, accountsService: AccountsServiceable) {
        self.jointAccountAddress = jointAccountAddress
        self.inboxService = inboxService
        self.accountsService = accountsService
        
        Task { @MainActor in
            setupViewModel()
            setupCallbacks()
        }
    }
    
    // MARK: - Setups
    
    @MainActor
    private func setupViewModel() {
        let nextAccountNumber = accountsService.accounts.value.filter { $0.type == .joint }.count + 1
        viewModel.name = String(localized: "create-joint-account-name-account-text-field-initial-name-\(nextAccountNumber)")
    }
    
    @MainActor
    private func setupCallbacks() {
        viewModel.$name
            .map { !$0.isEmpty }
            .sink { [weak self] in self?.writableViewModel.update(isValidName: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - CreateJointAccountNameAccountModelable
    
    @MainActor
    func createJointAccount() {
        
        writableViewModel.update(isWaitingForResponse: true)
        
        Task {
            do {
                try await inboxService.acceptAccountImportRequest(jointAccountAddress: jointAccountAddress, name: viewModel.name)
                viewModel.update(action: .success)
            } catch {
                viewModel.update(error: .unabletoAcceptTransaction)
                writableViewModel.update(isWaitingForResponse: false)
            }
        }
    }
    
}
