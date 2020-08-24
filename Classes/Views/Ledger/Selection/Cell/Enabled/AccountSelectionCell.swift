//
//  AccountSelectionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountSelectionCell: BaseCollectionViewCell<AccountSelectionView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.clear()
    }
}
