//
//  AssetCardCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AssetCardCell: BaseCollectionViewCell<AssetCardView> {
    
    weak var delegate: AssetCardCellDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
}

extension AssetCardCell: AssetCardViewDelegate {
    func assetCardViewDidCopyAssetId(_ assetCardView: AssetCardView) {
        delegate?.assetCardCellDidCopyAssetId(self)
    }
}

protocol AssetCardCellDelegate: class {
    func assetCardCellDidCopyAssetId(_ assetCardCell: AssetCardCell)
}
