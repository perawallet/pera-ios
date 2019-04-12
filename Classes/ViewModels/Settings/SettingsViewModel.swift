//
//  SettingsViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SettingsViewModelDelegate: class {
    func settingsViewModel(_ viewModel: SettingsViewModel, didToggleValue value: Bool, atIndexPath indexPath: IndexPath)
}

class SettingsViewModel {
    
    enum SettingsCellMode: Int {
        case serverSettings = 0
        case password = 1
        case localAuthentication = 2
        case language = 3
    }
    
    var indexPath: IndexPath?
    
    weak var delegate: SettingsViewModelDelegate?
    
    func configureDetail(_ cell: SettingsDetailCell, with mode: SettingsCellMode) {
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
    }
    
    func configureInfo(_ cell: SettingsInfoCell, with mode: SettingsCellMode) {
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
        cell.contextView.detailLabel.text = "settings-language-english".localized
    }
    
    func configureToggle(_ cell: SettingsToggleCell, enabled: Bool, with mode: SettingsCellMode, for indexPath: IndexPath) {
        self.indexPath = indexPath
        
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
        cell.contextView.toggle.setOn(enabled, animated: false)
        cell.contextView.delegate = self
    }
    
    fileprivate func nameOfMode(_ mode: SettingsCellMode) -> String {
        switch mode {
        case .serverSettings:
            return "settings-server-node-settings".localized
        case .password:
            return "settings-change-password".localized
        case .localAuthentication:
            return "settings-local-authentication".localized
        case .language:
            return "settings-language".localized
        }
    }
}

// MARK: - SettingsToggleContextViewDelegate
extension SettingsViewModel: SettingsToggleContextViewDelegate {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool) {
        guard let indexPath = self.indexPath else {
            return
        }
        
        delegate?.settingsViewModel(self, didToggleValue: value, atIndexPath: indexPath)
    }
}
