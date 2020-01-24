//
//  AssetFreezeTransactionType.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetFreezeTransactionType: Model {
    let account: String
    let isFreeze: Bool
    let assetId: Int64
}

extension AssetFreezeTransactionType {
    private enum CodingKeys: String, CodingKey {
        case account = "acct"
        case isFreeze = "freeze"
        case assetId = "id"
    }
}
