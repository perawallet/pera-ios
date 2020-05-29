//
//  SettingsViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsViewModel {
    
    var indexPath: IndexPath?
    
    weak var delegate: SettingsViewModelDelegate?
    
    func configureDetail(_ cell: SettingsDetailCell, with mode: SettingsCellMode) {
        cell.contextView.nameLabel.text = nameForMode(mode)
        cell.contextView.setImage(imageForMode(mode))
    }
    
    func configureInfo(_ cell: SettingsInfoCell, with mode: SettingsCellMode) {
        cell.contextView.nameLabel.text = nameForMode(mode)
        cell.contextView.detailLabel.text = "settings-language-english".localized
        cell.contextView.setImage(imageForMode(mode))
    }
    
    func configureToggle(_ cell: SettingsToggleCell, enabled: Bool, with mode: SettingsCellMode, for indexPath: IndexPath) {
        self.indexPath = indexPath
        cell.contextView.indexPath = indexPath
        
        cell.contextView.nameLabel.text = nameForMode(mode)
        cell.contextView.setImage(imageForMode(mode))
        cell.contextView.toggle.setOn(enabled, animated: false)
        cell.contextView.delegate = self
    }
    
    private func nameForMode(_ mode: SettingsCellMode) -> String {
        switch mode {
        case .password:
            return "settings-change-password".localized
        case .localAuthentication:
            return "settings-local-authentication".localized
        case .notifications:
            return "notifications-title".localized
        case .rewards:
            return "rewards-show-title".localized
        case .language:
            return "settings-language".localized
        case .nodeSettings:
            return "settings-server-node-settings".localized
        case .feedback:
            return "feedback-title".localized
        }
    }
    
    private func imageForMode(_ mode: SettingsCellMode) -> UIImage? {
        switch mode {
        case .password:
            return img("icon-settings-password")
        case .localAuthentication:
            return img("icon-settings-faceid")
        case .notifications:
            return img("icon-settings-notification")
        case .rewards:
            return img("icon-settings-reward")
        case .language:
            return img("icon-settings-language")
        case .nodeSettings:
            return img("icon-settings-node")
        case .feedback:
            return img("icon-feedback")
        }
    }
}

extension SettingsViewModel: SettingsToggleContextViewDelegate {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool, forIndexPath indexPath: IndexPath) {
        delegate?.settingsViewModel(self, didToggleValue: value, atIndexPath: indexPath)
    }
}

extension SettingsViewModel {
    enum SettingsCellMode: Int {
        case nodeSettings = 0
        case password = 1
        case localAuthentication = 2
        case notifications = 3
        case rewards = 4
        case language = 5
        case feedback = 6
    }
}

protocol SettingsViewModelDelegate: class {
    func settingsViewModel(_ viewModel: SettingsViewModel, didToggleValue value: Bool, atIndexPath indexPath: IndexPath)
}
