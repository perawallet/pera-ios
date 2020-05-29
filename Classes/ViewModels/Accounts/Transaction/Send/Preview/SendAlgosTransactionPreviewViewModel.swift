//
//  SendAlgosTransactionPreviewViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionPreviewViewModel {
    private let isAccountSelectionEnabled: Bool
    
    init(isAccountSelectionEnabled: Bool) {
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        guard let account = selectedAccount else {
            return
        }
        
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        if account.type.isLedger() {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toDecimalStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos
        view.transactionAccountInformationView.setAssetName("asset-algos-title".localized)
        view.transactionAccountInformationView.setAssetVerified(true)
        view.transactionAccountInformationView.removeAssetId()
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        view.transactionAccountInformationView.setAccountName(account.name)
        
        if account.type.isLedger() {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
        }

        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toDecimalStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos

        if isMaxTransaction {
            view.amountInputView.inputTextField.text = account.amount.toAlgos.toDecimalStringForLabel
        }
    }
}
