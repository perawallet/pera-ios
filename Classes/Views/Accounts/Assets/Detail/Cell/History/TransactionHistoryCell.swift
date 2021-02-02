//
//  TransactionHistoryCell.swift

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
