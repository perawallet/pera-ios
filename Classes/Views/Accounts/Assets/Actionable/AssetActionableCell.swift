//
//  AssetActionableCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetActionableCellDelegate: class {
    func assetActionableCellDidTapActionButton(_ assetActionableCell: AssetActionableCell)
}

class AssetActionableCell: BaseCollectionViewCell<AssetActionableView> {
    
    weak var delegate: AssetActionableCellDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
    
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

extension AssetActionableCell: AssetActionableViewDelegate {
    func assetActionableViewDidTapActionButton(_ assetActionableView: AssetActionableView) {
        delegate?.assetActionableCellDidTapActionButton(self)
    }
}

extension AssetActionableCell {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
