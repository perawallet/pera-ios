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
        view.transactionAccountInformationView.setDisabled()
        
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
