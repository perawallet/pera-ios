//
//  AssetQueryItem.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetSearchResult: Model {
    let id: Int64
    let name: String?
    let unitName: String?
    let isVerified: Bool
}

extension AssetSearchResult {
    enum CodingKeys: String, CodingKey {
        case id = "asset_id"
        case name = "name"
        case unitName = "unit_name"
        case isVerified = "is_verified"
    }
}
