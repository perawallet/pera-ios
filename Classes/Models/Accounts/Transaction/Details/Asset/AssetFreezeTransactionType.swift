//
//  AssetFreezeTransaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetFreezeTransaction: Model {
    let address: String?
    let isFreeze: Bool?
    let assetId: Int64?
}

extension AssetFreezeTransaction {
    private enum CodingKeys: String, CodingKey {
        case address = "address"
        case isFreeze = "new-freeze-status"
        case assetId = "asset-id"
    }
}
