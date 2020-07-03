//
//  TransactionFilterOptionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionFilterOptionCell: BaseCollectionViewCell<TransactionFilterOptionView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.setDeselected()
    }
}
