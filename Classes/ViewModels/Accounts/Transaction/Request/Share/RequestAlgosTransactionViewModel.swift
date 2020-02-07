//
//  RequestAlgosTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAlgosTransactionViewModel {
    
    private let algosTransactionRequestDraft: AlgosTransactionRequestDraft
    
    init(algosTransactionRequestDraft: AlgosTransactionRequestDraft) {
        self.algosTransactionRequestDraft = algosTransactionRequestDraft
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        view.transactionParticipantView.accountSelectionView.set(enabled: false)
        view.transactionParticipantView.accountSelectionView.detailLabel.text = algosTransactionRequestDraft.account.name
        view.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.turquois
        view.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.tintColor = SharedColors.turquois
        view.amountInputView.inputTextField.text = algosTransactionRequestDraft.amount.toDecimalStringForLabel
        view.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
    }
    
}
