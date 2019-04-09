//
//  SettingsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    private lazy var settingsView: SettingsView = {
        SettingsView()
    }()
        
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-title".localized
        
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
