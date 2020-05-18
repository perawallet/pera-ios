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
        if let status = transaction.status {
             view.statusView.setTransactionStatus(status)
        }
        
        view.userView.setTitle("transaction-detail-to".localized)
        if let accountName = account.name {
            view.userView.setDetail(accountName)
        }
        
        view.feeView.setAmountViewMode(.normal(amount: transaction.fee.toAlgos))

        if let round = transaction.round {
            view.roundView.setDetail("\(round)")
        }
        
        view.opponentView.setTitle("transaction-detail-from".localized)
        setOpponent(for: transaction, with: transaction.from, in: view)
        
        if let assetTransaction = transaction.assetTransfer,
            let assetDetail = assetDetail {
            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)

            if amount == 0 {
                view.amountView.setAmountViewMode(.normal(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals))
            } else {
                view.amountView.setAmountViewMode(.positive(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals))
            }
            
            view.rewardView.removeFromSuperview()
        } else if let payment = transaction.payment {
            let amount = payment.amountForTransaction().toAlgos

            if amount == 0 {
                view.amountView.setAmountViewMode(.normal(amount: amount))
            } else {
                view.amountView.setAmountViewMode(.positive(amount: amount))
            }

            setReward(for: transaction, in: view)
        }
        
        view.idView.setDetail(transaction.id.identifier)
        setNote(for: transaction, in: view)
    }
    
    func configureSentTransaction(
        _ view: TransactionDetailView,
        with transaction: Transaction,
        and assetDetail: AssetDetail?,
        for account: Account
    ) {
        if let status = transaction.status {
             view.statusView.setTransactionStatus(status)
        }
        
        setReward(for: transaction, in: view)
        
        view.userView.setTitle("transaction-detail-from".localized)
        if let accountName = account.name {
            view.userView.setDetail(accountName)
        }
        
        view.feeView.setAmountViewMode(.normal(amount: transaction.fee.toAlgos))

        if let round = transaction.round {
            view.roundView.setDetail("\(round)")
        }
        
        view.opponentView.setTitle("transaction-detail-to".localized)
        
        if let assetTransaction = transaction.assetTransfer,
            let assetDetail = assetDetail {
            setOpponent(for: transaction, with: assetTransaction.receiverAddress ?? "", in: view)
            
            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)

            if amount == 0 {
                view.amountView.setAmountViewMode(.normal(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals))
            } else {
                view.amountView.setAmountViewMode(.negative(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals))
            }
        } else if let payment = transaction.payment {
            setOpponent(for: transaction, with: payment.toAddress, in: view)
            
            let amount = payment.amountForTransaction().toAlgos

            if amount == 0 {
                view.amountView.setAmountViewMode(.normal(amount: amount))
            } else {
                view.amountView.setAmountViewMode(.negative(amount: amount))
            }
        }
        
        view.idView.setDetail(transaction.id.identifier)
        setNote(for: transaction, in: view)
    }
    
    func setOpponent(for transaction: Transaction, with address: String, in view: TransactionDetailView) {
        if let contact = transaction.contact {
            view.opponentView.setContact(contact)
            view.opponentView.setQRAction()
        } else {
            view.opponentView.setAddContactAction()
            view.opponentView.setName(address)
            view.opponentView.setContactImage(hidden: true)
        }
    }
    
    private func setReward(for transaction: Transaction, in view: TransactionDetailView) {
        if let rewards = transaction.fromRewards, rewards > 0 {
            view.rewardView.setAmountViewMode(.normal(amount: rewards.toAlgos))
        } else {
            view.rewardView.removeFromSuperview()
        }
    }
    
    private func setNote(for transaction: Transaction, in view: TransactionDetailView) {
        if let noteData = transaction.noteb64, !noteData.isEmpty {
            let utf8String = String(data: noteData, encoding: .utf8)
            view.noteView.setDetail(utf8String ?? noteData.base64EncodedString())
            view.noteView.setSeparatorView(hidden: true)
        } else {
            view.idView.setSeparatorView(hidden: true)
            view.noteView.removeFromSuperview()
        }
    }
}
