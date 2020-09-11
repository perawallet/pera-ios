//
//  SettingsInfoViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SettingsInfoViewModel {
    
    private var image: UIImage?
    private var title: String?
    private var detail: String?
    
    init(setting: Settings, info: String?) {
        setImage(from: setting)
        setTitle(from: setting)
        setDetail(from: info)
    }
    
    private func setImage(from settings: Settings) {
        image = settings.image
    }
    
    private func setTitle(from settings: Settings) {
        title = settings.name
    }
    
    private func setDetail(from info: String?) {
        detail = info
    }
}

extension SettingsInfoViewModel {
    func configure(_ cell: SettingsInfoCell) {
        cell.contextView.setImage(image)
        cell.contextView.setName(title)
        cell.contextView.setDetail(detail)
    }
}
