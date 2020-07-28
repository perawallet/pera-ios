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
    let date: Date?
    let message: String?
    let detail: NotificationDetail?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        account = try container.decodeIfPresent(Int.self, forKey: .account)
        notificationType = try container.decodeIfPresent(NotificationType.self, forKey: .notificationType)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        detail = try container.decodeIfPresent(NotificationDetail.self, forKey: .detail)
    }
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
