//
//  SettingsToggleCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsToggleCell: BaseCollectionViewCell<SettingsToggleContextView> {
    
    weak var delegate: SettingsToggleCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
}

extension SettingsToggleCell: SettingsToggleContextViewDelegate {
    func settingsToggleContextView(_ settingsToggleContextView: SettingsToggleContextView, didChangeValue value: Bool) {
        delegate?.settingsToggleCell(self, didChangeValue: value)
    }
}

protocol SettingsToggleCellDelegate: class {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool)
}
