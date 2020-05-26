//
//  RequestAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAssetTransactionPreviewViewModel {
    
    private var account: Account
    private let assetDetail: AssetDetail
    private let isAccountSelectionEnabled: Bool
    
    init(account: Account, assetDetail: AssetDetail, isAccountSelectionEnabled: Bool) {
        self.account = account
        self.assetDetail = assetDetail
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: RequestTransactionPreviewView) {
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        if account.type == .ledger {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.transactionAccountInformationView.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.removeAmountLabel()
        view.transactionAccountInformationView.setAssetName(for: assetDetail)
        view.transactionAccountInformationView.setAssetTransaction()
        view.transactionAccountInformationView.removeAssetId()
    }
}

extension RequestAssetTransactionPreviewViewModel {
    func updateAccount(_ account: Account) {
        self.account = account
    }
}
