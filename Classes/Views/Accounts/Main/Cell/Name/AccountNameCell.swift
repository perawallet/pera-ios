//
//  AccountNameCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountNameCell: BaseCollectionViewCell<AccountNameView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contextView.titleLabel.textColor = SharedColors.darkGray
        contextView.bottomLineView.isHidden = true
    }
}
