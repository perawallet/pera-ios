//
//  SendAlgosTransactionPreviewViewModel.swift

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
        
        view.transactionAccountInformationView.setAccountImage(account.accountImage())
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toAlgosStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos
        view.transactionAccountInformationView.setAssetName("asset-algos-title".localized)
        view.transactionAccountInformationView.removeAssetId()
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.setAccountImage(account.accountImage())
        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toAlgosStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos

        if isMaxTransaction {
            view.amountInputView.inputTextField.text = account.amount.toAlgos.toAlgosStringForLabel
        }
    }
}
