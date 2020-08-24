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
    
    func configure(_ view: RequestTransactionView) {
        if algosTransactionRequestDraft.account.isLedger() {
            view.setAccountImage(img("img-ledger-small"))
        } else if algosTransactionRequestDraft.account.isRekeyed() {
            view.setAccountImage(img("icon-account-type-rekeyed"))
        } else {
            view.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.removeAssetId()
        view.removeAssetUnitName()
        view.setAssetAlignment(.right)
        view.setAccountName(algosTransactionRequestDraft.account.name)
        view.setAssetName("asset-algos-title".localized)
        view.setAmountInformationViewMode(.normal(amount: algosTransactionRequestDraft.amount))
    }
}
