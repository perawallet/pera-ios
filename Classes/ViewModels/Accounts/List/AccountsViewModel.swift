//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewModel {
    func configure(_ cell: BaseAssetCell, with assetDetail: AssetDetail, and asset: Asset) {
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        let amountText = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        cell.contextView.setActionText(amountText)
    }
    
    func configure(_ cell: BasePendingAssetCell, with assetDetail: AssetDetail, isRemoving: Bool) {
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        if isRemoving {
            cell.contextView.detailLabel.text = "asset-remove-confirmation-title".localized
        } else {
            cell.contextView.detailLabel.text = "asset-add-confirmation-title".localized
        }
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toAlgosStringForLabel
    }
}

extension AccountsViewModel {
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: false)
        header.contextView.setQRButton(hidden: false)
        header.contextView.setAccountImage(account.accountImage())
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
