//
//  RequestAlgosTransactionPreviewViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class RequestAlgosTransactionPreviewViewModel {
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        view.transactionParticipantView.accountSelectionView.set(enabled: false)
        
        if account.type == .ledger {
            view.transactionParticipantView.accountSelectionView.setLedgerAccount()
        } else {
            view.transactionParticipantView.accountSelectionView.setStandardAccount()
        }
        
        view.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        view.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.transactionParticipantView.assetSelectionView.amountView.amountLabel.textColor = SharedColors.turquois
        view.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.tintColor = SharedColors.turquois
        view.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
    }
}
