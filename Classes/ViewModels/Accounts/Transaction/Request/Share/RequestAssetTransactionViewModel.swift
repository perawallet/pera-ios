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
    
    func configure(_ view: RequestTransactionView) {
        if assetTransactionRequestDraft.account.type.isLedger() {
            view.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.setAccountName(assetTransactionRequestDraft.account.name)
        
        view.setAssetName(for: assetTransactionRequestDraft.assetDetail)
        view.removeAssetId()
        
        view.setAmountInformationViewMode(
            .normal(
                amount: assetTransactionRequestDraft.amount,
                isAlgos: false,
                fraction: assetTransactionRequestDraft.assetDetail.fractionDecimals
            )
        )
    }
}
