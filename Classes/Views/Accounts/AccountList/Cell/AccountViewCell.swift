//
//  AccountViewCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountViewCell: BaseCollectionViewCell<AccountContextView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contextView.nameLabel.text = ""
        contextView.amountLabel.text = ""
        
        contextView.algoImageView.tintColor = SharedColors.green
        contextView.amountLabel.textColor = SharedColors.green
    }
}
