//
//  ContactAssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
