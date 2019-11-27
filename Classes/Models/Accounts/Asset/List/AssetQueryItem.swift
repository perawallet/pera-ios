//
//  AssetQueryItem.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetQueryItem: Model {
    let index: Int
    let assetDetail: AssetDetail
}

extension AssetQueryItem {
    enum CodingKeys: String, CodingKey {
        case index = "AssetIndex"
        case assetDetail = "AssetParams"
    }
}
