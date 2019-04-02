//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SwiftDate

enum TransactionDisplayMode {
    case accounts
    case contacts
}

class AccountsViewModel {
    
    func configure(_ view: AccountsHeaderView, with account: Account) {
        view.algosAmountLabel.text = "\(account.amount)"
    }
    
    func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for mode: TransactionDisplayMode) {
        cell.contextView.transactionDetailLabel.text = transaction.title
        
        if transaction.amount > 0 {
            cell.contextView.transactionAmountView.mode = .positive(transaction.amount)
        } else {
            cell.contextView.transactionAmountView.mode = .negative(-transaction.amount)
        }
        
        let formattedDate = transaction.date.toFormat("MMMM dd, yyyy")
        
        cell.contextView.dateLabel.text = formattedDate
        
        if mode == .accounts {
            cell.contextView.accountNamelabel.text = transaction.accountName
        } else {
            cell.contextView.accountNamelabel.isHidden = true
        }
    }
}
