//
//  NotificationsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NotificationsViewModel {
    
    private let notification: NotificationMessage
    
    private var notificationImage: UIImage?
    private(set) var title: String?
    private var time: String?
    
    init(notification: NotificationMessage) {
        self.notification = notification
        setImage()
        setTitle()
        setTime()
    }
    
    private func setImage() {
        notificationImage = nil
    }
    
    private func setTitle() {
        title = ""
    }
    
    private func setTime() {
        time = ""
    }
}

extension NotificationsViewModel {
    func configure(_ cell: NotificationCell) {
        cell.contextView.setNotificationImage(notificationImage)
        cell.contextView.setTitle(title)
        cell.contextView.setTime(time)
    }
}
