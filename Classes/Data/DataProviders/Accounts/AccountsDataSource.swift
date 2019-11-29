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
    
    private(set) var accounts = [Account]()
    
    override init() {
        super.init()
        
        guard let user = UIApplication.shared.appConfiguration?.session.authenticatedUser else {
            return
        }
        
        accounts.append(contentsOf: user.accounts)
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
        return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
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
    
    private func dequeueAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetCell.reusableIdentifier,
            for: indexPath) as? AssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.section < accounts.count {
            let account = accounts[indexPath.section]
            let assetDetail = account.assetDetails[indexPath.item - 1]
            if let assets = account.assets,
                let assetIndex = assetDetail.index,
                let asset = assets[assetIndex] {
                viewModel.configure(cell, with: assetDetail, and: asset)
            }
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
