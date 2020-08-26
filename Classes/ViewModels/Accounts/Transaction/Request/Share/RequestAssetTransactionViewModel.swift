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
        view.setAccountImage(assetTransactionRequestDraft.account.accountImage())
        view.setAccountName(assetTransactionRequestDraft.account.name)
        
        if !assetTransactionRequestDraft.assetDetail.isVerified {
            view.removeVerifiedAsset()
        }
        
        view.setAmountInformationViewMode(
            .normal(
                amount: assetTransactionRequestDraft.amount,
                isAlgos: false,
                fraction: assetTransactionRequestDraft.assetDetail.fractionDecimals
            )
        )
        
        view.setAssetAlignment(.right)
        view.setAssetId("\(assetTransactionRequestDraft.assetDetail.id)")
        
        if assetTransactionRequestDraft.assetDetail.hasBothDisplayName() || assetTransactionRequestDraft.assetDetail.hasOnlyAssetName() {
            view.setAssetName(assetTransactionRequestDraft.assetDetail.assetName)
            view.removeAssetUnitName()
            return
        }
        
        if assetTransactionRequestDraft.assetDetail.hasOnlyUnitName() {
            view.setAssetName(assetTransactionRequestDraft.assetDetail.unitName)
            view.removeAssetUnitName()
            return
        }
        
        if assetTransactionRequestDraft.assetDetail.hasNoDisplayName() {
            view.setAssetName("title-unknown".localized)
            view.removeAssetUnitName()
            return
        }
    }
}
