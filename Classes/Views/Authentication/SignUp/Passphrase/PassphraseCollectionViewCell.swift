//
//  PassPhraseCollectionViewCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseCollectionViewCell: BaseCollectionViewCell<PassphraseMnemonicView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.setMode(.idle, animated: false)
    }
}
