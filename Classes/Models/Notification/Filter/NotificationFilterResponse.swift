//
//  NotificationFilterResponse.swift

import Magpie

class NotificationFilterResponse: Model {
    let receivesNotification: Bool
}

extension NotificationFilterResponse {
    enum CodingKeys: String, CodingKey {
        case receivesNotification = "receive_notifications"
    }
}
