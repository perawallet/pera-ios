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
    
    override init() {
        super.init()
        
        guard let user = UIApplication.shared.appConfiguration?.session.authenticatedUser else {
            return
        }
        
        accounts.append(contentsOf: user.accounts)
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
            
            viewModel.configure(cell, with: account)
        }
        
        return cell
    }
}
