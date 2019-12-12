//
//  AssetListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetListViewModel {
    func configure(_ cell: AssetSelectionCell, at indexPath: IndexPath, with account: Account) {
        if indexPath.item == 0 {
            cell.contextView.assetNameView.nameLabel.text = "asset-algos-title".localized
            cell.contextView.detailLabel.text = account.amount.toAlgos.toDecimalStringForLabel
        } else {
            let assetDetail = account.assetDetails[indexPath.item - 1]
            cell.contextView.assetNameView.setAssetName(for: assetDetail)
            
            if let assetAmount = account.amount(for: assetDetail) {
                cell.contextView.detailLabel.text = assetAmount.toDecimalStringForLabel
            }
        }
    }
}
