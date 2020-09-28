//
//  SingleSelectionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SingleSelectionCell: BaseCollectionViewCell<SingleSelectionView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.clear()
    }
}
