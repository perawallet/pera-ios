//
//  Notification.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class NotificationMessage: Model {
    let id: Int
    let account: String
    let notificationType: NotificationType
    let message: String
    let detail: NotificationDetail?
}

extension NotificationMessage {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case account = "account"
        case notificationType = "type"
        case message = "message"
        case detail = "metadata"
    }
}
