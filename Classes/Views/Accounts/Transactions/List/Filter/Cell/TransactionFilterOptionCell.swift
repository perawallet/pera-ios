//
//  TransactionFilterOptionCell.swift

import UIKit

class TransactionFilterOptionCell: BaseCollectionViewCell<TransactionFilterOptionView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.setDeselected()
    }
}
