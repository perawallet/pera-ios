//
//  TransactionDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailViewModel {
    func configureReceivedTransaction(
        _ view: TransactionDetailView,
        with transaction: Transaction,
        and assetDetail: AssetDetail?,
        for account: Account
    ) {
        configureTransactionStatus(for: transaction, in: view)
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.transactionOpponentView.titleLabel.text = "send-algos-from".localized
        view.userAccountView.explanationLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(amount: transaction.fee.toAlgos)
        
        if let round = transaction.round {
            view.lastRoundView.detailLabel.text = "\(round)"
        }
        
        if let contact = transaction.contact {
            view.transactionOpponentView.state = .contact(contact)
            view.transactionOpponentView.actionMode = .qrView
        } else {
            view.transactionOpponentView.state = .address(address: transaction.from, amount: nil)
        }
        
        if let assetTransaction = transaction.assetTransfer,
            let assetDetail = assetDetail {
            view.transactionAmountView.algosAmountView.algoIconImageView.removeFromSuperview()
            
            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            
            if amount == 0 {
                view.transactionAmountView.algosAmountView.mode = .normal(
                    amount: amount,
                    assetFraction: assetDetail.fractionDecimals
                )
            } else {
                view.transactionAmountView.algosAmountView.mode = .positive(
                    amount: amount,
                    assetFraction: assetDetail.fractionDecimals
                )
            }
        } else if let payment = transaction.payment {
            let amount = payment.amountForTransaction().toAlgos
            
            if amount == 0 {
                view.transactionAmountView.algosAmountView.mode = .normal(amount: payment.amountForTransaction().toAlgos)
            } else {
                view.transactionAmountView.algosAmountView.mode = .positive(amount: payment.amountForTransaction().toAlgos)
            }
            
            if let rewards = payment.rewards, rewards > 0 {
                view.rewardView.isHidden = false
                view.rewardView.algosAmountView.amountLabel.text = "\(rewards.toAlgos)"
            }
        }
    }
    
    func configureSentTransaction(
        _ view: TransactionDetailView,
        with transaction: Transaction,
        and assetDetail: AssetDetail?,
        for account: Account
    ) {
        configureTransactionStatus(for: transaction, in: view)
        view.transactionOpponentView.passphraseInputView.inputTextView.isEditable = false
        
        view.userAccountView.detailLabel.text = account.name
        view.userAccountView.explanationLabel.text = "send-algos-from".localized
        view.transactionOpponentView.titleLabel.text = "send-algos-to".localized
        view.transactionIdView.detailLabel.text = transaction.id.identifier
        view.feeView.algosAmountView.mode = .normal(amount: transaction.fee.toAlgos)
        
        if let round = transaction.round {
            view.lastRoundView.detailLabel.text = "\(round)"
        }
        
        if let assetTransaction = transaction.assetTransfer {
            if let contact = transaction.contact {
                view.transactionOpponentView.state = .contact(contact)
                view.transactionOpponentView.actionMode = .qrView
            } else {
                view.transactionOpponentView.state = .address(address: assetTransaction.receiverAddress ?? "", amount: nil)
            }
        }
        
        if let assetTransaction = transaction.assetTransfer,
            let assetDetail = assetDetail {
            
            view.transactionAmountView.algosAmountView.algoIconImageView.removeFromSuperview()
            
            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            
            if amount == 0 {
                view.transactionAmountView.algosAmountView.mode = .normal(
                    amount: amount,
                    assetFraction: assetDetail.fractionDecimals
                )
            } else {
                view.transactionAmountView.algosAmountView.mode = .negative(
                    amount: amount,
                    assetFraction: assetDetail.fractionDecimals
                )
            }
        } else if let payment = transaction.payment {
            if let contact = transaction.contact {
                view.transactionOpponentView.state = .contact(contact)
                view.transactionOpponentView.actionMode = .qrView
            } else {
                view.transactionOpponentView.state = .address(address: payment.toAddress, amount: nil)
            }
            
            let amount = payment.amountForTransaction().toAlgos
            
            if amount == 0 {
                view.transactionAmountView.algosAmountView.mode = .normal(amount: payment.amountForTransaction().toAlgos)
            } else {
                view.transactionAmountView.algosAmountView.mode = .negative(amount: payment.amountForTransaction().toAlgos)
            }
        }
        
        if let rewards = transaction.fromRewards, rewards > 0 {
            view.rewardView.isHidden = false
            view.rewardView.algosAmountView.amountLabel.text = "\(rewards.toAlgos)"
        }
    }
    
    private func configureTransactionStatus(for transaction: Transaction, in view: TransactionDetailView) {
        guard let status = transaction.status else {
            return
        }
        
        view.transactionStatusView.detailLabel.text = status.rawValue
        view.transactionStatusView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        switch status {
        case .completed:
            view.transactionStatusView.detailLabel.textColor = SharedColors.purple
            view.transactionStatusView.pendingSpinnerView.stop()
            view.lastRoundView.isHidden = false
        case .pending:
            view.transactionStatusView.pendingSpinnerView.show()
            view.lastRoundView.isHidden = true
        default:
            view.lastRoundView.isHidden = true
        }
    }
}
