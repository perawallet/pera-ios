//
//  ToggleCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ToggleCell: SettingsToggleCell {
    override func prepareLayout() {
        super.prepareLayout()
        
        self.contextView.editButton.isHidden = true
        
        self.contextView.nameLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(self.contextView.layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}
