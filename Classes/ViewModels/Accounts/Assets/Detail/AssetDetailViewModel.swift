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
            view.dollarValueImageView.isHidden = true
            view.algosImageView.removeFromSuperview()
            if !assetDetail.isVerified {
                view.verifiedImageView.removeFromSuperview()
            }
            view.rewardTotalAmountView.removeFromSuperview()
            view.assetNameLabel.text = assetDetail.getDisplayNames().0
            view.assetIdLabel.isHidden = false
            view.assetIdLabel.text = "ID \(assetDetail.id)"
            
            guard let amount = account.amount(for: assetDetail) else {
                return
            }
            view.algosAmountLabel.text = amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        } else {
            view.algosAmountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
            view.verifiedImageView.isHidden = false
            let totalRewards: UInt64 = (account.pendingRewards ?? 0)
            view.rewardTotalAmountView.setReward(amount: totalRewards.toAlgos.toDecimalStringForLabel ?? "0.00")
        }
    }
    
    func configure(_ view: AssetDetailTitleView, with account: Account, and assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            guard let amount = account.amount(for: assetDetail) else {
                return
            }
            view.setDetail("\(amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "") \(assetDetail.getAssetCode())")
        } else {
            view.setDetail("\(account.amount.toAlgos.toDecimalStringForLabel ?? "") ALGO")
        }
    }
}

extension AssetDetailViewModel {
    func setDollarValue(visible: Bool, in view: AssetDetailHeaderView, for currentValue: Double) {
        view.algosAmountLabel.isHidden = visible
        view.dollarAmountLabel.isHidden = !visible
        view.verifiedImageView.isHidden = visible
        
        if visible {
            view.assetNameLabel.text = "accounts-dollar-value-title".localized
            view.assetNameLabel.textColor = SharedColors.detailText
            view.dollarAmountLabel.text = currentValue.toFractionStringForLabel(fraction: 2)
            view.algosImageView.isHidden = true
        } else {
            view.assetNameLabel.text = "accounts-algos-available-title".localized
            view.assetNameLabel.textColor = SharedColors.detailText
            view.algosImageView.isHidden = false
        }
    }
}

extension AssetDetailViewModel {
    func configure(_ view: TransactionHistoryContextView, with transaction: Transaction, for contact: Contact? = nil) {
        if let assetDetail = assetDetail {
            guard let assetTransaction = transaction.assetTransfer else {
                return
            }
            
            if assetTransaction.receiverAddress == account.address && assetTransaction.amount == 0 && transaction.type == .assetTransfer {
                view.setContact("asset-creation-fee-title".localized)
                view.subtitleLabel.isHidden = true
                view.transactionAmountView.mode = .negative(amount: transaction.fee.toAlgos)
            } else if assetTransaction.receiverAddress == account.address {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .positive(
                    amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    fraction: assetDetail.fractionDecimals
                )
            } else {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .negative(
                    amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    fraction: assetDetail.fractionDecimals
                )
            }
        } else {
            guard let payment = transaction.payment else {
                if let assetTransaction = transaction.assetTransfer,
                    assetTransaction.receiverAddress == account.address
                    && assetTransaction.amount == 0
                    && transaction.type == .assetTransfer {
                    view.setContact("asset-creation-fee-title".localized)
                    view.subtitleLabel.isHidden = true
                    view.transactionAmountView.mode = .negative(amount: transaction.fee.toAlgos)
                }
                let formattedDate = transaction.date?.toFormat("MMMM dd, yyyy")
                view.dateLabel.text = formattedDate
                return
            }
            
            if payment.receiver == account.address {
                configure(view, with: contact, and: transaction.sender)
                view.transactionAmountView.mode = .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
            } else {
                configure(view, with: contact, and: payment.receiver)
                view.transactionAmountView.mode = .negative(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
            }
        }
        
        let formattedDate = transaction.date?.toFormat("MMMM dd, yyyy")
        view.dateLabel.text = formattedDate
    }
    
    private func configure(_ view: TransactionHistoryContextView, with contact: Contact?, and address: String?) {
        if let contact = contact {
            view.setContact(contact.name)
            view.subtitleLabel.text = contact.address?.shortAddressDisplay()
        } else if let address = address,
            let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(from: address) {
            view.setContact(localAccount.name)
            view.subtitleLabel.text = address.shortAddressDisplay()
        } else {
            view.setAddress(address)
            view.subtitleLabel.isHidden = true
        }
    }
    
    func configure(_ view: TransactionHistoryContextView, with transaction: PendingTransaction, for contact: Contact? = nil) {
        if let assetDetail = assetDetail {
            if transaction.receiver == account.address && transaction.amount == 0 && transaction.type == .assetTransfer {
                view.setContact("asset-creation-fee-title".localized)
                view.subtitleLabel.isHidden = true
                view.transactionAmountView.mode = .negative(amount: transaction.fee.toAlgos)
            } else if transaction.receiver == account.address {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .positive(
                    amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    fraction: assetDetail.fractionDecimals
                )
            } else {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.algoIconImageView.removeFromSuperview()
                view.transactionAmountView.mode = .negative(
                    amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    fraction: assetDetail.fractionDecimals
                )
            }
        } else {
            if transaction.receiver == account.address {
                configure(view, with: contact, and: transaction.sender)
                view.transactionAmountView.mode = .positive(amount: transaction.amount.toAlgos)
            } else {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .negative(amount: transaction.amount.toAlgos)
            }
        }
        
        let formattedDate = Date().toFormat("MMMM dd, yyyy")
        view.dateLabel.text = formattedDate
    }
    
    func configure(_ cell: RewardCell, with reward: Reward) {
        cell.contextView.transactionAmountView.mode = .positive(amount: reward.amount.toAlgos)
        if let formattedDate = reward.date?.toFormat("MMMM dd, yyyy") {
            cell.contextView.setDate(formattedDate)
        }
    }
}
