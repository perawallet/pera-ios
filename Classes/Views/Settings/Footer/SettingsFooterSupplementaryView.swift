//
//  SettingsFooterSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SettingsFooterSupplementaryView: BaseSupplementaryView<SettingsFooterView> {
    
    weak var delegate: SettingsFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension SettingsFooterSupplementaryView: SettingsFooterViewDelegate {
    func settingsFooterViewDidTapLogoutButton(_ settingsFooterView: SettingsFooterView) {
        delegate?.settingsFooterSupplementaryViewDidTapLogoutButton(self)
    }
}

protocol SettingsFooterSupplementaryViewDelegate: class {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView)
}
