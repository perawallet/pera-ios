//
//  Device.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Device: Model {
    let id: String?
    let pushToken: String?
    let platform: String?
    let model: String?
    let locale: String?
}

extension Device {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case pushToken = "push_token"
        case platform = "platform"
        case model = "model"
        case locale = "locale"
    }
}
