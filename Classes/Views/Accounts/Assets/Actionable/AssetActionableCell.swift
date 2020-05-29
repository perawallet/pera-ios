//
//  AssetActionableCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetActionableCell: BaseCollectionViewCell<AssetActionableView> {
    
    weak var delegate: AssetActionableCellDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AssetActionableCell: AssetActionableViewDelegate {
    func assetActionableViewDidTapActionButton(_ assetActionableView: AssetActionableView) {
        delegate?.assetActionableCellDidTapActionButton(self)
    }
}

protocol AssetActionableCellDelegate: class {
    func assetActionableCellDidTapActionButton(_ assetActionableCell: AssetActionableCell)
}
