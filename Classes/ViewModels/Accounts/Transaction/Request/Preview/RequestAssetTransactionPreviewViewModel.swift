//
//  RequestAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAssetTransactionPreviewViewModel {
    
    private let account: Account
    private let assetDetail: AssetDetail
    
    init(account: Account, assetDetail: AssetDetail) {
        self.account = account
        self.assetDetail = assetDetail
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        view.transactionParticipantView.accountSelectionView.set(enabled: false)
        view.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        view.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.isHidden = true
        view.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        view.amountInputView.algosImageView.removeFromSuperview()
        
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
        view.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
    }
}
