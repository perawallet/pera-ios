//
//  SettingsToggleViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SettingsToggleViewModel {
    
    private var image: UIImage?
    private var title: String?
    private var isOn: Bool = false
    
    init(setting: Settings, isOn: Bool) {
        setImage(from: setting)
        setTitle(from: setting)
        setIsOn(from: isOn)
    }
    
    private func setImage(from settings: Settings) {
        image = settings.image
    }
    
    private func setTitle(from settings: Settings) {
        title = settings.name
    }
    
    private func setIsOn(from isOn: Bool) {
        self.isOn = isOn
    }
}

extension SettingsToggleViewModel {
    func configure(_ cell: SettingsToggleCell) {
        cell.contextView.setImage(image)
        cell.contextView.setName(title)
        cell.contextView.setToggleOn(isOn, animated: false)
    }
}
