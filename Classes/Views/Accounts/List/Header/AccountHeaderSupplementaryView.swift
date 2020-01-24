//
//  AccountHeaderSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountHeaderSupplementaryViewDelegate: class {
    func accountHeaderSupplementaryViewDidTapOptionsButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView)
}

class AccountHeaderSupplementaryView: BaseCollectionViewCell<AccountHeaderView> {
    
    weak var delegate: AccountHeaderSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AccountHeaderSupplementaryView: AccountHeaderViewDelegate {
    func accountHeaderViewDidTapOptionsButton(_ accountHeaderView: AccountHeaderView) {
        delegate?.accountHeaderSupplementaryViewDidTapOptionsButton(self)
    }
}
