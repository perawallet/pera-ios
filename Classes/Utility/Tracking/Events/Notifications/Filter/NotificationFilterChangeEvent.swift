//
//  NotificationFilterChangeEvent.swift

import Foundation

struct NotificationFilterChangeEvent: AnalyticsEvent {
    let isReceivingNotifications: Bool
    let address: String

    let key: AnalyticsEventKey = .notificationFilter

    var params: AnalyticsParameters? {
        return [.isReceivingNotifications: isReceivingNotifications, .address: address]
    }
}
