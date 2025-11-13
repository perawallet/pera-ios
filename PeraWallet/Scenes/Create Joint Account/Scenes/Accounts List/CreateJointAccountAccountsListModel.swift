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

//   CreateJointAccountAccountsListModel.swift

import Combine
import pera_wallet_core

final class CreateJointAccountAccountsListViewModel: ObservableObject {
    
    enum Action {
        case moveNext(participantAddresses: [String])
    }
    
    struct AccountModel: Hashable {
        let id: UUID
        let address: String
        let image: ImageType
        let title: String
        let subtitle: String?
        let isEditable: Bool
    }
    
    @Published fileprivate(set) var accounts: [AccountModel] = []
    @Published fileprivate(set) var canAddAccounts: Bool = true
    @Published fileprivate(set) var isValidated: Bool = false
    @Published fileprivate(set) var action: Action?
}

protocol CreateJointAccountAccountsListModelable {
    
    var viewModel: CreateJointAccountAccountsListViewModel { get }
    
    func add(account: AddedAccountData)
    func remove(identifier: UUID)
    func update(identifier: UUID, account: AddedAccountData)
    func requestData()
}

final class CreateJointAccountAccountsListModel: CreateJointAccountAccountsListModelable {
    
    // MARK: - Constants
    
    private static let minAccountsForValidation = 2
    private static let maxAccountsCount = 16
    
    // MARK: - Properties - CreateJointAccountAccountsListModelable
    
    let viewModel = CreateJointAccountAccountsListViewModel()
    
    // MARK: - Properties
    
    private let accountsService: AccountsServiceable
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServiceable) {
        self.accountsService = accountsService
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        viewModel.$accounts
            .map { $0.count >= Self.minAccountsForValidation }
            .sink { [weak self] in self?.viewModel.isValidated = $0 }
            .store(in: &cancellables)
        
        viewModel.$accounts
            .map { $0.count < Self.maxAccountsCount }
            .sink { [weak self] in self?.viewModel.canAddAccounts = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - CreateJointAccountAccountsListModelable
    
    func add(account: AddedAccountData) {
        
        var title = account.title
        
        if account.isUserAccount {
            title += " " + String(localized: "create-joint-account-account-list-user-account-suffix")
        }
        
        let model = CreateJointAccountAccountsListViewModel.AccountModel(id: UUID(), address: account.address, image: account.image, title: title, subtitle: account.subtitle, isEditable: account.isEditable)
        viewModel.accounts.append(model)
    }
    
    func remove(identifier: UUID) {
        viewModel.accounts.removeAll { $0.id == identifier }
    }
    
    func update(identifier: UUID, account: AddedAccountData) {
        guard let index = viewModel.accounts.firstIndex(where: { $0.id == identifier }) else { return }
        let model = CreateJointAccountAccountsListViewModel.AccountModel(id: identifier, address: account.address, image: account.image, title: account.title, subtitle: account.subtitle, isEditable: account.isEditable)
        viewModel.accounts[index] = model
    }
    
    func requestData() {
        viewModel.action = .moveNext(participantAddresses: viewModel.accounts.map(\.address))
    }
}

extension CreateJointAccountAccountsListViewModel.AccountModel: Identifiable {
    static func == (lhs: CreateJointAccountAccountsListViewModel.AccountModel, rhs: CreateJointAccountAccountsListViewModel.AccountModel) -> Bool { lhs.id == rhs.id }
}
