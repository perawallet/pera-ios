//
//  BalanceViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SwiftDate

class BalanceViewModel {
    
    func configure(_ view: BalanceView, for user: AuctionUser) {
        if let availableAmount = user.availableAmount?.convertToDollars() {
            view.balanceHeaderView.amountLabel.text = availableAmount
        }
    }
    
    func configure(_ cell: PendingCoinlistTransactionCell, with transaction: CoinlistTransaction) {
        if let description = transaction.description {
            cell.contextView.titleLabel.text = description
        }
        
        if let time = transaction.time,
            let date = Date(time) {
            cell.contextView.dateLabel.text = date.toFormat("MMM dd 'at' H:mm")
        }
        
        if let amount = transaction.amount {
            if let type = transaction.type {
                if type == .deposit {
                    cell.contextView.transactionAmountLabel.textColor = SharedColors.blue
                    cell.contextView.transactionAmountLabel.text = "+\(amount.convertToDollars())"
                } else {
                    cell.contextView.transactionAmountLabel.textColor = SharedColors.darkGray
                    cell.contextView.transactionAmountLabel.text = "-\(amount.convertToDollars())"
                }
            }
        }
    }
    
    func configure(_ cell: PastCoinlistTransactionCell, with transaction: CoinlistTransaction) {
        if let description = transaction.description {
            cell.contextView.titleLabel.text = description
        }
        
        if let time = transaction.time,
            let date = Date(time) {
            cell.contextView.dateLabel.text = date.toFormat("MMM dd 'at' H:mm")
        }
        
        if let amount = transaction.amount {
            if let type = transaction.type {
                if type == .deposit {
                    cell.contextView.transactionAmountLabel.textColor = SharedColors.blue
                    cell.contextView.transactionAmountLabel.text = "+\(amount.convertToDollars())"
                } else {
                    cell.contextView.transactionAmountLabel.textColor = SharedColors.darkGray
                    cell.contextView.transactionAmountLabel.text = "-\(amount.convertToDollars())"
                }
            }
        }
        
        if let balanceAfterTransaction = transaction.balanceAfterTransaction {
            cell.contextView.balanceLabel.text = "\(balanceAfterTransaction.convertToDollars())"
        }
    }
    
    func configure(_ view: USDWireInstructionContextView, with information: USDWireInstruction, for deposit: DepositInstruction) {
        if let amount = deposit.amount.toStringForTwoDecimal {
            view.sendInformationView.detailLabel.text = "$\(amount)"
        }
        
        view.accountInformationView.detailLabel.text = information.accountNumber
        
        if let bankAddress = information.bankAddress,
            let bankName = information.bankName,
            let phone = information.bankPhone {
            view.bankInformationView.detailLabel.text = "\(bankName)\n\(bankAddress)\n\(phone)"
        }
        
        if let creditTo = information.creditTo,
            let beneficiaryAddress = information.beneficiaryAddress {
            view.creditInformationView.detailLabel.text = "\(creditTo)\n\(beneficiaryAddress)"
        }
        
        view.routingInformationView.detailLabel.text = information.routingNumber
        view.swiftInformationView.detailLabel.text = information.swift
        view.referenceLabel.text = information.reference
    }
    
    func configure(
        _ view: BlockchainDepositInstructionContextView,
        with information: BlockchainInstruction,
        for deposit: DepositInstruction
    ) {
        configureAmountText(view, with: information, for: deposit)

        if let address = information.address {
            view.receiverInformationView.detailLabel.text = address
        }
    }
    
    private func configureAmountText(
        _ view: BlockchainDepositInstructionContextView,
        with information: BlockchainInstruction,
        for deposit: DepositInstruction
    ) {
        if let rate = information.rate,
            let amount = (deposit.amount * 100 / Double(rate)).toDecimalStringForLabel,
            let dollarAmount = deposit.amount.toCryptoCurrencyStringForLabel {
            
            let mainAttributedText = deposit.type == .eth ? NSAttributedString(string: "\(amount) ETH")
                : NSAttributedString(string: "\(amount) BTC")
            let attributedDollarAmount = " (~$\(dollarAmount))".attributed([.textColor(SharedColors.softGray)])
            
            view.sendInformationView.detailLabel.attributedText = mainAttributedText + attributedDollarAmount
        }
    }
    
    func configure(_ view: DepositTransactionHeaderView, for sectionType: BalanceViewController.Section) {
        switch sectionType {
        case .pending:
            view.titleLabel.text = "balance-pending-transactions-title".localized
        case .past:
            view.titleLabel.text = "balance-past-transactions-title".localized
        default:
            break
        }
    }
    
    func configure(_ view: DepositInstructionHeaderView, for sectionType: BalanceViewController.Section) {
        switch sectionType {
        case .usd:
            view.titleLabel.text = "balance-usd-deposit-title".localized
        case .btc:
            view.titleLabel.text = "balance-btc-deposit-title".localized
        case .eth:
            view.titleLabel.text = "balance-eth-deposit-title".localized
        default:
            break
        }
    }
}
