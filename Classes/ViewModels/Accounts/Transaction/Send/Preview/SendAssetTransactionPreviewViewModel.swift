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
    private let isAccountSelectionEnabled: Bool
    
    init(assetDetail: AssetDetail, isForcedMaxTransaction: Bool, isAccountSelectionEnabled: Bool) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isForcedMaxTransaction
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        view.transactionAccountInformationView.setAssetName(for: assetDetail)
        
        if !assetDetail.isVerified {
            view.transactionAccountInformationView.removeVerifiedAsset()
        }
        
        if let account = selectedAccount,
            let assetAmount = account.amount(for: assetDetail) {
            if account.type.isLedger() {
                view.transactionAccountInformationView.setAccountImage(img("img-ledger-small"))
            } else if account.type.isRekeyed() {
                view.transactionAccountInformationView.setAccountImage(img("icon-account-type-rekeyed"))
            } else {
                view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
            }
            
            view.transactionAccountInformationView.setAccountName(account.name)
            
            view.amountInputView.maxAmount = assetAmount
            view.transactionAccountInformationView.setAmount(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals))
        }
        
        if isForcedMaxTransaction {
            view.amountInputView.inputTextField.text = selectedAccount?.amountDisplayWithFraction(for: assetDetail)
            view.amountInputView.setEnabled(false)
        }
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        
        if account.type.isLedger() {
            view.transactionAccountInformationView.setAccountImage(img("img-ledger-small"))
        } else if account.type.isRekeyed() {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-rekeyed"))
        } else {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.transactionAccountInformationView.setAccountName(account.name)
        
        view.amountInputView.maxAmount = assetAmount
        view.transactionAccountInformationView.setAmount(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals))
        
        if isMaxTransaction {
            view.amountInputView.inputTextField.text = assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        }
    }
}
