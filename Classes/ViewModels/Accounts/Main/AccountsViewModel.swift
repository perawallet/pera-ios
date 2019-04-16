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
    
    var lastRound: Int64?
    
    var currentAccount: Account?
    
    func configure(_ view: AccountsHeaderView, with account: Account) {
        view.algosAmountLabel.text = "\(account.amount.toAlgos)"
    }
    
    func configure(_ view: AccountsSmallHeaderView, with account: Account) {
        view.algosAmountLabel.text = "\(account.amount.toAlgos)"
    }
    
    func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for contact: Contact? = nil) {
        guard let currentAccount = currentAccount,
            let payment = transaction.payment else {
                return
        }
        
        if payment.toAddress == currentAccount.address {
            if let contact = contact {
                cell.contextView.titleLabel.text = contact.name
                cell.contextView.subtitleLabel.text = transaction.from
            } else {
                cell.contextView.titleLabel.text = transaction.from
                cell.contextView.subtitleLabel.isHidden = true
            }
            
            cell.contextView.transactionAmountView.mode = .positive(payment.amount.toAlgos)
        } else {
            if let contact = contact {
                cell.contextView.titleLabel.text = contact.name
                cell.contextView.subtitleLabel.text = payment.toAddress
            } else {
                cell.contextView.titleLabel.text = payment.toAddress
                cell.contextView.subtitleLabel.isHidden = true
            }
            
            cell.contextView.transactionAmountView.mode = .negative(payment.amount.toAlgos)
        }
        
        let formattedDate = findDate(from: transaction.lastRound).toFormat("MMMM dd, yyyy")
        cell.contextView.dateLabel.text = formattedDate
    }
    
    private func findDate(from round: Int64) -> Date {
        guard let lastRound = lastRound else {
            return Date()
        }
    
        let roundDifference = lastRound - round
        let dayDifference = roundDifference / 17280
        
        guard let transactionDate = Calendar.current.date(byAdding: .day, value: Int(-dayDifference), to: Date()) else {
            return Date()
        }
        
        return transactionDate
    }
}
