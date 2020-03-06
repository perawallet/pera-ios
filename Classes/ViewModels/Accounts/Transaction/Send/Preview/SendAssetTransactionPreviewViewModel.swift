//
//  SendAssetTransactionPreviewViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionPreviewViewModel {
    private let assetDetail: AssetDetail
    private let isForcedMaxTransaction: Bool
    
    init(assetDetail: AssetDetail, isForcedMaxTransaction: Bool) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isForcedMaxTransaction
    }
    
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        view.transactionParticipantView.assetSelectionView.amountView.amountLabel.textColor = SharedColors.black
        view.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.removeFromSuperview()
        view.amountInputView.algosImageView.removeFromSuperview()
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
        
        if let selectedAccount = selectedAccount,
            let assetAmount = selectedAccount.amount(for: assetDetail) {
            view.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
            
            if selectedAccount.type == .ledger {
                view.transactionParticipantView.accountSelectionView.setLedgerAccount()
            } else {
                view.transactionParticipantView.accountSelectionView.setStandardAccount()
            }
            
            view.amountInputView.maxAmount = assetAmount
            view.transactionParticipantView.assetSelectionView.set(amount: assetAmount, assetFraction: assetDetail.fractionDecimals)
        }
        
        if isForcedMaxTransaction {
            view.amountInputView.algosImageView.removeFromSuperview()
            view.amountInputView.inputTextField.text = selectedAccount?.amountDisplayWithFraction(for: assetDetail)
            view.amountInputView.set(enabled: false)
        }
        
        view.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        
        view.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        
        if account.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.amountInputView.maxAmount = assetAmount
        view.transactionParticipantView.assetSelectionView.set(amount: assetAmount, assetFraction: assetDetail.fractionDecimals)
        
        if isMaxTransaction {
            view.amountInputView.inputTextField.text = assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        }
    }
}
