//
//  SendAlgosTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewModel {
    func configure(_ view: SendTransactionView, with algosTransactionSendDraft: AlgosTransactionSendDraft) {
        view.transactionParticipantView.accountSelectionView.detailLabel.text = algosTransactionSendDraft.from.name
        
        if algosTransactionSendDraft.from.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.amountInputView.inputTextField.text = algosTransactionSendDraft.amount?.toDecimalStringForLabel
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
        view.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.transactionParticipantView.assetSelectionView.set(amount: algosTransactionSendDraft.from.amount.toAlgos)
    }
}
