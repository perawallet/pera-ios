//
//  AssetSelectionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSelectionCell: BaseCollectionViewCell<AssetSelectionView> {
 
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.assetNameView.nameLabel.text = ""
        contextView.assetNameView.idLabel.text = ""
        contextView.assetNameView.codeLabel.text = ""
        contextView.detailLabel.text = ""
        
        contextView.assetNameView.nameLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        contextView.assetNameView.nameLabel.textColor = SharedColors.black
        contextView.assetNameView.codeLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        contextView.assetNameView.codeLabel.textColor = SharedColors.darkGray
    }
}
