//
//  SendAssetTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewModel {
    func configure(_ view: SendTransactionView, with assetTransactionSendDraft: AssetTransactionSendDraft) {
        view.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        view.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.removeFromSuperview()
        view.transactionParticipantView.accountSelectionView.detailLabel.text = assetTransactionSendDraft.from.name
        view.amountInputView.inputTextField.text
            = assetTransactionSendDraft.amount?.toFractionStringForLabel(fraction: assetTransactionSendDraft.assetDecimalFraction)
        view.amountInputView.algosImageView.removeFromSuperview()
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetTransactionSendDraft.isVerifiedAsset
        
        guard let assetIndex = assetTransactionSendDraft.assetIndex,
            let assetDetail = assetTransactionSendDraft.from.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        view.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        
        if let assetAmount = assetTransactionSendDraft.from.amount(for: assetDetail) {
            view.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.removeFromSuperview()
            view.transactionParticipantView.assetSelectionView.set(amount: assetAmount, assetFraction: assetDetail.fractionDecimals)
        }
    }
}
