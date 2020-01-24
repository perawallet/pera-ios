//
//  ContactAssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactAssetCellDelegate: class {
    func contactAssetCellDidTapSendButton(_ contactAssetCell: ContactAssetCell)
}

class ContactAssetCell: BaseCollectionViewCell<ContactAssetView> {
    
    weak var delegate: ContactAssetCellDelegate?
    
    override func setListeners() {
        super.setListeners()
        contextView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        configureBorders()
    }
        
    private func configureBorders() {
        layer.cornerRadius = 4.0
        layer.borderColor = Colors.borderColor.cgColor
        layer.borderWidth = 1.0
    }
}

extension ContactAssetCell: ContactAssetViewDelegate {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView) {
        delegate?.contactAssetCellDidTapSendButton(self)
    }
}

extension ContactAssetCell {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
