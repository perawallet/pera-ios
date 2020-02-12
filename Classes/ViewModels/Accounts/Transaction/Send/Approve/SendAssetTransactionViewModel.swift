//
//  SendAssetTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewModel {
    func configure(_ view: SendTransactionView, with transaction: AssetTransactionDraft) {
        view.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        view.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.removeFromSuperview()
        view.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        view.amountInputView.inputTextField.text = transaction.amount?.toFractionStringForLabel(fraction: transaction.assetDecimalFraction)
        view.amountInputView.algosImageView.removeFromSuperview()
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !transaction.isVerified
        
        guard let assetIndex = transaction.assetIndex,
            let assetDetail = transaction.fromAccount.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        view.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        
        if let assetAmount = transaction.fromAccount.amount(for: assetDetail) {
            view.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.removeFromSuperview()
            view.transactionParticipantView.assetSelectionView.set(amount: assetAmount, assetFraction: assetDetail.fractionDecimals)
        }
    }
}
