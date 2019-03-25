//
//  PassPhraseCollectionViewCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseCollectionViewCell: BaseCollectionViewCell<UILabel> {
    override func configureAppearance() {
        super.configureAppearance()
        
        contextView
            .withFont(UIFont.font(Font.opensans, withWeight: .regular(size: 13.0)))
            .withTextColor(UIColor.black)
            .withAlignment(.center)
        
        contentView.backgroundColor = UIColor.red
        contentView.layer.cornerRadius = 10.0
    }
}
