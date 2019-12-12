//
//  AssetDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SwiftDate

class AssetDetailViewModel {
    
    var lastRound: Int64?
    
    private(set) var account: Account
    private(set) var assetDetail: AssetDetail?
    
    init(account: Account, assetDetail: AssetDetail?) {
        self.account = account
        self.assetDetail = assetDetail
    }
}

extension AssetDetailViewModel {
    func configure(_ view: AssetDetailHeaderView, with account: Account, and assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            view.dollarValueLabel.isHidden = true
            view.rewardTotalAmountView.removeFromSuperview()
            view.assetNameLabel.attributedText = assetDetail.assetDisplayName(
                with: UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)),
                isIndexIncluded: true
            )
            
            guard let amount = account.amount(for: assetDetail) else {
                return
            }
            view.algosAmountLabel.text = amount.toDecimalStringForLabel
        } else {
            view.algosAmountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
            
            let totalRewards: UInt64 = (account.rewards ?? 0)
            view.rewardTotalAmountView.algosAmountView.amountLabel.text = totalRewards.toAlgos.toDecimalStringForLabel
        }
    }
    
    func configure(_ view: AssetDetailSmallHeaderView, with account: Account, and assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            guard let amount = account.amount(for: assetDetail) else {
                return
            }
            view.algosAmountLabel.text = amount.toDecimalStringForLabel
        } else {
            view.algosAmountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
        }
    }
}

extension AssetDetailViewModel {
    func setDollarValue(visible: Bool, in view: AssetDetailHeaderView, for currentValue: Double) {
        view.algosAmountLabel.isHidden = visible
        view.dollarAmountLabel.isHidden = !visible
        view.dollarImageView.isHidden = !visible
        
        if visible {
            view.assetNameLabel.text = "accounts-dollar-value-title".localized
            view.assetNameLabel.textColor = SharedColors.darkGray
            view.dollarValueLabel.backgroundColor = SharedColors.darkGray
            view.dollarValueLabel.textColor = .white
            view.dollarAmountLabel.text = currentValue.toCryptoCurrencyStringForLabel
            view.dollarValueLabel.layer.borderWidth = 0.0
        } else {
            view.assetNameLabel.text = "accounts-algos-available-title".localized
            view.assetNameLabel.textColor = SharedColors.black
            view.dollarValueLabel.backgroundColor = .white
            view.dollarValueLabel.textColor = .black
            view.dollarValueLabel.layer.borderWidth = 1.0
        }
    }
}

extension AssetDetailViewModel {
    func configure(_ view: TransactionHistoryContextView, with transaction: Transaction, for contact: Contact? = nil) {
        if let pendingTransactionView = view as? PendingTransactionView,
            transaction.status == .pending {
            pendingTransactionView.pendingSpinnerView.show()
        }
        
        if assetDetail != nil {
            guard let assetTransaction = transaction.assetTransfer else {
                return
            }
            
            if assetTransaction.receiverAddress == account.address && assetTransaction.amount == 0 && transaction.type == "axfer" {
                view.titleLabel.text = "asset-creation-fee-title".localized
                view.subtitleLabel.isHidden = true
                view.transactionAmountView.mode = .negative(assetTransaction.amount.toAlgos)
            } else if assetTransaction.receiverAddress == account.address {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .positive(Double(assetTransaction.amount))
            } else {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .negative(Double(assetTransaction.amount))
            }
        } else {
            guard let payment = transaction.payment else {
                if let assetTransaction = transaction.assetTransfer,
                    assetTransaction.receiverAddress == account.address && assetTransaction.amount == 0 && transaction.type == "axfer" {
                    view.titleLabel.text = "asset-creation-fee-title".localized
                    view.subtitleLabel.isHidden = true
                    view.transactionAmountView.mode = .negative(assetTransaction.amount.toAlgos)
                }
                return
            }
            
            if payment.toAddress == account.address {
                configure(view, with: contact, and: transaction.from)
                view.transactionAmountView.mode = .positive(payment.amountForTransaction().toAlgos)
            } else {
                configure(view, with: contact, and: payment.toAddress)
                view.transactionAmountView.mode = .negative(payment.amountForTransaction().toAlgos)
            }
        }
        
        let formattedDate = findDate(from: transaction.lastRound).toFormat("MMMM dd, yyyy")
        view.dateLabel.text = formattedDate
    }
    
    private func configure(_ view: TransactionHistoryContextView, with contact: Contact?, and address: String?) {
        if let contact = contact {
            view.titleLabel.text = contact.name
            view.subtitleLabel.text = contact.address
        } else {
            view.titleLabel.text = address
            view.subtitleLabel.isHidden = true
        }
    }
    
    func configure(_ cell: RewardCell, with reward: Reward) {
        cell.contextView.transactionAmountView.amountLabel.text = reward.amount.toAlgos.toDecimalStringForLabel
    }
}

extension AssetDetailViewModel {
    private func findDate(from round: Int64) -> Date {
        guard let lastRound = lastRound else {
            return Date()
        }
    
        let roundDifference = lastRound - round
        let minuteDifference = roundDifference / 12
        
        if roundDifference <= 0 {
            return Date()
        }
        
        guard let transactionDate = Calendar.current.date(byAdding: .minute, value: Int(-minuteDifference), to: Date()) else {
            return Date()
        }
        
        return transactionDate
    }
}
