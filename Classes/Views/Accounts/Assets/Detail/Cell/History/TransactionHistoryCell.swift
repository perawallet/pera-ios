//
//  TransactionHistoryCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryCell: BaseCollectionViewCell<TransactionHistoryContextView> {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contextView.reset()
        contextView.subtitleLabel.text = nil
        contextView.subtitleLabel.isHidden = false
        contextView.dateLabel.text = nil
        contextView.transactionAmountView.algoIconImageView.isHidden = false
        contextView.transactionAmountView.amountLabel.text = nil
    }
}
