//
//  AssetAdditionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetAdditionViewModel {
    func configure(_ cell: AssetSelectionCell, with assetSearchResult: AssetSearchResult) {
        cell.contextView.assetNameView.setAssetName(for: AssetDetail(searchResult: assetSearchResult))
        cell.contextView.detailLabel.text = "\(assetSearchResult.id)"
    }
    
    func update(_ view: AssetAdditionView, with status: AssetSearchStatus) {
        switch status {
        case .all:
            view.set(button: view.verifiedAssetsButton, selected: true)
            view.set(button: view.unverifiedAssetsButton, selected: true)
        case .verified:
            view.set(button: view.verifiedAssetsButton, selected: true)
            view.set(button: view.unverifiedAssetsButton, selected: false)
        case .unverified:
            view.set(button: view.verifiedAssetsButton, selected: false)
            view.set(button: view.unverifiedAssetsButton, selected: true)
        default:
            break
        }
    }
}
