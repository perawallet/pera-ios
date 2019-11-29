//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccounsViewModel {
    func configure(_ cell: AssetCell, with assetDetail: AssetDetail, and asset: Asset) {
        guard let assetName = assetDetail.assetName,
            let code = assetDetail.unitName else {
                return
        }
        
        cell.contextView.assetNameView.setName(assetName)
        cell.contextView.assetNameView.setCode(code)
        cell.contextView.amountLabel.text = Double(asset.amount).toDecimalStringForLabel
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
    }
}

extension AccounsViewModel {
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: false)
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName.uppercased())
    }
}
