//
//  TitledToggleViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation
import UserNotifications

class TitledToggleViewModel {

    private(set) var title: String?
    private(set) var isSelected: Bool = true

    init() {
        setTitle()
        setIsSelected()
    }

    private func setTitle() {
        title = "notification-filter-show-title".localized
    }

    private func setIsSelected() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isSelected = settings.authorizationStatus == .authorized
            }
        }
    }
}
