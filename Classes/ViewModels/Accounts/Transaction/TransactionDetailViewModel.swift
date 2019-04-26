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
        
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.transactionOpponentView.titleLabel.text = "send-algos-from".localized
        view.userAccountView.explanationLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(transaction.fee.toAlgos)
        view.lastRoundView.detailLabel.text = "\(transaction.lastRound)"
        
        if let contact = transaction.contact {
            view.transactionOpponentView.state = .contact(contact)
            view.transactionOpponentView.receiverContactView.qrDisplayButton.isHidden = false
            view.transactionOpponentView.receiverContactView.qrDisplayButton.setImage(img("icon-qr-view"), for: .normal)
        } else {
            view.transactionOpponentView.state = .address(address: transaction.from, amount: nil)
        }
        
        view.transactionAmountView.mode = .positive(payment.amount.toAlgos)
    }
    
    func configureSentTransaction(_ view: TransactionDetailView, with transaction: Transaction, for account: Account) {
        guard let payment = transaction.payment else {
            return
        }
        
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.userAccountView.explanationLabel.text = "send-algos-from".localized
        view.transactionOpponentView.titleLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(transaction.fee.toAlgos)
        view.lastRoundView.detailLabel.text = "\(transaction.lastRound)"
        
        if let contact = transaction.contact {
            view.transactionOpponentView.state = .contact(contact)
            view.transactionOpponentView.receiverContactView.qrDisplayButton.isHidden = false
            view.transactionOpponentView.receiverContactView.qrDisplayButton.setImage(img("icon-qr-view"), for: .normal)
        } else {
            view.transactionOpponentView.state = .address(address: payment.toAddress, amount: nil)
        }
        
        view.transactionAmountView.mode = .negative(payment.amount.toAlgos)
    }
}
