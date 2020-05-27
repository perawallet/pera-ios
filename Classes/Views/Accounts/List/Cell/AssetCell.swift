//
//  AssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetCell: BaseCollectionViewCell<AssetView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.assetNameView.nameLabel.text = ""
        contextView.assetNameView.idLabel.text = ""
        contextView.assetNameView.codeLabel.text = ""
        contextView.amountLabel.text = ""
        
        contextView.assetNameView.nameLabel.font = UIFont.font(withWeight: .medium(size: 14.0))
        contextView.assetNameView.nameLabel.textColor = SharedColors.primaryText
        contextView.assetNameView.codeLabel.font = UIFont.font(withWeight: .medium(size: 14.0))
        contextView.assetNameView.codeLabel.textColor = SharedColors.detailText
    }
}
