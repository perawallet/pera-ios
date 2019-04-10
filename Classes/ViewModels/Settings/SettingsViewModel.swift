//
//  SettingsViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsViewModel {
    
    enum SettingsCellMode: Int {
        case serverSettings
        case password
        case localAuthentication
        case language
    }
    
    func configureDetail(_ cell: SettingsDetailCell, with mode: SettingsCellMode) {
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
    }
    
    func configureInfo(_ cell: SettingsInfoCell, with mode: SettingsCellMode) {
        let name = nameOfMode(mode)
        
        cell.contextView.nameLabel.text = name
        cell.contextView.detailLabel.text = "settings-language-english".localized
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
