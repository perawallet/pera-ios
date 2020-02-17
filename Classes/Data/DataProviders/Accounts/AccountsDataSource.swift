//
//  AccountsDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsDataSourceDelegate: class {
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapOptionsButtonFor account: Account)
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapAddAssetButtonFor account: Account)
}

class AccountsDataSource: NSObject, UICollectionViewDataSource {
    
    private let viewModel = AccounsViewModel()
    
    weak var delegate: AccountsDataSourceDelegate?
    
    var accounts: [Account] = UIApplication.shared.appConfiguration?.session.accounts ?? []
    
    private var addedAssetDetails: [Account: [AssetDetail]] = [:]
    private var removedAssetDetails: [Account: [AssetDetail]] = [:]
    
    var hasPendingAssetAction: Bool {
        return !addedAssetDetails.isEmpty || !removedAssetDetails.isEmpty
    }
    
    func reload() {
        guard let session = UIApplication.shared.appConfiguration?.session else {
            return
        }
        accounts = session.accounts
        
        filterAddedAssetDetails()
        filterRemovedAssetDetails()
    }
    
    func refresh() {
        accounts.removeAll()
        reload()
    }
    
    func add(assetDetail: AssetDetail, to account: Account) {
        guard let accountIndex = accounts.firstIndex(of: account) else {
            return
        }
        assetDetail.isRecentlyAdded = true
        accounts[accountIndex].assetDetails.append(assetDetail)
        if addedAssetDetails[account] == nil {
            addedAssetDetails[account] = [assetDetail]
        } else {
            addedAssetDetails[account]?.append(assetDetail)
        }
    }
    
    func remove(assetDetail: AssetDetail, from account: Account) {
        guard let accountIndex = accounts.firstIndex(of: account),
            let assetDetailIndex = accounts[accountIndex].assetDetails.firstIndex(of: assetDetail) else {
            return
        }
        assetDetail.isRemoved = true
        accounts[accountIndex].assetDetails[assetDetailIndex] = assetDetail
        if removedAssetDetails[account] == nil {
            removedAssetDetails[account] = [assetDetail]
        } else {
            removedAssetDetails[account]?.append(assetDetail)
        }
    }
    
    func section(for account: Account) -> Int? {
        return accounts.firstIndex(of: account)
    }
    
    func item(for assetDetail: AssetDetail, in account: Account) -> Int? {
        return account.assetDetails.firstIndex(of: assetDetail)
    }
}

extension AccountsDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let account = accounts[section]
        if account.assetDetails.isEmpty {
            return 1
        }
        
        return account.assetDetails.count + 1
    }
}

extension AccountsDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
        }
        return dequeueAssetCells(in: collectionView, cellForItemAt: indexPath)
    }
    
    private func dequeueAlgoAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlgoAssetCell.reusableIdentifier,
            for: indexPath) as? AlgoAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.section < accounts.count {
            let account = accounts[indexPath.section]
            viewModel.configure(cell, with: account)
        }
        
        return cell
    }
    
    private func dequeueAssetCells(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < accounts.count {
            let account = accounts[indexPath.section]
            let assetDetail = account.assetDetails[indexPath.item - 1]
            
            if assetDetail.isRemoved {
                return dequeuePendingAssetCell(in: collectionView, cellForItemAt: indexPath, isRemoved: true)
            } else if assetDetail.isRecentlyAdded {
                return dequeuePendingAssetCell(in: collectionView, cellForItemAt: indexPath, isRemoved: false)
            } else {
                return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
            }
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func dequeuePendingAssetCell(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        isRemoved: Bool
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PendingAssetCell.reusableIdentifier,
            for: indexPath) as? PendingAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        let account = accounts[indexPath.section]
        let assetDetail = account.assetDetails[indexPath.item - 1]
        viewModel.configure(cell, with: assetDetail, isRemoving: isRemoved)
        
        return cell
    }
    
    private func dequeueAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetCell.reusableIdentifier,
            for: indexPath) as? AssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        let account = accounts[indexPath.section]
        let assetDetail = account.assetDetails[indexPath.item - 1]
        
        if let assets = account.assets,
            let assetId = assetDetail.id,
            let asset = assets["\(assetId)"] {
            viewModel.configure(cell, with: assetDetail, and: asset)
        }
        
        return cell
    }
}

extension AccountsDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountHeaderSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            let account = accounts[indexPath.section]
            viewModel.configure(headerView, with: account)
            
            headerView.delegate = self
            headerView.tag = indexPath.section
            
            return headerView
        } else {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountFooterSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountFooterSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            footerView.delegate = self
            footerView.tag = indexPath.section
            
            return footerView
        }
    }
}

extension AccountsDataSource: AccountHeaderSupplementaryViewDelegate {
    func accountHeaderSupplementaryViewDidTapOptionsButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView) {
        if accountHeaderSupplementaryView.tag < accounts.count {
            let account = accounts[accountHeaderSupplementaryView.tag]
            delegate?.accountsDataSource(self, didTapOptionsButtonFor: account)
        }
    }
}

extension AccountsDataSource: AccountFooterSupplementaryViewDelegate {
    func accountFooterSupplementaryViewDidTapAddAssetButton(_ accountFooterSupplementaryView: AccountFooterSupplementaryView) {
        if accountFooterSupplementaryView.tag < accounts.count {
            let account = accounts[accountFooterSupplementaryView.tag]
            delegate?.accountsDataSource(self, didTapAddAssetButtonFor: account)
        }
    }
}

extension AccountsDataSource {
    private func filterAddedAssetDetails() {
        for (addedAccount, addedAssets) in addedAssetDetails {
            guard let accountIndex = accounts.firstIndex(of: addedAccount) else {
                continue
            }
            
            for (index, assetDetail) in addedAssets.enumerated() where assetDetail.isRecentlyAdded {
                if accounts[accountIndex].assetDetails.contains(assetDetail) {
                    var filteredAssets = addedAssets
                    filteredAssets.remove(at: index)
                    addedAssetDetails[addedAccount] = filteredAssets
                    break
                }
            }
        }
    }
    
    private func filterRemovedAssetDetails() {
        for (removedAccount, removedAssets) in removedAssetDetails {
            guard let accountIndex = accounts.firstIndex(of: removedAccount) else {
                continue
            }
            
            for (index, assetDetail) in removedAssets.enumerated() where assetDetail.isRemoved {
                if !accounts[accountIndex].assetDetails.contains(assetDetail) {
                    var filteredAssets = removedAssets
                    filteredAssets.remove(at: index)
                    removedAssetDetails[removedAccount] = filteredAssets
                    break
                }
            }
        }
    }
}
