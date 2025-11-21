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

//   CreateJointAccountAddAccountModel.swift

import UIKit
import Combine
import pera_wallet_core

private struct CurrencyFormatterSettings: LocalCurrency {
    let id: CurrencyID
    let name: String? = nil
    let symbol: String?
}

final class CreateJointAccountAddAccountViewModel: ObservableObject {
    
    enum Action {
        case selectAccount
    }
    
    enum SectionID: Int {
        case accounts
        case contacts
        case generic
        case manualAddress
        case nfd
    }
    
    enum AccountRowType: Hashable {
        case normal(model: AccountModel)
        case add(model: SimplifiedAccountModel)
    }
    
    enum ErrorMessage: Error {
        case unableToFetchNFDs(error: Error)
        case unableToFetchContacts(error: Error)
    }
    
    struct SectionModel: Identifiable {
        let id: SectionID
        let title: String?
        let rows: [AccountRowType]
    }
    
    struct SimplifiedAccountModel: Hashable {
        let id: String
        let title: String
        let subtitle: String?
    }
    
    struct AccountModel: Hashable {
        let address: String
        let title: String
        let subtitle: String?
        let primaryValue: String
        let secondaryValue: String
        let image: ImageType
        let isContact: Bool
    }
    
    @Published var searchText: String = ""
    @Published fileprivate(set) var accountsListSections: [SectionModel] = []
    @Published fileprivate(set) var selectedAccount: AddedAccountData?
    @Published fileprivate(set) var error: ErrorMessage?
}

protocol CreateJointAccountAddAccountModelable {
    
    var viewModel: CreateJointAccountAddAccountViewModel { get }
    
    func pasteFromClipboard()
    func select(normalAccount: CreateJointAccountAddAccountViewModel.AccountModel)
    func select(specialAccount: CreateJointAccountAddAccountViewModel.SimplifiedAccountModel)
}

final class CreateJointAccountAddAccountModel: CreateJointAccountAddAccountModelable {
    
    // MARK: - Properties - CreateJointAccountAddAccountModelable
    
    let viewModel = CreateJointAccountAddAccountViewModel()
    
    // MARK: - Properties
    
    private let accountsService: AccountsServiceable
    private let currencyService: CurrencyServiceable
    private let nfdService: NonFungibleDomainServiceable
    
    private let algoCurrencyFormatter: CurrencyFormatter = {
        let formatter = CurrencyFormatter()
        formatter.currency = AlgoLocalCurrency()
        return formatter
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var rawContacts: [Contact] = []
    @Published private var nfdAccount: CreateJointAccountAddAccountViewModel.SimplifiedAccountModel?
    @Published private var accounts: [CreateJointAccountAddAccountViewModel.AccountModel] = []
    @Published private var contacts: [CreateJointAccountAddAccountViewModel.AccountModel] = []
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServiceable, currencyService: CurrencyServiceable, nfdService: NonFungibleDomainServiceable) {
        self.accountsService = accountsService
        self.currencyService = currencyService
        self.nfdService = nfdService
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        viewModel.$searchText
            .sink { [weak self] in
                self?.fetchNonFungableDomain(name: $0)
                self?.fetchContacts(name: $0)
            }
            .store(in: &cancellables)
        
        let accountsPublisher = accountsService.accounts.publisher
            .removeDuplicates()
            .map { $0.filter { $0.type != .joint }}
        
        Publishers.CombineLatest3(accountsPublisher, currencyService.selectedCurrencyData.publisher.removeDuplicates(), viewModel.$searchText)
            .map { [weak self] accounts, currencyData, searchText in
                accounts
                    .filter {
                        guard !searchText.isEmpty else { return true }
                        return $0.address.range(of: searchText, options: .caseInsensitive) != nil || $0.titles.primary.range(of: searchText, options: .caseInsensitive) != nil
                    }
                    .sorted { $0.sortingIndex < $1.sortingIndex }
                    .compactMap { self?.accountModel(account: $0, currencyData: currencyData) }
            }
            .sink { [weak self] in self?.accounts = $0 }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($rawContacts, viewModel.$searchText)
            .map { contacts, searchText in
                contacts
                    .filter {
                        guard !searchText.isEmpty else { return true }
                        return $0.address?.range(of: searchText, options: .caseInsensitive) != nil || $0.name?.range(of: searchText, options: .caseInsensitive) != nil
                    }
                    .compactMap { [weak self] in self?.accountModel(contact: $0) }
                    .sorted { $0.title < $1.title }
            }
            .sink { [weak self] in
                self?.contacts = $0
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4($accounts, $contacts, $nfdAccount, viewModel.$searchText)
            .compactMap { [weak self] accounts, contacts, nfdAccount, searchText -> [CreateJointAccountAddAccountViewModel.SectionModel]? in
                
                guard let self else { return nil }
                
                guard !searchText.isEmpty else {
                    return [
                        self.section(id: .accounts, title: String(localized: "create-joint-account-add-account-section-accounts"), accounts: accounts),
                        self.section(id: .contacts, title: String(localized: "create-joint-account-add-account-section-contacts"), accounts: contacts)
                    ]
                }
                
                let allAccounts = accounts + contacts
                
                guard allAccounts.isEmpty else { return [self.genericSection(accounts: allAccounts)] }
                guard !searchText.isValidatedAddress else { return [self.genericSectionWithManualAddress(address: searchText)] }
                guard let nfdAccount else { return [] }
                return [self.genericSectionForNFD(address: nfdAccount.id, name: nfdAccount.title)]
            }
            .map { $0.filter { !$0.rows.isEmpty }}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.viewModel.accountsListSections = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    private func fetchNonFungableDomain(name: String) {
        
        guard name.split(separator: ".").count >= 2 else {
            nfdAccount = nil
            return
        }
        
        Task {
            do {
                let response = try await nfdService.nonFungibleDomainData(name: name)
                guard let nfdData = response.first else {
                    nfdAccount = nil
                    return
                }
                nfdAccount = CreateJointAccountAddAccountViewModel.SimplifiedAccountModel(id: nfdData.address, title: name, subtitle: nfdData.address.shortAddressDisplay)
            } catch {
                Task { @MainActor in
                    viewModel.error = .unableToFetchNFDs(error: error)
                }
            }
        }
    }
    
    private func fetchContacts(name: String) {
        
        let predicate: NSPredicate?
        
        if name.isEmpty {
            predicate = nil
        } else {
            predicate = NSPredicate(format: "name contains[c] %@", name)
        }
        
        Contact.fetchAll(entity: Contact.entityName, with: predicate) { [weak self] in
            guard let self else { return }
            switch $0 {
            case .result:
                break
            case let .results(objects):
                let contacts = objects as? [Contact] ?? []
                self.rawContacts = contacts
            case let .error(error):
                self.viewModel.error = .unableToFetchContacts(error: error)
            }
        }
    }
    
    // MARK: - Actions - CreateJointAccountAddAccountModelable
    
    func pasteFromClipboard() {
        viewModel.searchText = UIPasteboard.general.string ?? ""
    }
    
    func select(normalAccount: CreateJointAccountAddAccountViewModel.AccountModel) {
        
        let isUserAccount = accountsService.accounts.value
            .first { $0.address == normalAccount.address }
            .map { $0.isValid && $0.type != .watch }
        
        guard let isUserAccount else { return }
        
        viewModel.selectedAccount = AddedAccountData(
            address: normalAccount.address,
            image: normalAccount.image,
            title: normalAccount.title,
            subtitle: normalAccount.subtitle,
            isEditable: normalAccount.isContact,
            isUserAccount: isUserAccount
        )
    }
    
    func select(specialAccount: CreateJointAccountAddAccountViewModel.SimplifiedAccountModel) {
        viewModel.selectedAccount = AddedAccountData(
            address: specialAccount.id,
            image: .placeholderIconData,
            title: specialAccount.title,
            subtitle: specialAccount.subtitle,
            isEditable: true,
            isUserAccount: false
        )
    }
    
    // MARK: - Handlers
    
    private func section(id: CreateJointAccountAddAccountViewModel.SectionID, title: String, accounts: [CreateJointAccountAddAccountViewModel.AccountModel]) -> CreateJointAccountAddAccountViewModel.SectionModel {
        let rows = accounts.map { CreateJointAccountAddAccountViewModel.AccountRowType.normal(model: $0) }
        return CreateJointAccountAddAccountViewModel.SectionModel(id: id, title: title, rows: rows)
    }
    
    private func genericSection(accounts: [CreateJointAccountAddAccountViewModel.AccountModel]) -> CreateJointAccountAddAccountViewModel.SectionModel {
        let rows = accounts.map { CreateJointAccountAddAccountViewModel.AccountRowType.normal(model: $0) }
        return CreateJointAccountAddAccountViewModel.SectionModel(id: .generic, title: nil, rows: rows)
    }
    
    private func genericSectionWithManualAddress(address: String) -> CreateJointAccountAddAccountViewModel.SectionModel {
        let model = CreateJointAccountAddAccountViewModel.SimplifiedAccountModel(id: address, title: address.shortAddressDisplay, subtitle: nil)
        let rows = [CreateJointAccountAddAccountViewModel.AccountRowType.add(model: model)]
        return CreateJointAccountAddAccountViewModel.SectionModel(id: .manualAddress, title: nil, rows: rows)
    }
    
    private func genericSectionForNFD(address: String, name: String) -> CreateJointAccountAddAccountViewModel.SectionModel {
        let model = CreateJointAccountAddAccountViewModel.SimplifiedAccountModel(id: address, title: name, subtitle: address.shortAddressDisplay)
        let rows = [CreateJointAccountAddAccountViewModel.AccountRowType.add(model: model)]
        return CreateJointAccountAddAccountViewModel.SectionModel(id: .nfd, title: nil, rows: rows)
    }
    
    private func accountModel(account: PeraAccount, currencyData: CurrencyData?) -> CreateJointAccountAddAccountViewModel.AccountModel {
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.currency = CurrencyFormatterSettings(id: .fiat(localValue: currencyData?.id), symbol: currencyData?.symbol)
        
        var fiatValue: Double = 0.0
        
        if let rawExchangeRate = currencyData?.exchangeRate, let exchangeRate = Double(rawExchangeRate) {
            fiatValue = account.amount * exchangeRate
        }
        
        let formatterAlgoValue = algoCurrencyFormatter.format(account.amount) ?? ""
        let formattedFiatValue = currencyFormatter.format(fiatValue) ?? ""
        let isAlgoPrimaryCurrency = currencyService.isAlgoPrimaryCurrency.value
        
        return CreateJointAccountAddAccountViewModel.AccountModel(
            address: account.address,
            title: account.titles.primary,
            subtitle: account.titles.secondary,
            primaryValue: isAlgoPrimaryCurrency ? formatterAlgoValue : formattedFiatValue,
            secondaryValue: isAlgoPrimaryCurrency ? formattedFiatValue : formatterAlgoValue,
            image: .icon(data: AccountIconProvider.iconData(account: account)),
            isContact: false
        )
    }
    
    private func accountModel(contact: Contact) -> CreateJointAccountAddAccountViewModel.AccountModel? {
        guard let address = contact.address else { return nil }
        guard let contactData = ContactDataProvider.data(contact: contact) else { return nil }
        return CreateJointAccountAddAccountViewModel.AccountModel(address: address, title: contactData.title, subtitle: contactData.subtitle, primaryValue: "", secondaryValue: "", image: contactData.image, isContact: true)
    }
}
