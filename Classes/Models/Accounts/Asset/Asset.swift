//
//  Asset.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Asset: Model {
    let creator: String
    let amount: UInt64
    let isFrozen: Bool?
}

extension Asset {
    enum CodingKeys: String, CodingKey {
        case creator = "creator"
        case amount = "amount"
        case isFrozen = "frozen"
    }
}

extension Asset: Encodable { }

extension Asset: Equatable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.creator == rhs.creator && lhs.amount == rhs.amount && lhs.isFrozen == rhs.isFrozen
    }
}
