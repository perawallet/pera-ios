//
//  Device.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct Device: Model {
    let pushToken: String?
    let platform: String
    let model: String
    let locale: String
    let accounts: [String]?
}

extension Device {
    enum CodingKeys: String, CodingKey {
        case pushToken = "push_token"
        case platform = "platform"
        case model = "model"
        case locale = "locale"
        case accounts = "accounts"
    }
}
