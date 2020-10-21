//
//  LedgerAccountSelectionDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionDataSource: NSObject {
    
    weak var delegate: LedgerAccountSelectionDataSourceDelegate?
    
    private let accountsFetchGroup = DispatchGroup()
    private let assetsFetchGroup = DispatchGroup()
    
    private let viewModel = AccountsViewModel()
    
    private let api: API
    private var accounts = [Account]()
    
    private let ledger: LedgerDetail
    private let ledgerAddress: String
    
    init(api: API, ledger: LedgerDetail, ledgerAddress: String) {
        self.api = api
        self.ledger = ledger
        self.ledgerAddress = ledgerAddress
        super.init()
    }
}

extension LedgerAccountSelectionDataSource {
    func loadData() {
        fetchLedgerAccount(for: ledgerAddress)
        fetchRekeyedAccounts(ofLedger: ledgerAddress)

        assetsFetchGroup.enter()
        accountsFetchGroup.notify(queue: .global()) {
            self.accounts.forEach { account in
                if account.isThereAnyDifferentAsset() {
                    self.fetchAssets(for: account)
                }
            }
            self.assetsFetchGroup.leave()
        }
        
        assetsFetchGroup.notify(queue: .main) {
            self.delegate?.ledgerAccountSelectionDataSource(self, didFetch: self.accounts)
        }
    }
    
    private func fetchLedgerAccount(for address: String) {
        accountsFetchGroup.enter()
        
        api.fetchAccount(with: AccountFetchDraft(publicKey: address)) { response in
            switch response {
            case let .success(accountResponse):
                accountResponse.account.type = .ledger
                self.accounts.insert(accountResponse.account, at: 0)
            case let .failure(_, indexerError):
                if indexerError?.containsAccount(address) ?? false {
                    self.accounts.insert(Account(address: address, type: .ledger, name: address.shortAddressDisplay()), at: 0)
                } else {
                    self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
                }
            }
            
            self.accountsFetchGroup.leave()
        }
    }
    
    private func fetchRekeyedAccounts(ofLedger address: String) {
        accountsFetchGroup.enter()
        
        api.fetchRekeyedAccounts(of: address) { response in
            switch response {
            case let .success(rekeyedAccountsResponse):
                rekeyedAccountsResponse.accounts.forEach { account in
                    account.type = .rekeyed
                    self.accounts.append(account)
                }
            case .failure:
                self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
            }
            
            self.accountsFetchGroup.leave()
        }
    }
    
    private func fetchAssets(for account: Account) {
        guard let assets = account.assets else {
            return
        }
        
        for asset in assets {
            if let assetDetail = api.session.assetDetails[asset.id] {
                account.assetDetails.append(assetDetail)
            } else {
                assetsFetchGroup.enter()
                
                self.api.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self.composeAssetDetail(
                            assetDetailResponse.assetDetail,
                            of: account,
                            with: asset.id
                        )
                    case .failure:
                        account.removeAsset(asset.id)
                    }
                    
                    self.assetsFetchGroup.leave()
                }
            }
        }
    }
    
    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64) {
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        api.session.assetDetails[id] = assetDetail
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api.session.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == id
            }) {
            assetDetail.isVerified = true
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
                withReuseIdentifier: AccountSelectionCell.reusableIdentifier,
                for: indexPath
            ) as? AccountSelectionCell {
            
            if isUnselectable(at: indexPath) {
                cell.contextView.state = .unselectable
            }
            
            addLedgerAccountSelectionTitleView(to: cell, isUnselectable: isUnselectable(at: indexPath), account: account)
            addAlgoView(to: cell, for: account)
            addAssetViews(to: cell, for: account)
            
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
            LedgerAccountSelectionHeaderSupplementaryViewModel(accounts: accounts).configure(headerView)
            return headerView
        }
        
        fatalError("Unexpected element kind")
    }
}

extension LedgerAccountSelectionDataSource {
    private func addLedgerAccountSelectionTitleView(to cell: AccountSelectionCell, isUnselectable: Bool, account: Account) {
        let ledgerAccountSelectionTitleView = LedgerAccountSelectionTitleView()
        LedgerAccountSelectionTitleViewModel(account: account, isUnselectable: isUnselectable).configure(ledgerAccountSelectionTitleView)
        cell.contextView.addView(ledgerAccountSelectionTitleView)
    }
    
    private func addAlgoView(to cell: AccountSelectionCell, for account: Account) {
        let algoView = AlgoAssetView()
        algoView.amountLabel.text = account.amount.toAlgos.toAlgosStringForLabel
        cell.contextView.addView(algoView)
    }
    
    private func addAssetViews(to cell: AccountSelectionCell, for account: Account) {
        for (index, assetDetail) in account.assetDetails.enumerated() {
            guard let asset = account.assets?[index] else {
                continue
            }
            
            if assetDetail.isVerified {
                addVerifiedAssetViews(to: cell, assetDetail: assetDetail, asset: asset)
            } else {
                addUnverifiedAssetViews(to: cell, assetDetail: assetDetail, asset: asset)
            }
        }
    }
    
    private func addVerifiedAssetViews(to cell: AccountSelectionCell, assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(AssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(OnlyNameAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(OnlyUnitNameAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnnamedAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addUnverifiedAssetViews(to cell: AccountSelectionCell, assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(UnverifiedAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(UnverifiedOnlyNameAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(UnverifiedOnlyUnitNameAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnverifiedUnnamedAssetCell(), to: cell, assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addAssetView(
        _ view: BaseAssetCell,
        to cell: AccountSelectionCell,
        assetDetail: AssetDetail,
        asset: Asset
    ) {
        viewModel.configure(view, with: assetDetail, and: asset)
        cell.contextView.addView(view)
    }
}

extension LedgerAccountSelectionDataSource {
    var isEmpty: Bool {
        return accounts.isEmpty
    }
    
    func account(at index: Int) -> Account? {
        return accounts[safe: index]
    }
    
    func clear() {
        accounts.removeAll()
    }
    
    func isUnselectable(at indexPath: IndexPath) -> Bool {
        return indexPath.item == 0
    }
    
    func saveSelectedAccounts(_ indexes: [IndexPath]) {
        /// Add ledger's account to local accounts
        addLedgerAccountIfNeeded()
        
        indexes.forEach { indexPath in
            if let account = accounts[safe: indexPath.item] {
                if let localAccount = api.session.accountInformation(from: account.address) {
                    localAccount.type = .rekeyed
                    api.session.authenticatedUser?.updateAccount(localAccount)
                    
                    account.type = .rekeyed
                    api.session.updateAccount(account)
                } else {
                    setupLocalAccount(from: account, isLedgerAccount: false)
                }
            }
        }
    }
    
    private func setupLocalAccount(from account: Account, isLedgerAccount: Bool) {
        let localAccount = AccountInformation(
            address: account.address,
            name: account.address.shortAddressDisplay(),
            type: account.type,
            ledgerDetail: isLedgerAccount ? ledger : nil
        )
        
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
    
    private func addLedgerAccountIfNeeded() {
        if let account = account(at: 0),
            api.session.accountInformation(from: account.address) == nil {
            setupLocalAccount(from: account, isLedgerAccount: true)
        }
    }
}

protocol LedgerAccountSelectionDataSourceDelegate: class {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    )
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource)
}
