//
//  AccountsTotalDisplayCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsTotalDisplayCell: BaseCollectionViewCell<AccountContextView> {
    
    override func configureAppearance() {
        contextView.nameLabel.text = "account-list-total".localized
        
        contextView.nameLabel.textColor = SharedColors.darkGray
        contextView.algoImageView.tintColor = SharedColors.darkGray
        contextView.amountLabel.textColor = SharedColors.darkGray
    }
}
