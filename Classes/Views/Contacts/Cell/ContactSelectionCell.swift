//
//  ContactSelectionCell.swift

import UIKit

class ContactSelectionCell: ContactCell {
    
    override func configureAppearance() {
        super.configureAppearance()
        contextView.qrDisplayButton.isHidden = true
    }
}
