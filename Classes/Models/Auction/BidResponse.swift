//
//  BidResponse.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class BidResponse: Mappable {
    
    let id: Int
    let uuid: String?
}

extension BidResponse {
    
    enum CodingKeys: String, CodingKey {
        case id = "bid_id"
        case uuid = "bid_uuid"
    }
}
