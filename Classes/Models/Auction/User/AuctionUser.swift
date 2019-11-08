//
//  AuctionUser.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AuctionUser: Model {
    let username: String?
    let name: String?
    let address: String?
    var availableAmount: Int?
    let lockedAmount: Int?
}

extension AuctionUser {
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case name = "name"
        case address = "Address"
        case availableAmount = "Available"
        case lockedAmount = "Locked"
    }
}
