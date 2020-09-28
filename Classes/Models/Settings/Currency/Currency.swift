//
//  Currency.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class Currency: Model {
    let id: String
    let name: String?
    let price: String?
}

extension Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Currency {
    private enum CodingKeys: String, CodingKey {
        case id = "currency_id"
        case name = "name"
        case price = "exchange_price"
    }
}
