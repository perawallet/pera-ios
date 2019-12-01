//
//  AccountListDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListDataSource: NSObject, UICollectionViewDataSource {
    
    private let viewModel = AccountListViewModel()
    
    private(set) var accounts = [Account]()
    private let mode: AccountListViewController.Mode
    
    init(mode: AccountListViewController.Mode) {
        self.mode = mode
        super.init()
        
        guard let user = UIApplication.shared.appConfiguration?.session.authenticatedUser else {
            return
        }
        
        switch mode {
        case .assetCount:
            accounts.append(contentsOf: user.accounts)
        case let .amount(assetDetail):
            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: user.accounts)
                return
            }
            
            let filteredAccounts = user.accounts.filter { account -> Bool in
                account.assetDetails.contains { detail -> Bool in
                     assetDetail.index == detail.index
                }
            }
            accounts = filteredAccounts
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountViewCell.reusableIdentifier,
            for: indexPath) as? AccountViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            viewModel.configure(cell, with: account, for: mode)
        }
        
        return cell
    }
}
