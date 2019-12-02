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
            cell.contextView.assetNameView.setName("asset-algos-title".localized)
            cell.contextView.detailLabel.text = account.amount.toAlgos.toDecimalStringForLabel
        } else {
            let assetDetail = account.assetDetails[indexPath.item - 1]
            cell.contextView.assetNameView.setName(assetDetail.assetName ?? "")
            cell.contextView.assetNameView.setCode(assetDetail.unitName ?? "")
            
            if let assetIndex = assetDetail.index,
                let asset = account.assets?[assetIndex] {
                cell.contextView.detailLabel.text = Double(asset.amount).toDecimalStringForLabel
            }
        }
    }
}
