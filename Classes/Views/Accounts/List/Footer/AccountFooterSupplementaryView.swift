//
//  AccountFooterSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountFooterSupplementaryViewDelegate: class {
    func accountFooterSupplementaryViewDidTapAddAssetButton(_ accountFooterSupplementaryView: AccountFooterSupplementaryView)
}

class AccountFooterSupplementaryView: BaseCollectionViewCell<AccountFooterView> {
    
    weak var delegate: AccountFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AccountFooterSupplementaryView: AccountFooterViewDelegate {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView) {
        delegate?.accountFooterSupplementaryViewDidTapAddAssetButton(self)
    }
}
