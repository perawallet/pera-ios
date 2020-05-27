//
//  ContactCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactCell: BaseCollectionViewCell<ContactContextView> {
    
    weak var delegate: ContactCellDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.userImageView.image = img("icon-user-placeholder")
    }
}

extension ContactCell: ContactContextViewDelegate {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView) {
        delegate?.contactCellDidTapQRDisplayButton(self)
    }
}

protocol ContactCellDelegate: class {
    func contactCellDidTapQRDisplayButton(_ cell: ContactCell)
}
