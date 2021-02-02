//
//  AssetCardCell.swift

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
