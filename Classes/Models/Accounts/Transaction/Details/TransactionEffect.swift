//
//  TransactionEffect.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class TransactionEffect: Model {
    let createdAsset: Int64?
}

extension TransactionEffect {
    private enum CodingKeys: String, CodingKey {
        case createdAsset = "createdasset"
    }
}
