//
//  SendAlgosTransactionPreviewViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionPreviewViewModel {
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        view.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
        view.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.tintColor = SharedColors.turquois
        configureSelectedAccount(view, with: selectedAccount)
    }
    
    private func configureSelectedAccount(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        view.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
        
        if selectedAccount.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.transactionParticipantView.assetSelectionView.set(amount: selectedAccount.amount.toAlgos)
        view.amountInputView.maxAmount = selectedAccount.amount.toAlgos
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        view.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        
        if account.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.transactionParticipantView.assetSelectionView.set(amount: account.amount.toAlgos)
        view.amountInputView.maxAmount = account.amount.toAlgos
        
        if isMaxTransaction {
            view.amountInputView.inputTextField.text = view.transactionParticipantView.assetSelectionView.amountView.amountLabel.text
        }
    }
}
