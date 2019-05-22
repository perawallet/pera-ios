//
//  AuctionUser.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AuctionUser: Mappable {
    
    let username: String?
    let address: String?
    let availableAmount: Int?
    let lockedAmount: String?
}

extension AuctionUser {
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case address = "Address"
        case availableAmount = "Available"
        case lockedAmount = "Locked"
    }
}
