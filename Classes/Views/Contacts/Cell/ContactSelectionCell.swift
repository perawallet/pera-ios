//
//  ContactSelectionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactSelectionCell: ContactCell {
    
    override func configureAppearance() {
        super.configureAppearance()
        
        contextView.sendButton.isHidden = true
        contextView.qrDisplayButton.isHidden = true
        
        contextView.addressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.0)
        }
    }
}
