//
//  NotificationFilterResponse.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Magpie

class NotificationFilterResponse: Model {
    let receivesNotification: Bool
}

extension NotificationFilterResponse {
    enum CodingKeys: String, CodingKey {
        case receivesNotification = "receive_notifications"
    }
}
