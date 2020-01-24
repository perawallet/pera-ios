//
//  AssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetCell: BaseCollectionViewCell<AssetView> {
    
    override func configureAppearance() {
        super.configureAppearance()
        configureBorders()
    }
    
    private func configureBorders() {
        layer.cornerRadius = 4.0
        layer.borderColor = Colors.borderColor.cgColor
        layer.borderWidth = 1.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.assetNameView.nameLabel.text = ""
        contextView.assetNameView.idLabel.text = ""
        contextView.assetNameView.codeLabel.text = ""
        contextView.amountLabel.text = ""
        
        contextView.assetNameView.nameLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        contextView.assetNameView.nameLabel.textColor = SharedColors.black
        contextView.assetNameView.codeLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        contextView.assetNameView.codeLabel.textColor = SharedColors.purple
    }
}

extension AssetCell {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
