//
//  AssetAdditionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetAdditionViewModel {
    func configure(_ cell: AssetSelectionCell, with asset: AssetDetail) {
        cell.contextView.nameLabel.text = asset.assetName
        cell.contextView.codeLabel.text = asset.unitName
    }
}
