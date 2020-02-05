//
//  AlgorandNotification.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AlgorandNotification: Model {
    let badge: Int?
    let alert: String?
    let details: NotificationDetail?
    let sound: String?
}

extension AlgorandNotification {
    enum CodingKeys: String, CodingKey {
        case badge = "badge"
        case alert = "alert"
        case details = "custom"
        case sound = "sound"
    }
}
