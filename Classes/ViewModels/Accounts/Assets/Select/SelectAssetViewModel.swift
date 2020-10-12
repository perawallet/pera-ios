//
//  SelectAssetViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetViewModel {
    func configure(_ cell: BaseAssetCell, with assetDetail: AssetDetail, and asset: Asset) {
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        let amountText = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        cell.contextView.setActionText(amountText)
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toAlgosStringForLabel
    }
}

extension SelectAssetViewModel {
    func configure(_ header: SelectAssetHeaderSupplementaryView, with account: Account) {
        header.contextView.setAccountImage(account.accountImage())
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
