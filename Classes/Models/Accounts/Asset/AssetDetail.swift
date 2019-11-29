//
//  AssetDetail.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetDetail: Model {
    let creator: String
    let total: UInt64
    let isDefaultFrozen: Bool?
    let unitName: String?
    let assetName: String?
    let url: String?
    let managerKey: String?
    let reserveAddress: String?
    let freezeAddress: String?
    let clawBackAddress: String?
    
    var index: String?
}

extension AssetDetail {
    enum CodingKeys: String, CodingKey {
        case creator = "creator"
        case total = "total"
        case isDefaultFrozen = "defaultfrozen"
        case unitName = "unitname"
        case assetName = "assetname"
        case url = "url"
        case managerKey = "managerkey"
        case reserveAddress = "reserveaddr"
        case freezeAddress = "freezeaddr"
        case clawBackAddress = "clawbackaddr"
        case index = "index"
    }
}

extension AssetDetail: Encodable {
}
