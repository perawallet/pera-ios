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
        if algosTransactionRequestDraft.account.type == .ledger {
            view.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.setAccountName(algosTransactionRequestDraft.account.name)
        
        view.setAssetName("asset-algos-title".localized)
        view.setAssetVerified(true)
        view.removeAssetId()
        
        view.setAmountInformationViewMode(.normal(amount: algosTransactionRequestDraft.amount))
    }
}
