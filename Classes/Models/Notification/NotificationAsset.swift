//
//  NotificationAsset.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class NotificationAsset: Model {
    let id: Int64?
    let name: String?
    let code: String?
    let url: String?
    let fractionDecimals: Int?
}

extension NotificationAsset {
    enum CodingKeys: String, CodingKey {
        case id = "asset_id"
        case name = "asset_name"
        case code = "unit_name"
        case url = "url"
        case fractionDecimals = "fraction_decimals"
    }
}
