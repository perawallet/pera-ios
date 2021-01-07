//
//  NotificationFilterChangeEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

struct NotificationFilterChangeEvent: AnalyticsEvent {
    let isReceivingNotifications: Bool
    let address: String

    let key: AnalyticsEventKey = .notificationFilter

    var params: AnalyticsParameters? {
        return [.isReceivingNotifications: isReceivingNotifications, .address: address]
    }
}
