//
//  AccountSelectionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountSelectionViewModel {
    
    func size(for accounts: [Account], at indexPath: IndexPath) -> CGSize {
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            
            guard let width = account.name?.width(usingFont: UIFont.font(.avenir, withWeight: .bold(size: 11.0))) else {
                return .zero
            }
            return CGSize(width: width + 10.0, height: 80.0)
        } else {
            return CGSize(width: 110.0, height: 80.0)
        }
    }
    
    func configure(_ cell: AccountNameCell, for accounts: [Account], at indexPath: IndexPath, with selectedAccount: Account?) {
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            cell.contextView.titleLabel.text = account.name
            
            guard let selectedAccount = selectedAccount else {
                return
            }
            
            if account.address == selectedAccount.address {
                cell.contextView.set(selected: true)
            }
        } else {
            cell.contextView.titleLabel.textColor = SharedColors.turquois
            cell.contextView.titleLabel.text = "accounts-add-account".localized
        }
    }
    
    func configure(selected account: Account, among accounts: [Account], in collectionView: UICollectionView) {
        guard let index = accounts.firstIndex(of: account),
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? AccountNameCell else {
            return
        }
        
        cell.contextView.set(selected: true)
    }
}
