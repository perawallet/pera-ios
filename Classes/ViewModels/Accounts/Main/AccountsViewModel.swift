//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewModel {
    
    func configure(_ view: AccountsHeaderView, with account: Account) {
        view.algosAmountLabel.text = "\(account.amount)"
    }
    
    func configure(_ cell: TransactionHistoryCell, with transaction: Transaction) {
        cell.contextView.transactionDetailLabel.text = transaction.title
        
        if transaction.amount > 0 {
            cell.contextView.transactionAmountView.mode = .positive(transaction.amount)
        } else {
            cell.contextView.transactionAmountView.mode = .negative(-transaction.amount)
        }
        
        cell.contextView.dateLabel.text = "\(transaction.date.timeIntervalSince1970)"
        cell.contextView.accountNamelabel.text = transaction.accountName
    }
}
