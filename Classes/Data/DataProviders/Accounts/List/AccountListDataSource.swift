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
    
    private var accounts = [Account]()
    
    // TODO: Added accounts for test. Should be removed after SDK integration.
    override init() {
        super.init()
        
        for index in 0...10 {
            let account = Account(address: "\(index)")
            account.name = "Account \(index)"
            account.amount = 123456
            
            accounts.append(account)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == accounts.count {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AccountsTotalDisplayCell.reusableIdentifier,
                for: indexPath) as? AccountsTotalDisplayCell else {
                    fatalError("Index path is out of bounds")
            }
            
            // TODO: Add total amount string
            viewModel.configure(cell, with: "1234567")
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountViewCell.reusableIdentifier,
            for: indexPath) as? AccountViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            
            viewModel.configure(cell, with: account)
        }
        
        return cell
    }
}
