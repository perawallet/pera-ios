//
//  RequestAlgosTransactionPreviewViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class RequestAlgosTransactionPreviewViewModel {
    
    private var account: Account
    private let isAccountSelectionEnabled: Bool
    
    init(account: Account, isAccountSelectionEnabled: Bool) {
        self.account = account
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        if account.type.isLedger() {
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

extension RequestAlgosTransactionPreviewViewModel {
    func updateAccount(_ account: Account) {
        self.account = account
    }
}
