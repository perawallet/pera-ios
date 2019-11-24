//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccounsViewModel {
    func configure(_ cell: AssetCell, with asset: AssetDetail) {
        guard let assetName = asset.assetName,
            let code = asset.unitName else {
                return
        }
        
        cell.contextView.assetNameView.setName(assetName)
        cell.contextView.assetNameView.setCode(code)
        cell.contextView.amountLabel.text = asset.total.toAlgos.toDecimalStringForLabel
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
    }
}

extension AccounsViewModel {
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: true)
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
