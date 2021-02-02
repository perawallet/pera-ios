//
//  SettingsFooterSupplementaryView.swift

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
