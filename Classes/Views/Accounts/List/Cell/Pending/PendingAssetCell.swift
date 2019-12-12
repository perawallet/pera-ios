//
//  PendingAssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PendingAssetCell: BaseCollectionViewCell<PendingAssetView> {
    
    override func configureAppearance() {
        super.configureAppearance()
        configureBorders()
    }
    
    private func configureBorders() {
        layer.cornerRadius = 4.0
        layer.borderColor = Colors.borderColor.cgColor
        layer.borderWidth = 1.0
    }
}

extension PendingAssetCell {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
