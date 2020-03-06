//
//  RequestAssetTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAssetTransactionViewModel {
    
    private let assetTransactionRequestDraft: AssetTransactionRequestDraft
    
    init(assetTransactionRequestDraft: AssetTransactionRequestDraft) {
        self.assetTransactionRequestDraft = assetTransactionRequestDraft
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        view.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        view.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.removeFromSuperview()
        view.transactionParticipantView.accountSelectionView.detailLabel.text = assetTransactionRequestDraft.account.name
        
        if assetTransactionRequestDraft.account.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.amountInputView.algosImageView.removeFromSuperview()
        
        let assetDetail = assetTransactionRequestDraft.assetDetail
        view.transactionParticipantView.accountSelectionView.set(enabled: false)
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
        view.amountInputView.inputTextField.text = assetTransactionRequestDraft.amount.toFractionStringForLabel(
            fraction: assetDetail.fractionDecimals
        )
        view.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
    }
}
