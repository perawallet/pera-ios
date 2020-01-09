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
}
