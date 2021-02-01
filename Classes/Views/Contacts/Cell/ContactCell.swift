//
//  ContactCell.swift

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

    func bind(_ viewModel: ContactsViewModel) {
        contextView.bind(viewModel)
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
