//
//  CointlistUser.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class CoinlistUser: Mappable {
    
    let username: String
    let address: String
    let availableAmount: Int
    let lockedAmount: String
}

extension CoinlistUser {
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case address = "address"
        case availableAmount = "available"
        case lockedAmount = "locked"
    }
}
