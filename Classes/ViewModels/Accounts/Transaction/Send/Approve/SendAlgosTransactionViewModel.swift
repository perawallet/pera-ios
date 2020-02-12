//
//  SendAlgosTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewModel {
    func configure(_ view: SendTransactionView, with transaction: TransactionPreviewDraft) {
        view.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        view.amountInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
        view.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.transactionParticipantView.assetSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
    }
}
