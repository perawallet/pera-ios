//
//  SettingsDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SettingsDetailViewModel {
    
    private var image: UIImage?
    private var title: String?
    
    init(setting: Settings) {
        setImage(from: setting)
        setTitle(from: setting)
    }
    
    private func setImage(from settings: Settings) {
        image = settings.image
    }
    
    private func setTitle(from settings: Settings) {
        title = settings.name
    }
}

extension SettingsDetailViewModel {
    func configure(_ cell: SettingsDetailCell) {
        cell.contextView.setImage(image)
        cell.contextView.setName(title)
    }
}
