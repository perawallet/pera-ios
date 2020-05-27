//
//  AccountHeaderSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountHeaderSupplementaryView: BaseSupplementaryView<AccountHeaderView> {
    
    weak var delegate: AccountHeaderSupplementaryViewDelegate?
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AccountHeaderSupplementaryView: AccountHeaderViewDelegate {
    func accountHeaderViewDidTapQRButton(_ accountHeaderView: AccountHeaderView) {
        delegate?.accountHeaderSupplementaryViewDidTapQRButton(self)
    }
    
    func accountHeaderViewDidTapOptionsButton(_ accountHeaderView: AccountHeaderView) {
        delegate?.accountHeaderSupplementaryViewDidTapOptionsButton(self)
    }
}

protocol AccountHeaderSupplementaryViewDelegate: class {
    func accountHeaderSupplementaryViewDidTapQRButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView)
    func accountHeaderSupplementaryViewDidTapOptionsButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView)
}
