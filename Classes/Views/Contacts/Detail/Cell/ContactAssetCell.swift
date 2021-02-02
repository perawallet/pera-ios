//
//  ContactAssetCell.swift

import UIKit

class ContactAssetCell: BaseCollectionViewCell<ContactAssetView> {
    
    weak var delegate: ContactAssetCellDelegate?
    
    override func configureAppearance() {
        contextView.layer.cornerRadius = 12.0
    }
    
    override func setListeners() {
        super.setListeners()
        contextView.delegate = self
    }
}

extension ContactAssetCell: ContactAssetViewDelegate {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView) {
        delegate?.contactAssetCellDidTapSendButton(self)
    }
}

protocol ContactAssetCellDelegate: class {
    func contactAssetCellDidTapSendButton(_ contactAssetCell: ContactAssetCell)
}
