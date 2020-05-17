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
        view.transactionAccountInformationView.setDisabled()
        
        if account.type == .ledger {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.removeAmountLabel()
        view.transactionAccountInformationView.setAssetName("asset-algos-title".localized)
        view.transactionAccountInformationView.setAssetVerified(true)
        view.transactionAccountInformationView.removeAssetId()
    }
}
