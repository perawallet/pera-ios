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
    
    private let dispatchGroup = DispatchGroup()
    private let assetGroup = DispatchGroup()
    
    private let viewModel = AccountsViewModel()
    
    private let api: API
    private var accounts = [Account]()
    
    private let ledger: LedgerDetail
    
    init(api: API, ledger: LedgerDetail) {
        self.api = api
        self.ledger = ledger
        super.init()
    }
}

extension LedgerAccountSelectionDataSource {
    func loadData() {
        guard let address = ledger.address else {
            return
        }
        
        fetchLedgerAccount(for: address)
        fetchRekeyedAccounts(ofLedger: address)

        assetGroup.enter()
        dispatchGroup.notify(queue: .global()) {
            self.accounts.forEach { account in
                if account.isThereAnyDifferentAsset() {
                    self.fetchAssets(for: account)
                }
            }
            self.assetGroup.leave()
        }
        
        assetGroup.notify(queue: .main) {
            self.delegate?.ledgerAccountSelectionDataSource(self, didFetch: self.accounts)
        }
    }
    
    private func fetchLedgerAccount(for address: String) {
        dispatchGroup.enter()
        
        api.fetchAccount(with: AccountFetchDraft(publicKey: address)) { response in
            switch response {
            case let .success(accountResponse):
                accountResponse.account.type = .ledger
                self.accounts.insert(accountResponse.account, at: 0)
            case let .failure(_, indexerError):
                if indexerError?.containsAccount(address) ?? false {
                    self.accounts.insert(Account(address: address, name: address.shortAddressDisplay()), at: 0)
                } else {
                    self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
                }
            }
            
            self.dispatchGroup.leave()
        }
    }
    
    private func fetchRekeyedAccounts(ofLedger address: String) {
        dispatchGroup.enter()
        
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
            
            self.dispatchGroup.leave()
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
                assetGroup.enter()
                
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
                    
                    self.assetGroup.leave()
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
            
            let isEnabled = !shouldSetDisabled(at: indexPath)
            
            addLedgerAccountSelectionTitleView(to: cell, isEnabled: isEnabled, account: account)
            addAlgoView(to: cell, isEnabled: isEnabled, account: account)
            addAssetViews(to: cell, for: account, isEnabled: isEnabled)
            addLedgerAccountSelectionRekeyedInfoViewIfNeeded(to: cell, isEnabled: isEnabled, account: account)
            
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
    private func addLedgerAccountSelectionTitleView(to cell: AccountSelectionCell, isEnabled: Bool, account: Account) {
        let ledgerAccountSelectionTitleView = LedgerAccountSelectionTitleView()
        LedgerAccountSelectionTitleViewModel(account: account, isEnabled: isEnabled).configure(ledgerAccountSelectionTitleView)
        cell.contextView.addView(ledgerAccountSelectionTitleView)
    }
    
    private func addAlgoView(to cell: AccountSelectionCell, isEnabled: Bool, account: Account) {
        let algoView = AlgoAssetView()
        algoView.setEnabled(isEnabled)
        algoView.amountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
        cell.contextView.addView(algoView)
    }
    
    private func addAssetViews(to cell: AccountSelectionCell, for account: Account, isEnabled: Bool) {
        for (index, assetDetail) in account.assetDetails.enumerated() {
            guard let asset = account.assets?[index] else {
                continue
            }
            
            if assetDetail.isVerified {
                addVerifiedAssetViews(to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
            } else {
                addUnverifiedAssetViews(to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
            }
        }
    }
    
    private func addVerifiedAssetViews(
        to cell: AccountSelectionCell,
        isEnabled: Bool,
        assetDetail: AssetDetail,
        asset: Asset
    ) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(AssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(OnlyNameAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(OnlyUnitNameAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnnamedAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addUnverifiedAssetViews(
        to cell: AccountSelectionCell,
        isEnabled: Bool,
        assetDetail: AssetDetail,
        asset: Asset
    ) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(UnverifiedAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(UnverifiedOnlyNameAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(
                UnverifiedOnlyUnitNameAssetCell(),
                to: cell,
                isEnabled: isEnabled,
                assetDetail: assetDetail,
                asset: asset
            )
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnverifiedUnnamedAssetCell(), to: cell, isEnabled: isEnabled, assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addAssetView(
        _ view: BaseAssetCell,
        to cell: AccountSelectionCell,
        isEnabled: Bool,
        assetDetail: AssetDetail,
        asset: Asset
    ) {
        view.contextView.setEnabled(isEnabled)
        viewModel.configure(view, with: assetDetail, and: asset)
        cell.contextView.addView(view)
    }
    
    private func addLedgerAccountSelectionRekeyedInfoViewIfNeeded(to cell: AccountSelectionCell, isEnabled: Bool, account: Account) {
        if !isEnabled {
            let ledgerAccountSelectionRekeyedInfoView = LedgerAccountSelectionRekeyedInfoView()
            LedgerAccountSelectionRekeyedInfoViewModel(account: account).configure(ledgerAccountSelectionRekeyedInfoView)
            cell.contextView.addView(ledgerAccountSelectionRekeyedInfoView)
            cell.contextView.state = .disabled
        }
    }
    
    @objc
    private func notifyDelegateToCopyAuthAddress() {
        delegate?.ledgerAccountSelectionDataSourceDidCopyAuthAddress(self)
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
    
    func shouldSetDisabled(at indexPath: IndexPath) -> Bool {
        if let account = accounts[safe: indexPath.item],
            indexPath.item == 0,
            account.hasAuthAccount() {
            return true
        }
        return false
    }
    
    func saveSelectedAccounts(_ indexes: [IndexPath]) {
        indexes.forEach { indexPath in
            if let account = accounts[safe: indexPath.item],
                api.session.authenticatedUser?.account(address: account.address) == nil {
                setupLocalAccount(from: account)
            }
        }
    }
    
    private func setupLocalAccount(from account: Account) {
        let localAccount = AccountInformation(
            address: account.address,
            name: account.address.shortAddressDisplay() ?? "",
            type: account.type,
            ledgerDetail: ledger
        )
        
        let user: User
        
        if let authenticatedUser = api.session.authenticatedUser {
            user = authenticatedUser
            user.addAccount(localAccount)
        } else {
            user = User(accounts: [localAccount])
        }
        
        let remoteAccount = Account(address: localAccount.address, type: localAccount.type, ledgerDetail: ledger, name: localAccount.name)
        api.session.addAccount(remoteAccount)
        api.session.authenticatedUser = user
    }
}

protocol LedgerAccountSelectionDataSourceDelegate: class {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    )
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource)
    func ledgerAccountSelectionDataSourceDidCopyAuthAddress(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource)
}
