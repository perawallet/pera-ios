//
//  TitledToggleViewModel.swift

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
