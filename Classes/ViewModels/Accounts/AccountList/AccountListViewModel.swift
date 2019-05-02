//
//  AccountListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListViewModel {
    
    func configure(_ cell: AccountViewCell, with account: Account) {
        cell.contextView.nameLabel.text = account.name
        
        if account.amount > 0 {
            cell.contextView.algoImageView.tintColor = SharedColors.green
            cell.contextView.amountLabel.textColor = SharedColors.green
            cell.contextView.amountLabel.text = "\(account.amount.toAlgos)"
        } else if account.amount == 0 {
            cell.contextView.algoImageView.tintColor = SharedColors.black
            cell.contextView.amountLabel.textColor = SharedColors.black
            cell.contextView.amountLabel.text = "\(account.amount.toAlgos)"
        } else {
            cell.contextView.algoImageView.tintColor = SharedColors.blue
            cell.contextView.amountLabel.textColor = SharedColors.blue
            cell.contextView.amountLabel.text = "\(account.amount.toAlgos)"
        }
        
        if let amount = account.amount.toAlgos.toDecimalStringForLabel {
            cell.contextView.amountLabel.text = amount
        }
    }
    
    func configure(_ cell: AccountsTotalDisplayCell, with totalAmount: String) {
        cell.contextView.amountLabel.text = totalAmount
    }
}
