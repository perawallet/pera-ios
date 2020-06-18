//
//  AssetConfigTransaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetConfigTransaction: Model {
    let id: Int64?
}

extension AssetConfigTransaction {
    private enum CodingKeys: String, CodingKey {
        case id = "asset-id"
    }
}
