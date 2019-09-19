//
//  TransactionDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailViewModel {
    
    func configureReceivedTransaction(_ view: TransactionDetailView, with transaction: Transaction, for account: Account) {
        guard let payment = transaction.payment else {
            return
        }
        
        configureTransactionStatus(for: transaction, in: view)
        
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.transactionOpponentView.titleLabel.text = "send-algos-from".localized
        view.userAccountView.explanationLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(transaction.fee.toAlgos)
        
        if let round = transaction.round {
            view.lastRoundView.detailLabel.text = "\(round)"
        }
        
        if let contact = transaction.contact {
            view.transactionOpponentView.state = .contact(contact)
            view.transactionOpponentView.actionMode = .qrView
        } else {
            view.transactionOpponentView.state = .address(address: transaction.from, amount: nil)
        }
        
        view.transactionAmountView.algosAmountView.mode = .positive(payment.amount.toAlgos)
        
        if let rewards = transaction.payment?.rewards, rewards > 0 {
            view.rewardView.isHidden = false
            view.rewardView.algosAmountView.amountLabel.text = "\(rewards.toAlgos)"
        }
    }
    
    func configureSentTransaction(_ view: TransactionDetailView, with transaction: Transaction, for account: Account) {
        guard let payment = transaction.payment else {
            return
        }
        
        configureTransactionStatus(for: transaction, in: view)
        
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.userAccountView.explanationLabel.text = "send-algos-from".localized
        view.transactionOpponentView.titleLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(transaction.fee.toAlgos)
        
        if let round = transaction.round {
            view.lastRoundView.detailLabel.text = "\(round)"
        }
        
        if let contact = transaction.contact {
            view.transactionOpponentView.state = .contact(contact)
            view.transactionOpponentView.actionMode = .qrView
        } else {
            view.transactionOpponentView.state = .address(address: payment.toAddress, amount: nil)
        }
        
        view.transactionAmountView.algosAmountView.mode = .negative(payment.amount.toAlgos)
        
        if let rewards = transaction.fromRewards, rewards > 0 {
            view.rewardView.isHidden = false
            view.rewardView.algosAmountView.amountLabel.text = "\(rewards.toAlgos)"
        }
    }
    
    private func configureTransactionStatus(for transaction: Transaction, in view: TransactionDetailView) {
        view.transactionStatusView.detailLabel.text = transaction.status.rawValue
        view.transactionStatusView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        switch transaction.status {
        case .completed:
            view.transactionStatusView.detailLabel.textColor = SharedColors.purple
        default:
            view.lastRoundView.isHidden = true
        }
    }
}
