//
//  SettingsToggleCell.swift

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
