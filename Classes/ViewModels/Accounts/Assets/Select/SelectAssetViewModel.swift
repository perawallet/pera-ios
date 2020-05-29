//
//  SelectAssetViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetViewModel {
    func configure(_ cell: AssetCell, with assetDetail: AssetDetail, and asset: Asset) {
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        cell.contextView.amountLabel.text = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
    }
}

extension SelectAssetViewModel {
    func configure(_ header: SelectAssetHeaderSupplementaryView, with account: Account) {
        if account.type.isLedger() {
            header.contextView.setLedgerAccount()
        } else {
            header.contextView.setStandardAccount()
        }
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
