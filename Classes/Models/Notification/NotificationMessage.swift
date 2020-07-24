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
    let account: Int?
    let notificationType: NotificationType?
    let date: Date
    let message: String?
    let detail: NotificationDetail?
}

extension NotificationMessage {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case account = "account"
        case notificationType = "type"
        case date = "creation_datetime"
        case message = "message"
        case detail = "metadata"
    }
}
