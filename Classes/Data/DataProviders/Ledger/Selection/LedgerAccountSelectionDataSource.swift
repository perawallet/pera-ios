// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LedgerAccountSelectionDataSource.swift

import UIKit

class LedgerAccountSelectionDataSource: NSObject {
    
    weak var delegate: LedgerAccountSelectionDataSourceDelegate?
    
    private let accountsFetchGroup = DispatchGroup()
    
    private let api: AlgorandAPI
    private var accounts = [Account]()
    
    private let ledger: LedgerDetail
    private let ledgerAccounts: [Account]
    private let isMultiSelect: Bool
    
    private var rekeyedAccounts: [String: [Account]] = [:]
    
    init(api: AlgorandAPI, ledger: LedgerDetail, accounts: [Account], isMultiSelect: Bool) {
        self.api = api
        self.ledger = ledger
        self.ledgerAccounts = accounts
        self.isMultiSelect = isMultiSelect
        super.init()
    }
}

extension LedgerAccountSelectionDataSource {
    func loadData() {
        for (index, account) in ledgerAccounts.enumerated() {
            account.type = .ledger
            account.ledgerDetail = ledger
            account.ledgerDetail?.indexInLedger = index
            self.accounts.append(account)
            fetchRekeyedAccounts(of: account.address)
        }
        
        accountsFetchGroup.notify(queue: .main) {
            self.delegate?.ledgerAccountSelectionDataSource(self, didFetch: self.accounts)
        }
    }
    
    private func fetchRekeyedAccounts(of address: String) {
        accountsFetchGroup.enter()
        
        api.fetchRekeyedAccounts(of: address) { response in
            switch response {
            case let .success(rekeyedAccountsResponse):
                self.rekeyedAccounts[address] = rekeyedAccountsResponse.accounts
                rekeyedAccountsResponse.accounts.forEach { account in
                    account.type = .rekeyed
                    if let authAddress = account.authAddress {
                        account.addRekeyDetail(self.ledger, for: authAddress)
                    }
                    self.accounts.append(account)
                }
            case .failure:
                self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
            }
            
            self.accountsFetchGroup.leave()
        }
    }
}

extension LedgerAccountSelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let account = accounts[safe: indexPath.item],
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LedgerAccountCell.reusableIdentifier,
                for: indexPath
            ) as? LedgerAccountCell {
            cell.delegate = self
            let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
            cell.bind(LedgerAccountSelectionViewModel(account: account, isMultiSelect: isMultiSelect, isSelected: isSelected))
            return cell
        }
        fatalError("Index path is out of bounds")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LedgerAccountSelectionHeaderSupplementaryView.reusableIdentifier,
                for: indexPath
        ) as? LedgerAccountSelectionHeaderSupplementaryView {
            headerView.bind(LedgerAccountSelectionHeaderSupplementaryViewModel(accounts: accounts))
            return headerView
        }
        
        fatalError("Unexpected element kind")
    }
}

extension LedgerAccountSelectionDataSource: LedgerAccountCellDelegate {
    func ledgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: LedgerAccountCell) {
        delegate?.ledgerAccountSelectionDataSource(self, didTapMoreInfoFor: ledgerAccountCell)
    }
}

extension LedgerAccountSelectionDataSource {
    var isEmpty: Bool {
        return accounts.isEmpty
    }
    
    func account(at index: Int) -> Account? {
        return accounts[safe: index]
    }
    
    func rekeyedAccounts(for account: String) -> [Account]? {
        return rekeyedAccounts[account]
    }
    
    func ledgerAccountIndex(for address: String) -> Int? {
        return accounts.firstIndex { account -> Bool in
            account.type == .ledger && account.address == address
        }
    }
    
    func clear() {
        accounts.removeAll()
    }
    
    func saveSelectedAccounts(_ indexes: [IndexPath]) {
        indexes.forEach { indexPath in
            if let account = accounts[safe: indexPath.item] {
                if var localAccount = api.session.accountInformation(from: account.address) {
                    localAccount.type = account.type
                    setupLedgerDetails(of: &localAccount, from: account)

                    api.session.authenticatedUser?.updateAccount(localAccount)
                    api.session.updateAccount(account)
                } else {
                    setupLocalAccount(from: account)
                }
            }
        }
    }
    
    private func setupLocalAccount(from account: Account) {
        var localAccount = AccountInformation(address: account.address, name: account.address.shortAddressDisplay(), type: account.type)
        setupLedgerDetails(of: &localAccount, from: account)

        let user: User
        
        if let authenticatedUser = api.session.authenticatedUser {
            user = authenticatedUser
            user.addAccount(localAccount)
        } else {
            user = User(accounts: [localAccount])
        }
        
        api.session.addAccount(Account(accountInformation: localAccount))
        api.session.authenticatedUser = user
    }

    private func setupLedgerDetails(of localAccount: inout AccountInformation, from account: Account) {
        if let authAddress = account.authAddress {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .rekeyed))
            localAccount.addRekeyDetail(account.ledgerDetail ?? ledger, for: authAddress)
        } else {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .ledger))
            localAccount.ledgerDetail = account.ledgerDetail
        }
    }
}

protocol LedgerAccountSelectionDataSourceDelegate: class {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    )
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource)
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didTapMoreInfoFor cell: LedgerAccountCell
    )
}
