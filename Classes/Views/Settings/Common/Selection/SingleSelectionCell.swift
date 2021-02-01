//
//  SingleSelectionCell.swift

import UIKit

class SingleSelectionCell: BaseCollectionViewCell<SingleSelectionView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.clear()
    }
}
