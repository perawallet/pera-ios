//
//  AssetConfigTransactionType.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetConfigTransactionType: Model {
    let id: Int64?
    let assetDetail: AssetDetail?
}

extension AssetConfigTransactionType {
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case assetDetail = "params"
    }
}
