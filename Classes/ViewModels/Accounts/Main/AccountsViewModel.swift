//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SwiftDate

class AccountsViewModel {
    
    func configure(_ view: AccountsHeaderView, with account: Account) {
        view.algosAmountLabel.text = "\(account.amount.toAlgos)"
    }
    
    func configure(_ cell: TransactionHistoryCell, with transaction: Transaction) {
        cell.contextView.transactionDetailLabel.text = transaction.identifier
        
        if transaction.amount > 0 {
            cell.contextView.transactionAmountView.mode = .positive(transaction.amount)
        } else {
            cell.contextView.transactionAmountView.mode = .negative(-transaction.amount)
        }
        
        let formattedDate = Date().toFormat("MMMM dd, yyyy")
        
        cell.contextView.dateLabel.text = formattedDate
        
        cell.contextView.accountNamelabel.text = ""
    }
}
