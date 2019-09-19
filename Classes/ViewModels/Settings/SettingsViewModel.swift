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
    func settingsViewModel(_ viewModel: SettingsViewModel, didTapCoinlistActionIn cell: CoinlistCell)
}

class SettingsViewModel {
    
    enum SettingsCellMode: Int {
        case serverSettings = 0
        case password = 1
        case localAuthentication = 2
        case notifications = 3
        case rewards = 4
        case language = 5
        case coinlist = 6
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
    
    func configureToggle(_ cell: ToggleCell, enabled: Bool, with mode: SettingsCellMode, for indexPath: IndexPath) {
        self.indexPath = indexPath
        cell.contextView.indexPath = indexPath
        
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
        cell.contextView.toggle.setOn(enabled, animated: false)
        cell.contextView.delegate = self
    }
    
    func configureCoinlist(_ cell: CoinlistCell, for session: Session?) {
        let name = nameOfMode(.coinlist)
        
        cell.contextView.nameLabel.text = name
        cell.delegate = self
        
        guard let session = session else {
            return
        }
        
        if session.coinlistToken == nil {
            cell.contextView.actionMode = .connect
        } else {
            cell.contextView.actionMode = .disconnect
        }
    }
    
    fileprivate func nameOfMode(_ mode: SettingsCellMode) -> String {
        switch mode {
        case .serverSettings:
            return "settings-server-node-settings".localized
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
        case .coinlist:
            return "settings-coinlist".localized
        }
    }
}

// MARK: - SettingsToggleContextViewDelegate

extension SettingsViewModel: SettingsToggleContextViewDelegate {
    
    func settingsToggleDidTapEdit(forIndexPath indexPath: IndexPath) {
    }
    
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool, forIndexPath indexPath: IndexPath) {
        delegate?.settingsViewModel(self, didToggleValue: value, atIndexPath: indexPath)
    }
    
}

// MARK: - CoinlistCellDelegate

extension SettingsViewModel: CoinlistCellDelegate {
    
    func coinlistCellDidTapActionButton(_ coinlistCell: CoinlistCell) {
        delegate?.settingsViewModel(self, didTapCoinlistActionIn: coinlistCell)
    }
}
